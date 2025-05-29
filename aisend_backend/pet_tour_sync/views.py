from django.contrib.admin.views.decorators import staff_member_required
from django.shortcuts import render, redirect
from django.core.management import call_command
from django.contrib import messages
import subprocess
import sys

@staff_member_required
def sync_pet_tour_page(request):
    if request.method == 'POST':
        if 'run_sync' in request.POST:
            call_command('sync_pet_tour')
            messages.success(request, '수동 동기화 완료!')
        elif 'add_cron' in request.POST:
            subprocess.run([sys.executable, 'manage.py', 'crontab', 'add'])
            messages.success(request, '자동 동기화 등록 완료!')
        elif 'remove_cron' in request.POST:
            subprocess.run([sys.executable, 'manage.py', 'crontab', 'remove'])
            messages.success(request, '자동 동기화 해제 완료!')
        return redirect('pet_tour_sync:sync_pet_tour_page')
    return render(request, 'pet_tour_sync/sync_page.html')
