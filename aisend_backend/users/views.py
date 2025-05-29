from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from django.contrib.auth import login, logout
from django.contrib.auth.models import User
from .serializers import UserSerializer, RegisterSerializer, LoginSerializer
from .models import UserSearchCount
from django.db import transaction


@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    """
    새로운 사용자 등록
    """
    serializer = RegisterSerializer(data=request.data)
    
    if serializer.is_valid():
        # 이메일 중복 확인
        if User.objects.filter(email=serializer.validated_data['email']).exists():
            return Response({
                'success': False,
                'message': '이미 사용 중인 이메일입니다.'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        user = serializer.save()
        token, created = Token.objects.get_or_create(user=user)
        
        # 새 사용자를 위한 검색 횟수 카운터 생성
        UserSearchCount.objects.create(user=user)
        
        return Response({
            'success': True,
            'message': '회원가입이 완료되었습니다.',
            'data': {
                'user': UserSerializer(user).data,
                'access_token': token.key,
            }
        }, status=status.HTTP_201_CREATED)
    
    # 유효성 검사 오류 처리
    errors = serializer.errors
    first_error = list(errors.values())[0][0] if errors else '회원가입에 실패했습니다.'
    
    return Response({
        'success': False,
        'message': str(first_error),
        'errors': errors
    }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    """
    사용자 로그인
    """
    serializer = LoginSerializer(data=request.data, context={'request': request})
    
    if serializer.is_valid():
        user = serializer.validated_data['user']
        login(request, user)
        token, created = Token.objects.get_or_create(user=user)
        
        # 사용자의 검색 카운터가 없으면 생성
        search_count, created = UserSearchCount.objects.get_or_create(user=user)
        
        return Response({
            'success': True,
            'message': '로그인되었습니다.',
            'data': {
                'user': UserSerializer(user).data,
                'access_token': token.key,
                'refresh_token': token.key,  # 단순화를 위해 동일한 토큰 사용
                'search_info': {
                    'daily_limit': search_count.DAILY_SEARCH_LIMIT,
                    'remaining_searches': search_count.get_remaining_searches(),
                    'cooldown_seconds': search_count.get_cooldown_seconds(),
                }
            }
        }, status=status.HTTP_200_OK)
    
    errors = serializer.errors
    first_error = list(errors.values())[0][0] if errors else '로그인에 실패했습니다.'
    
    return Response({
        'success': False,
        'message': str(first_error),
    }, status=status.HTTP_401_UNAUTHORIZED)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_view(request):
    """
    사용자 로그아웃
    """
    try:
        # 토큰 삭제
        request.user.auth_token.delete()
    except:
        pass
    
    logout(request)
    
    return Response({
        'success': True,
        'message': '로그아웃되었습니다.'
    }, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def me(request):
    """
    현재 로그인한 사용자 정보
    """
    search_count, created = UserSearchCount.objects.get_or_create(user=request.user)
    
    return Response({
        'success': True,
        'data': {
            'user': UserSerializer(request.user).data,
            'search_info': {
                'daily_limit': search_count.DAILY_SEARCH_LIMIT,
                'remaining_searches': search_count.get_remaining_searches(),
                'cooldown_seconds': search_count.get_cooldown_seconds(),
            }
        }
    }, status=status.HTTP_200_OK)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_profile(request):
    """
    사용자 프로필 업데이트
    """
    user = request.user
    serializer = UserSerializer(user, data=request.data, partial=True)
    
    if serializer.is_valid():
        serializer.save()
        return Response({
            'success': True,
            'message': '프로필이 업데이트되었습니다.',
            'data': {
                'user': serializer.data
            }
        }, status=status.HTTP_200_OK)
    
    return Response({
        'success': False,
        'message': '프로필 업데이트에 실패했습니다.',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([AllowAny])
def check_email(request):
    """
    이메일 중복 확인
    """
    email = request.query_params.get('email', '')
    
    if not email:
        return Response({
            'success': False,
            'message': '이메일을 입력해주세요.'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    exists = User.objects.filter(email=email).exists()
    
    return Response({
        'success': True,
        'exists': exists
    }, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([AllowAny])
def forgot_password(request):
    """
    비밀번호 재설정 요청
    """
    email = request.data.get('email', '')
    
    if not email:
        return Response({
            'success': False,
            'message': '이메일을 입력해주세요.'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        user = User.objects.get(email=email)
        # 실제로는 이메일 발송 로직이 필요합니다
        # 여기서는 간단히 성공 응답만 반환
        return Response({
            'success': True,
            'message': '비밀번호 재설정 이메일이 발송되었습니다.'
        }, status=status.HTTP_200_OK)
    except User.DoesNotExist:
        return Response({
            'success': False,
            'message': '등록되지 않은 이메일입니다.'
        }, status=status.HTTP_404_NOT_FOUND)


# 검색 횟수 관련 API 추가
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def search_count_info(request):
    """
    현재 사용자의 검색 횟수 정보 조회
    """
    search_count, created = UserSearchCount.objects.get_or_create(user=request.user)
    
    return Response({
        'success': True,
        'data': {
            'daily_limit': search_count.DAILY_SEARCH_LIMIT,
            'search_count': search_count.search_count,
            'remaining_searches': search_count.get_remaining_searches(),
            'cooldown_seconds': search_count.get_cooldown_seconds(),
            'cooldown_minutes': search_count.COOLDOWN_MINUTES,
            'can_search': search_count.can_search(),
            'last_search_time': search_count.last_search_time.isoformat() if search_count.last_search_time else None,
        }
    }, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def use_search(request):
    """
    검색 횟수 사용 - 검색 시 호출
    """
    search_count, created = UserSearchCount.objects.get_or_create(user=request.user)
    
    # 검색 가능 여부 확인
    if not search_count.can_search():
        return Response({
            'success': False,
            'message': f'검색 제한에 도달했습니다. 남은 검색 횟수: {search_count.get_remaining_searches()}, 쿨다운: {search_count.get_cooldown_seconds()}초',
            'data': {
                'remaining_searches': search_count.get_remaining_searches(),
                'cooldown_seconds': search_count.get_cooldown_seconds(),
            }
        }, status=status.HTTP_429_TOO_MANY_REQUESTS)
    
    # 검색 횟수 증가
    with transaction.atomic():
        search_count.increment_search_count()
    
    return Response({
        'success': True,
        'message': '검색을 시작합니다.',
        'data': {
            'remaining_searches': search_count.get_remaining_searches(),
            'cooldown_seconds': search_count.get_cooldown_seconds(),
        }
    }, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def reset_search_count(request):
    """
    검색 횟수 초기화 (테스트용 또는 관리자용)
    """
    # 실제 운영에서는 관리자 권한 검사가 필요합니다
    search_count, created = UserSearchCount.objects.get_or_create(user=request.user)
    search_count.reset_daily_count()
    
    return Response({
        'success': True,
        'message': '검색 횟수가 초기화되었습니다.',
        'data': {
            'remaining_searches': search_count.get_remaining_searches(),
        }
    }, status=status.HTTP_200_OK)
