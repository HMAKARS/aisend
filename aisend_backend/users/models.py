from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone

class UserSearchCount(models.Model):
    """사용자별 검색 횟수 추적 모델"""
    user = models.OneToOneField(
        User, 
        on_delete=models.CASCADE, 
        related_name='search_count'
    )
    search_count = models.IntegerField(default=0)
    last_search_date = models.DateField(null=True, blank=True)
    last_search_time = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    # 일일 검색 제한
    DAILY_SEARCH_LIMIT = 3
    # 쿨다운 시간 (분)
    COOLDOWN_MINUTES = 10
    
    def __str__(self):
        return f"{self.user.username} - {self.search_count} searches"
    
    def reset_daily_count(self):
        """일일 검색 횟수 초기화"""
        self.search_count = 0
        self.last_search_date = timezone.now().date()
        self.save()
    
    def increment_search_count(self):
        """검색 횟수 증가"""
        now = timezone.now()
        today = now.date()
        
        # 날짜가 변경된 경우 카운트 리셋
        if self.last_search_date and self.last_search_date < today:
            self.reset_daily_count()
        
        self.search_count += 1
        self.last_search_time = now
        self.last_search_date = today
        self.save()
    
    def get_remaining_searches(self):
        """남은 검색 횟수 반환"""
        now = timezone.now()
        today = now.date()
        
        # 날짜가 변경된 경우
        if self.last_search_date and self.last_search_date < today:
            return self.DAILY_SEARCH_LIMIT
        
        return max(0, self.DAILY_SEARCH_LIMIT - self.search_count)
    
    def get_cooldown_seconds(self):
        """쿨다운 남은 시간(초) 반환"""
        if not self.last_search_time:
            return 0
        
        now = timezone.now()
        cooldown_end_time = self.last_search_time + timezone.timedelta(minutes=self.COOLDOWN_MINUTES)
        difference = cooldown_end_time - now
        
        return max(0, int(difference.total_seconds()))
    
    def can_search(self):
        """검색 가능 여부"""
        now = timezone.now()
        today = now.date()
        
        # 날짜가 변경된 경우
        if self.last_search_date and self.last_search_date < today:
            return True
        
        # 일일 제한 확인
        if self.search_count >= self.DAILY_SEARCH_LIMIT:
            return False
        
        # 쿨다운 확인
        if self.get_cooldown_seconds() > 0:
            return False
        
        return True
