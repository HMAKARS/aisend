import requests
from django.core.management.base import BaseCommand
from attractions.models import PetTourSpot
from django.conf import settings
import xml.etree.ElementTree as ET

class Command(BaseCommand):
    help = '매일 21시, 반려동물 관광정보 API 전체 동기화 (기존 데이터 완전삭제 후 최신화)'

    def handle(self, *args, **options):
        api_key = settings.TOUR_API_KEY  # settings.py 또는 .env에 저장
        print(api_key)
        url = f'http://apis.data.go.kr/B551011/KorPetTourService/petTourSyncList?serviceKey={api_key}&numOfRows=10000&pageNo=1&_type=xml&MobileOS=ETC&MobileApp=PetTrip'
        response = requests.get(url)
        response.encoding = 'utf-8'
        if response.status_code != 200:
            self.stderr.write('API 요청 실패')
            return

        root = ET.fromstring(response.text)
        items = root.findall('.//item')
        self.stdout.write(f'API에서 {len(items)}개 데이터 수신')

        # 기존 데이터 전체 삭제
        PetTourSpot.objects.all().delete()
        self.stdout.write('기존 데이터 전체 삭제 완료')

        # 새 데이터 insert
        new_objs = []
        for item in items:
            new_objs.append(PetTourSpot(
                contentid = item.findtext('contentid'),
                title = item.findtext('title'),
                addr1 = item.findtext('addr1'),
                addr2 = item.findtext('addr2'),
                areacode = item.findtext('areacode'),
                sigungucode = item.findtext('sigungucode'),
                mapx = float(item.findtext('mapx') or 0),
                mapy = float(item.findtext('mapy') or 0),
                tel = item.findtext('tel'),
                firstimage = item.findtext('firstimage'),
                contenttypeid = item.findtext('contenttypeid'),
                cat1 = item.findtext('cat1'),
                cat2 = item.findtext('cat2'),
                cat3 = item.findtext('cat3'),
                overview = item.findtext('overview') or '',
                createdtime = item.findtext('createdtime'),
                modifiedtime = item.findtext('modifiedtime'),
            ))
        PetTourSpot.objects.bulk_create(new_objs)
        self.stdout.write(self.style.SUCCESS(f'동기화 완료! (총 {len(new_objs)}건)'))