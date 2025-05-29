from django.urls import path
from . import views

app_name = 'users'

urlpatterns = [
    path('register/', views.register, name='register'),
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('me/', views.me, name='me'),
    path('profile/', views.update_profile, name='update_profile'),
    path('check-email/', views.check_email, name='check_email'),
    path('forgot-password/', views.forgot_password, name='forgot_password'),
    
    # 검색 횟수 관련 엔드포인트
    path('search-count/', views.search_count_info, name='search_count_info'),
    path('use-search/', views.use_search, name='use_search'),
    path('reset-search-count/', views.reset_search_count, name='reset_search_count'),
]
