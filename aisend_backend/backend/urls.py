from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    # 기존 앱들...
    path('pet-tour/', include('pet_tour_sync.urls')),
]
