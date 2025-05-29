from django.urls import path
from .views import sync_pet_tour_page

app_name = 'pet_tour_sync'

urlpatterns = [
    path('sync/', sync_pet_tour_page, name='sync_pet_tour_page'),
]
