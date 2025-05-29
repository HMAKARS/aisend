from django.contrib import admin
from .models import PetTourSpot

@admin.register(PetTourSpot)
class PetTourSpotAdmin(admin.ModelAdmin):
    list_display = ('title', 'contentid', 'addr1', 'tel', 'firstimage')
    search_fields = ('title', 'addr1', 'addr2', 'tel')
    list_filter = ('areacode', 'sigungucode', 'contenttypeid')
    readonly_fields = ()
