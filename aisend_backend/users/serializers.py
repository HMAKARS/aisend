from rest_framework import serializers
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from .models import UserSearchCount


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name')
        read_only_fields = ('id',)


class RegisterSerializer(serializers.ModelSerializer):
    name = serializers.CharField(source='first_name', max_length=150)
    password = serializers.CharField(write_only=True, min_length=6)
    password_confirmation = serializers.CharField(write_only=True)
    agree_to_marketing = serializers.BooleanField(default=False, required=False)

    class Meta:
        model = User
        fields = ('name', 'email', 'password', 'password_confirmation', 
                  'agree_to_marketing')

    def validate(self, attrs):
        password = attrs.get('password')
        password_confirmation = attrs.pop('password_confirmation', None)
        
        if password != password_confirmation:
            raise serializers.ValidationError({
                'password_confirmation': '비밀번호가 일치하지 않습니다.'
            })
        
        # 마케팅 동의는 추가 처리를 위해 제거 (User 모델에는 없음)
        attrs.pop('agree_to_marketing', None)
        
        return attrs

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['email'],  # 이메일을 username으로 사용
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
        )
        return user


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        email = attrs.get('email')
        password = attrs.get('password')

        if email and password:
            # 이메일로 User 찾기
            try:
                user = User.objects.get(email=email)
                # 인증
                user = authenticate(request=self.context.get('request'),
                                  username=user.username,  # username 사용
                                  password=password)
                
                if not user:
                    raise serializers.ValidationError('이메일 또는 비밀번호가 올바르지 않습니다.')
            except User.DoesNotExist:
                raise serializers.ValidationError('이메일 또는 비밀번호가 올바르지 않습니다.')
        else:
            raise serializers.ValidationError('이메일과 비밀번호를 모두 입력해주세요.')

        attrs['user'] = user
        return attrs


class UserSearchCountSerializer(serializers.ModelSerializer):
    remaining_searches = serializers.SerializerMethodField()
    cooldown_seconds = serializers.SerializerMethodField()
    can_search = serializers.SerializerMethodField()
    daily_limit = serializers.IntegerField(source='DAILY_SEARCH_LIMIT', read_only=True)
    cooldown_minutes = serializers.IntegerField(source='COOLDOWN_MINUTES', read_only=True)
    
    class Meta:
        model = UserSearchCount
        fields = [
            'search_count', 
            'remaining_searches', 
            'cooldown_seconds', 
            'can_search',
            'daily_limit',
            'cooldown_minutes',
            'last_search_date',
            'last_search_time',
        ]
        read_only_fields = fields
    
    def get_remaining_searches(self, obj):
        return obj.get_remaining_searches()
    
    def get_cooldown_seconds(self, obj):
        return obj.get_cooldown_seconds()
    
    def get_can_search(self, obj):
        return obj.can_search()
