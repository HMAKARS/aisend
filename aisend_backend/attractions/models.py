from django.db import models

class PetTourSpot(models.Model):
    contentid = models.CharField(max_length=32, unique=True)
    title = models.CharField(max_length=255)
    addr1 = models.CharField(max_length=255, blank=True)
    addr2 = models.CharField(max_length=255, blank=True)
    areacode = models.CharField(max_length=10, blank=True)
    sigungucode = models.CharField(max_length=10, blank=True)
    mapx = models.FloatField(null=True, blank=True)
    mapy = models.FloatField(null=True, blank=True)
    tel = models.CharField(max_length=100, blank=True)
    firstimage = models.URLField(blank=True)
    contenttypeid = models.CharField(max_length=10, blank=True)
    cat1 = models.CharField(max_length=10, blank=True)
    cat2 = models.CharField(max_length=10, blank=True)
    cat3 = models.CharField(max_length=20, blank=True)
    overview = models.TextField(blank=True)
    createdtime = models.CharField(max_length=20, blank=True)
    modifiedtime = models.CharField(max_length=20, blank=True)

    def __str__(self):
        return f'{self.title} ({self.contentid})'
