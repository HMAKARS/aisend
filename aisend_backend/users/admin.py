from django.contrib import admin
from .models import UserSearchCount

@admin.register(UserSearchCount)
class UserSearchCountAdmin(admin.ModelAdmin):
    list_display = ['user', 'search_count', 'last_search_date', 'last_search_time', 'created_at']
    list_filter = ['last_search_date', 'search_count']
    search_fields = ['user__username', 'user__email']
    ordering = ['-last_search_time']
    
    def get_readonly_fields(self, request, obj=None):
        if obj:  # 수정 시
            return ['user', 'created_at', 'updated_at']
        return ['created_at', 'updated_at']
