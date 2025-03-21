import datetime
from datetime import datetime
import json
import os
import pycountry
from django.http import HttpResponse, JsonResponse
from django.shortcuts import  redirect, render
from django.urls import reverse
import joblib
import requests
import urllib
from CrisisGuard import settings
from app.models import *
from app.river import get_rivers_near_location
from app.sample import getmaindata
from django.contrib import messages, auth
from django.db.models import Count, F, FloatField, ExpressionWrapper,Sum
from django.core.files.storage import FileSystemStorage
from collections import defaultdict
from django.core.mail import send_mail
from django.db.models import Q
from django.contrib.auth.decorators import login_required
from django.utils import timezone
from datetime import timedelta
from datetime import datetime






##################################################  COMMON  ###################################################


def login(request):
    return render(request,'common/login.html')



def logout(request):
    auth.logout(request)
    return redirect('/')





def login_post(request):
    if request.method == 'POST':
        name = request.POST.get('username', '').strip()
        password = request.POST.get('password', '').strip()
        if not name or not password:
            messages.error(request, 'Please enter both username and password.')
            return redirect('/')
        try:
            user = Login.objects.get(username__iexact=name)
            if user.password == password:
                request.session['lid'] = user.id
                ob1 = auth.authenticate(username="admin", password="admin")
                if ob1 is not None:
                    auth.login(request, ob1)
                dashboard_mapping = {
                    'Admin': '/admin_dashboard',
                    'Coordinator': '/coordinator_dashboard',
                    'ERT': '/ert_dashboard',
                }
                dashboard_url = dashboard_mapping.get(user.type)
                if dashboard_url:
                    messages.success(request, f'{user.type} Logged In')
                    return redirect(dashboard_url)
                else:
                    messages.error(request, 'Unknown user type.')
                    return redirect('/')
            else:
                messages.error(request, 'Invalid username or password.')
                return redirect('/')
        except Login.DoesNotExist:
            messages.error(request, 'Invalid username or password.')
            return redirect('/')
    messages.error(request, 'Invalid request method.')
    return redirect('/')




def forgotpass(request):
    return render(request,'common/forgotpass.html')


@login_required(login_url='/')
def change_password(request):
    if request.method == "POST":
        user_id = request.session.get('lid')
        if not user_id:
            messages.error(request, 'You are not logged in.')
            return redirect('/logout')
        if 'new_password' in request.POST and 'confirm_password' in request.POST:
            new_password = request.POST['new_password']
            confirm_password = request.POST['confirm_password']
            user = Login.objects.get(id=user_id)
            if new_password == confirm_password:
                user.password = new_password
                user.save()
                messages.success(request, 'Password updated successfully!')
                return redirect('/logout')
            else:
                messages.error(request, 'New passwords do not match.')
                return render(request, 'common/change password.html')
        elif 'current_password' in request.POST:
            current_password = request.POST['current_password']
            try:
                user = Login.objects.get(id=user_id)
                if user.password == current_password:
                    return render(request, 'common/change password.html', {
                        'current_password_verified': True
                    })
                else:
                    messages.error(request, 'Incorrect current password.')
                    return render(request, 'common/change password.html')
            except Login.DoesNotExist:
                messages.error(request, 'User does not exist.')
                return redirect('/logout')
    return render(request, 'common/change password.html')



def register_ert(request):
    return render(request,'common/register ert.html')



def register_ert_post(request):
    department = request.POST["department"]
    district = request.POST["district"]
    city = request.POST["city"]
    pin = request.POST["pin"]
    contactno = request.POST["contactno"]
    email = request.POST["email"]
    username = request.POST["username"]
    password = request.POST["password"]
    if Login.objects.filter(username=username).exists():
        messages.error(request, 'Username already exists!')
        return redirect('/register_ert')
    if EmergencyTeam.objects.filter(email=email).exists():
        messages.error(request, 'Email already exists!')
        return redirect('/register_ert')
    if EmergencyTeam.objects.filter(contact_no=contactno).exists():
        messages.error(request, 'Contact number already exists!')
        return redirect('/register_ert')
    ob = Login(username=username, password=password, type="Pending")
    ob.save()
    obj = EmergencyTeam(
        LOGIN=ob,
        department=department,
        district=district,
        city=city,
        pin=pin,
        contact_no=contactno,
        email=email
    )
    obj.save()
    messages.success(request, 'Emergency Response Team registered!')
    return redirect('/ert_registration_status')



def ert_registration_status(request):
    ob=EmergencyTeam.objects.all()
    return render(request,'common/status.html', {'val': ob})





##################################################  ADMIN  ###################################################

@login_required(login_url='/')
def admin_dashboard(request):
    context = {
        'total_camp': Camp.objects.count(),
        'total_coordinator': CampCoordinator.objects.count(),
        'total_volunteer': Login.objects.filter(type='Volunteer').count(),
        'total_member': Member.objects.count(),
        'total_ert': Login.objects.filter(type='ERT').count(),
        'total_user': Public.objects.count(),
        'total_complaints_pending': Complaint.objects.filter(status='Pending').count(),
        'total_complaints_working_on': Complaint.objects.filter(status='Working').count(),
        'total_complaints_resolved': Complaint.objects.filter(status='Resolved').count(),
        'total_donations': '{:,}'.format(int(Payment.objects.aggregate(total=Sum('amount'))['total'] or 0)),

    }
    return render(request, 'admin/dashboard.html', context)



##########  ADD & MANAGE CAMP  ##########

@login_required(login_url='/')
def admin_add_camp(request):
    return render (request,'admin/add camp.html')


@login_required(login_url='/')
def admin_add_camp_post(request):
    camp = request.POST["camp"]
    capacity = request.POST["capacity"]
    district = request.POST["district"]
    city = request.POST["city"]
    pin = request.POST["pin"]
    email = request.POST["email"]
    contactno = request.POST["contactno"]
    if Camp.objects.filter(camp_name=camp).exists():
        messages.error(request, 'Camp name already exists!')
        return redirect('/admin_add_camp')
    if Camp.objects.filter(email=email).exists():
        messages.error(request, 'Email already exists!')
        return redirect('/admin_add_camp')
    if Camp.objects.filter(contact_no=contactno).exists():
        messages.error(request, 'Contact number already exists!')
        return redirect('/admin_add_camp')
    obj = Camp()
    obj.camp_name = camp
    obj.capacity = capacity
    obj.district = district
    obj.city = city
    obj.pin = pin
    obj.email = email
    obj.contact_no = contactno
    obj.save()
    messages.success(request, 'Camp Added successfully!')
    return redirect('/admin_manage_camp')


@login_required(login_url='/')
def admin_manage_camp(request):
    camps = Camp.objects.annotate(
        member_count=Count('member'),
        occupancy_rate=ExpressionWrapper(
            (F('member_count') * 100.0) / F('capacity'),
            output_field=FloatField()
        )
    )
    camp_data = []
    for camp in camps:
        try:
            camp_coordinator = camp.campcoordinator  
        except CampCoordinator.DoesNotExist:
            camp_coordinator = None 

        camp_data.append({
            'camp': camp,
            'coordinator': camp_coordinator
        })
    return render(request, 'admin/manage camp.html', {'camp_data': camp_data})


@login_required(login_url='/')
def admin_search_camp(request):
    camp_name = request.POST.get('campname', '')  
    camps = Camp.objects.filter(camp_name__icontains=camp_name).annotate(
        member_count=Count('member'),
        occupancy_rate=ExpressionWrapper(
            (F('member_count') * 100) / F('capacity'),
            output_field=FloatField()
        )
    )
    camp_data = []
    for camp in camps:
        try:
            camp_coordinator = camp.campcoordinator 
        except CampCoordinator.DoesNotExist:
            camp_coordinator = None  

        camp_data.append({
            'camp': camp,
            'coordinator': camp_coordinator
        })
    return render(request, 'admin/manage camp.html', {'camp_data': camp_data})


@login_required(login_url='/')
def admin_edit_camp(request,id):
    request.session["campid"]=id
    ob=Camp.objects.get(id=id)
    return render(request, 'admin/edit camp.html',{"ob":ob})


@login_required(login_url='/')
def admin_edit_camp_post(request):
    camp = request.POST.get("camp")
    capacity = request.POST.get("capacity")
    district = request.POST.get("district")
    city = request.POST.get("city")
    pin = request.POST.get("pin")
    contactno = request.POST.get("contactno")
    email = request.POST.get("email")
    camp_id = request.session.get("campid")
    obj = Camp.objects.get(id=camp_id)
    if Camp.objects.filter(camp_name=camp).exclude(id=camp_id).exists():
        messages.error(request, 'Camp name already exists!')
        return redirect(reverse('admin_edit_camp', args=[camp_id]))
    if Camp.objects.filter(email=email).exclude(id=camp_id).exists():
        messages.error(request, 'Email already exists!')
        return redirect(reverse('admin_edit_camp', args=[camp_id]))
    if Camp.objects.filter(contact_no=contactno).exclude(id=camp_id).exists():
        messages.error(request, 'Contact number already exists!')
        return redirect(reverse('admin_edit_camp', args=[camp_id]))
    obj.camp_name = camp
    obj.capacity = capacity
    obj.district = district
    obj.city = city
    obj.pin = pin
    obj.contact_no = contactno
    obj.email = email
    obj.save()
    messages.success(request, 'Camp Edited successfully!')
    return redirect('/admin_manage_camp')


@login_required(login_url='/')
def admin_delete_camp(request,id):
    Camp.objects.get(id=id).delete()
    messages.success(request, 'Camp Deleted')
    return redirect('/admin_manage_camp')



##########  ADD & MANAGE CAMP COORDINATOR  ##########

@login_required(login_url='/')
def admin_add_coordinator(request):
    camps = Camp.objects.filter(campcoordinator__isnull=True)
    return render(request, 'admin/add coordinator.html', {"camps": camps})


@login_required(login_url='/')
def admin_add_coordinator_post(request):
    camp = request.POST["camp"]
    name = request.POST["name"]
    gender = request.POST["gender"]
    dob = request.POST["dob"]
    contactno = request.POST["contactno"]
    email = request.POST["email"]
    district = request.POST["district"]
    city = request.POST["city"]
    pin = request.POST["pin"]
    username = request.POST["username"]
    password = request.POST["password"]
    aadhaar_number = request.POST["aadhaar_number"]  
    photo = request.FILES["photo"]
    if CampCoordinator.objects.filter(contact_no=contactno).exists():
        messages.error(request, 'Contact number already exists')
        return redirect('/admin_add_coordinator')
    if CampCoordinator.objects.filter(email=email).exists():
        messages.error(request, 'Email already exists')
        return redirect('/admin_add_coordinator')
    if CampCoordinator.objects.filter(aadhaar_number=aadhaar_number).exists():
        messages.error(request, 'Aadhaar number already exists')
        return redirect('/admin_add_coordinator')
    if Login.objects.filter(username=username).exists():
        messages.error(request, 'Username already exists')
        return redirect('/admin_add_coordinator')
    fs = FileSystemStorage()
    fsave = fs.save(photo.name, photo)
    login_obj = Login(username=username, password=password, type="Coordinator")
    login_obj.save()
    coordinator_obj = CampCoordinator(
        LOGIN=login_obj,
        CAMP_id=camp,
        name=name,
        gender=gender,
        dob=dob,
        contact_no=contactno,
        email=email,
        district=district,
        city=city,
        pin=pin,
        aadhaar_number=aadhaar_number,
        photo=fsave
    )
    coordinator_obj.save()
    messages.success(request, 'Camp Coordinator Added')
    return redirect('/admin_manage_coordinator')


@login_required(login_url='/')
def admin_manage_coordinator(request):
    ob=CampCoordinator.objects.all()
    return render (request,'admin/manage coordinator.html',{'val':ob})


@login_required(login_url='/')
def admin_search_coordinator(request):
    name = request.POST['coordinatorname']
    ob = CampCoordinator.objects.filter(name__icontains=name)
    return render(request, 'admin/manage coordinator.html', {'val': ob})


@login_required(login_url='/')
def admin_edit_coordinator(request,id):
    request.session["coordinatorid"]=id
    ob=CampCoordinator.objects.get(id=id)
    return render(request, 'admin/edit coordinator.html', {"ob": ob})


@login_required(login_url='/')
def admin_edit_coordinator_post(request):
    name = request.POST["name"]
    gender = request.POST["gender"]
    dob = request.POST["dob"]
    contactno = request.POST["contactno"]
    email = request.POST["email"]
    district = request.POST["district"]
    city = request.POST["city"]
    pin = request.POST["pin"]
    aadhaar_number = request.POST["aadhaar_number"]
    obj = CampCoordinator.objects.get(id=request.session["coordinatorid"])
    if CampCoordinator.objects.filter(contact_no=contactno).exclude(id=obj.id).exists():
        messages.error(request, 'Contact number already exists')
        return redirect('admin_edit_coordinator', id=obj.id)
    if CampCoordinator.objects.filter(email=email).exclude(id=obj.id).exists():
        messages.error(request, 'Email already exists')
        return redirect('admin_edit_coordinator', id=obj.id)
    if CampCoordinator.objects.filter(aadhaar_number=aadhaar_number).exclude(id=obj.id).exists():
        messages.error(request, 'Aadhaar number already exists')
        return redirect('admin_edit_coordinator', id=obj.id)
    obj.name = name
    obj.gender = gender
    obj.dob = dob
    obj.contact_no = contactno
    obj.email = email
    obj.district = district
    obj.city = city
    obj.pin = pin
    obj.aadhaar_number = aadhaar_number
    obj.save()
    messages.success(request, 'Camp Coordinator Edited')
    return redirect('/admin_manage_coordinator')


@login_required(login_url='/')
def admin_delete_coordinator(request, id):
    if CampCoordinator.objects.filter(id=id).exists():
        coordinator = CampCoordinator.objects.get(id=id)
        if coordinator.photo:
            file_path = os.path.join(settings.MEDIA_ROOT, coordinator.photo.name)
            if os.path.exists(file_path):
                os.remove(file_path)
        login = coordinator.LOGIN
        login.delete()
        coordinator.delete()
        messages.success(request, 'Camp Coordinator Deleted')
    else:
        messages.error(request, 'Camp Coordinator not found')
    return redirect('/admin_manage_coordinator')



##########  ADD & MANAGE GUIDELINES  ##########

@login_required(login_url='/')
def admin_send_guideline(request):
    ob = CampCoordinator.objects.all()
    return render (request,'admin/add guideline.html',{"data":ob})


@login_required(login_url='/')
def admin_send_guideline_post(request):
    camp=request.POST["camp"]
    guideline=request.FILES["guideline"]
    fs=FileSystemStorage( )
    fsave=fs.save(guideline.name,guideline)
    obj=Guideline()
    obj.COORDINATOR=CampCoordinator.objects.get(id=camp)
    obj.guideline=fsave
    obj.save()
    messages.success(request, 'Guideline sent')
    return redirect('/admin_manage_guideline')


@login_required(login_url='/')
def admin_manage_guideline(request):
    ob = Guideline.objects.all()
    return render (request,'admin\manage guideline.html',{"val":ob})


@login_required(login_url='/')
def admin_search_guideline(request):
    name = request.POST['coordinatorname']
    ob = Guideline.objects.filter(COORDINATOR__name__icontains=name)
    return render(request, 'admin/manage guideline.html', {'val': ob})


@login_required(login_url='/')
def admin_delete_guideline(request, id):
    guideline = Guideline.objects.get(id=id)
    file_path = os.path.join(settings.MEDIA_ROOT, guideline.guideline.name)
    if os.path.exists(file_path):
        os.remove(file_path)
    guideline.delete()
    messages.success(request, 'Guideline Deleted')
    return redirect('/admin_manage_guideline')



##########  VERIFY EMERGENCY TEAM  ##########

@login_required(login_url='/')
def admin_verify_ert(request):
    ob=EmergencyTeam.objects.filter(LOGIN__type='Pending')
    return render(request, 'admin/verify ert.html', {'val': ob})


@login_required(login_url='/')
def admin_manage_ert(request):
    ob1=EmergencyTeam.objects.filter(LOGIN__type='ERT')
    ob2=EmergencyTeam.objects.filter(LOGIN__type='Rejected')
    return render(request, 'admin/manage ert.html', {'val1': ob1 ,'val2':ob2})



@login_required(login_url='/')
def admin_accept_ert(request, id):
    try:
        request.session["ERTid"] = id
        login = Login.objects.get(id=id)
        login.type = "ERT"
        login.save()
        emergency_team = EmergencyTeam.objects.get(LOGIN=login)
        subject = 'Emergency Team Application Accepted'
        message = f'Dear {emergency_team.city},{emergency_team.department} Team,\n\nYour application to join the Emergency Team has been accepted. Welcome aboard!\n\nBest regards,\n Admin'
        from_email = settings.EMAIL_HOST_USER
        recipient_list = [emergency_team.email]
        send_mail(subject, message, from_email, recipient_list, fail_silently=False)
        messages.success(request, 'Emergency Team Accepted and email sent!')
    except Exception as e:
        messages.error(request, f"Error: {str(e)}")

    return redirect('/admin_manage_ert')


@login_required(login_url='/')
def admin_reject_ert(request, id):
    try:
        request.session["ERTid"] = id
        login = Login.objects.get(id=id)
        login.type = "Rejected"
        login.save()
        emergency_team = EmergencyTeam.objects.get(LOGIN=login)
        subject = 'Emergency Team Application Rejected'
        message = f'Dear {emergency_team.city},{emergency_team.department} Team,\n\nWe regret to inform you that your application to join the Emergency Team has been rejected.\n\nBest regards,\Admin'
        from_email = settings.EMAIL_HOST_USER
        recipient_list = [emergency_team.email]
        send_mail(subject, message, from_email, recipient_list, fail_silently=False)
        messages.error(request, 'Emergency Team Rejected and email sent!')
    except Exception as e:
        messages.error(request, f"Error: {str(e)}")
    return redirect('/admin_manage_ert')


@login_required(login_url='/')
def admin_search_verify_ert(request):
    district = request.POST['district']
    ob = EmergencyTeam.objects.filter(district__icontains=district,LOGIN__type='pending')
    return render(request, 'admin/verify ert.html', {'val': ob})


@login_required(login_url='/')
def admin_search_accept_ert(request):
    district = request.POST['district']
    ob = EmergencyTeam.objects.filter(district__icontains=district,LOGIN__type='ert')
    ob2=EmergencyTeam.objects.filter(LOGIN__type='Rejected')
    return render(request, 'admin/manage ert.html', {'val1': ob,'val2':ob2})


@login_required(login_url='/')
def admin_search_reject_ert(request):
    district = request.POST['district']
    ob = EmergencyTeam.objects.filter(district__icontains=district,LOGIN__type='rejected')
    ob1=EmergencyTeam.objects.filter(LOGIN__type='ERT')
    return render(request, 'admin/manage ert.html', {'val1': ob1 ,'val2':ob})



##########  MANAGE NOTIFICATION  ##########

@login_required(login_url='/')
def admin_send_notification(request):
    return render (request,'admin/add notification.html')


@login_required(login_url='/')
def admin_send_notification_post(request):
   title=request.POST["title"]
   notification=request.POST["notification"]
   obj=Notification()
   obj.title=title
   obj.notification=notification
   obj.save()
   messages.success(request, 'Notification Sent')
   return redirect('/admin_manage_notification')   
  

@login_required(login_url='/')
def admin_manage_notification(request):
    ob = Notification.objects.all().order_by('-posted_date', '-posted_time')
    return render(request, 'admin/manage notification.html', {"val": ob})


@login_required(login_url='/')
def admin_delete_notification(request,id):
    Notification.objects.get(id=id).delete()
    messages.success(request, 'Notification Deleted')
    return redirect('/admin_manage_notification')  
    

@login_required(login_url='/')
def admin_edit_notification(request,id):
    request.session["notificationid"]=id
    ob=Notification.objects.get(id=id)
    return render(request, 'admin/edit notification.html',{"ob":ob})


@login_required(login_url='/')
def admin_edit_notification_post(request):
    title=request.POST["title"]
    notification=request.POST["notification"]
    obj = Notification.objects.get(id=request.session["notificationid"])
    obj.title=title
    obj.notification=notification
    obj.save()
    messages.success(request, 'Notification Edited')
    return redirect('/admin_manage_notification')  
    

@login_required(login_url='/')
def admin_search_notification(request):
    date = request.POST['date']
    ob = Notification.objects.filter(posted_date__icontains=date)
    return render(request, 'admin/manage notification.html',{"val":ob})



##########  DONATION  ##########

@login_required(login_url='/')
def admin_view_donation(request):
    ob = Payment.objects.all().order_by('-id')
    return render(request, 'admin/view donation.html', {"val": ob})



##########  MANAGE COMPLAINT  ##########

@login_required(login_url='/')
def admin_manage_complaint(request):
    ob = Complaint.objects.all().order_by('-posted_at')
    return render (request,'admin/manage complaint.html',{'val':ob})


@login_required(login_url='/')
def admin_reply_complaint(request,id):
    request.session["complaintid"]=id
    ob=Complaint.objects.get(id=id)
    return render(request, 'admin/reply complaint.html',{"ob":ob})


@login_required(login_url='/')
def admin_reply_complaint_post(request):
    status=request.POST["status"]
    reply=request.POST["reply"]
    obj = Complaint.objects.get(id=request.session["complaintid"])
    obj.status=status
    obj.reply=reply
    obj.save()
    messages.success(request, 'Complaint Replied')
    return redirect('/admin_manage_complaint')


@login_required(login_url='/')
def admin_search_complaint(request):
    status = request.POST['status'] 
    ob = Complaint.objects.filter(status__icontains=status)
    return render (request,'admin/manage complaint.html',{'val':ob})





##################################################  CAMP COORDINATOR  ##################################################

@login_required(login_url='/')
def coordinator_dashboard(request):
    user_id = request.session.get('lid')
    try:
        coordinator = CampCoordinator.objects.get(LOGIN__id=user_id)
        current_camp = coordinator.CAMP
        total_members = Member.objects.filter(CAMP=current_camp).count()
        total_volunteer = Volunteer.objects.filter(CAMP=current_camp).count()
        total_missing_asset = Asset.objects.filter(MEMBER__CAMP=current_camp, status='Pending').count()
        total_found_asset = Asset.objects.filter(MEMBER__CAMP=current_camp, status='Found').count()
        total_needs = Needs.objects.filter(CAMP=current_camp).count()
        total_ert = Login.objects.filter(type='ERT').count()
        total_products = Stock.objects.filter(CAMP=current_camp).values('name').distinct().count()
    except CampCoordinator.DoesNotExist:
        total_members = 0
        total_volunteer = 0
        total_missing_asset = 0
        total_needs = 0
        total_products = 0
        total_found_asset = 0
        total_ert = 0
    context = {
        'total_members': total_members,
        'total_volunteer': total_volunteer,
        'total_missing_asset': total_missing_asset,
        'total_needs': total_needs,
        'total_products': total_products,
        'total_found_asset': total_found_asset,
        'total_ert': total_ert,
    }
    return render(request, 'coordinator/dashboard.html', context)


@login_required(login_url='/')
def coordinator_profile(request):
    user_id = request.session.get('lid')
    if not user_id:
        return redirect('/')
    context = {}
    try:
        login_user = Login.objects.get(id=user_id)

        if login_user.type != 'Coordinator':
            return redirect('/')
        coordinator = CampCoordinator.objects.get(LOGIN=login_user)
        context['user_type'] = 'Coordinator'
        context['user_details'] = {
            'username': login_user.username,
            'type': login_user.type,
            'name': coordinator.name,
            'gender': coordinator.gender,
            'dob': coordinator.dob,
            'district': coordinator.district,
            'city': coordinator.city,
            'pin': coordinator.pin,
            'email': coordinator.email,
            'contact_no': coordinator.contact_no,
            'photo': coordinator.photo,
        }
    except Exception:
        return redirect('/')
    return render(request, 'coordinator/profile.html', context)


@login_required(login_url='/')
def update_coordinator_profile(request):
    if request.method == 'POST':
        user_id = request.session.get('lid')
        if not user_id:
            return redirect('/')
        try:
            login_user = Login.objects.get(id=user_id)
            if login_user.type != 'Coordinator':
                return redirect('/')
            new_username = request.POST.get('username')
            new_email = request.POST.get('email')
            new_contact_no = request.POST.get('contactno')
            if Login.objects.filter(username=new_username).exclude(id=user_id).exists():
                messages.error(request, 'Username already exists')
                return redirect('coordinator_profile')
            if CampCoordinator.objects.filter(email=new_email).exclude(LOGIN=login_user).exists():
                messages.error(request, 'Email already exists')
                return redirect('coordinator_profile')
            if CampCoordinator.objects.filter(contact_no=new_contact_no).exclude(LOGIN=login_user).exists():
                messages.error(request, 'Contact number already exists')
                return redirect('coordinator_profile')
            coordinator = CampCoordinator.objects.get(LOGIN=login_user)
            coordinator.name = request.POST.get('name')
            coordinator.gender = request.POST.get('gender')
            coordinator.dob = request.POST.get('dob')
            coordinator.district = request.POST.get('district')
            coordinator.city = request.POST.get('city')
            coordinator.pin = request.POST.get('pin')
            coordinator.email = new_email
            coordinator.contact_no = new_contact_no
            login_user.username = new_username
            if 'photoUpload' in request.FILES:
                if coordinator.photo:
                    old_photo_path = os.path.join(settings.MEDIA_ROOT, coordinator.photo.name)
                    if os.path.exists(old_photo_path):
                        os.remove(old_photo_path)
                coordinator.photo = request.FILES['photoUpload']
            coordinator.save()
            login_user.save()
            messages.success(request, 'Profile updated successfully!')
            return redirect('coordinator_dashboard')
        except Exception as e:
            messages.error(request, f'Error updating profile: {e}')
            return redirect('coordinator_dashboard')
    return redirect('/')



##########  ADD & MANAGE STOCK  ##########

@login_required(login_url='/')
def coordinator_add_stock(request):
    return render(request, 'coordinator/add stock.html')


@login_required(login_url='/')
def coordinator_add_stock_post(request):
    category = request.POST["category"]
    product = request.POST["product"]
    name = request.POST["name"]
    quantity = request.POST["quantity"]
    unit = request.POST["unit"]
    obj = Stock()
    obj.donated="Government"
    obj.category= category
    obj.product=product
    obj.name=name
    obj.quantity=quantity
    obj.unit=unit
    coordinator = CampCoordinator.objects.get(LOGIN__id=request.session['lid'])
    obj.CAMP = coordinator.CAMP 
    obj.save()
    messages.success(request, 'Stock Added')
    return redirect('/coordinator_manage_stock')
   

@login_required(login_url='/')
def coordinator_manage_stock(request):
    login_id = request.session.get('lid')
    coordinator = CampCoordinator.objects.get(LOGIN_id=login_id)
    ob = Stock.objects.filter(CAMP=coordinator.CAMP)
    total_quantities = ob.values('category', 'product', 'unit').annotate(total_quantity=Sum('quantity'))
    grouped_quantities = defaultdict(list)
    for item in total_quantities:
        grouped_quantities[item['category']].append(item)
    grouped_quantities = dict(grouped_quantities)
    return render(request, 'coordinator/manage stock.html', {
        "grouped_quantities": grouped_quantities
    })


@login_required(login_url='/')
def coordinator_detailed_stock(request):
    login_id = request.session.get('lid')
    coordinator = CampCoordinator.objects.get(LOGIN_id=login_id)
    ob = Stock.objects.filter(CAMP=coordinator.CAMP)
    return render(request, 'coordinator/detailed stock.html', {"val": ob})


@login_required(login_url='/')
def coordinator_edit_stock(request,id):
    request.session["stockid"]=id
    ob=Stock.objects.get(id=id)
    return render(request, 'coordinator/edit stock.html',{"ob":ob})


@login_required(login_url='/')
def coordinator_edit_stock_post(request):
    quantity = request.POST["quantity"]
    unit = request.POST["unit"]
    obj = Stock.objects.get(id=request.session["stockid"])
    obj.quantity=quantity
    obj.unit= unit
    obj.save()
    messages.success(request, 'Stock Edited')
    return redirect('/coordinator_detailed_stock')


@login_required(login_url='/')
def coordinator_delete_stock(request,id):
    Stock.objects.get(id=id).delete()
    messages.success(request, 'Stock Deleted')
    return redirect('/coordinator_detailed_stock')


@login_required(login_url='/')
def coordinator_search_stock(request):
    login_id = request.session.get('lid')
    coordinator = CampCoordinator.objects.get(LOGIN_id=login_id)
    product = request.POST['product']
    ob = Stock.objects.filter(CAMP=coordinator.CAMP, product__icontains=product)
    return render(request, 'coordinator/detailed stock.html', {"val": ob})
    


##########  ADD & MANAGE MEMBER  ##########

@login_required(login_url='/')
def coordinator_register_member(request):
    return render (request,'coordinator/register member.html')


@login_required(login_url='/')
def coordinator_register_member_post(request):
    name = request.POST["name"]
    gender = request.POST["gender"]
    dob = request.POST["dob"]
    district = request.POST["district"]
    city = request.POST["city"]
    pin = request.POST["pin"]
    aadhaar_number = request.POST["aadhaar_number"]
    email = request.POST["email"]
    contactno = request.POST["contactno"]
    photo = request.FILES["photo"]
    if Member.objects.filter(aadhaar_number=aadhaar_number).exists():
        messages.error(request, 'Aadhaar number already exists!')
        return redirect('/coordinator_register_member')
    if Member.objects.filter(contact_no=contactno).exists():
        messages.error(request, 'Contact number already exists!')
        return redirect('/coordinator_register_member')
    if Member.objects.filter(email=email).exists():
        messages.error(request, 'Email already exists!')
        return redirect('/coordinator_register_member')
    fs = FileSystemStorage()
    fsave = fs.save(photo.name, photo)
    obj = Member()
    obj.name = name
    obj.gender = gender
    obj.dob = dob
    obj.district = district
    obj.city = city
    obj.pin = pin
    obj.aadhaar_number = aadhaar_number
    obj.contact_no = contactno
    obj.email = email
    obj.photo = fsave
    coordinator = CampCoordinator.objects.get(LOGIN__id=request.session['lid'])
    obj.CAMP = coordinator.CAMP
    obj.save()
    messages.success(request, 'Member Registered')
    return redirect('/coordinator_manage_members')


@login_required(login_url='/')
def coordinator_manage_members(request):
    login_id = request.session.get('lid')
    coordinator = CampCoordinator.objects.get(LOGIN_id=login_id)
    ob = Member.objects.filter(CAMP=coordinator.CAMP)
    return render (request,'coordinator/manage member.html', {"val": ob})


@login_required(login_url='/')
def coordinator_delete_member(request, id):
    if Member.objects.filter(id=id).exists():
        member = Member.objects.get(id=id)
        if member.photo:
            file_path = os.path.join(settings.MEDIA_ROOT, member.photo.name)
            if os.path.exists(file_path):
                os.remove(file_path)
        member.delete()
        messages.success(request, 'Member Removed')
    else:
        messages.error(request, 'Member not found')
    return redirect('/coordinator_manage_members')


@login_required(login_url='/')
def coordinator_edit_member(request,id):
    request.session["memberid"]=id
    ob=Member.objects.get(id=id)
    return render(request,'coordinator/edit member.html',{"ob":ob})


@login_required(login_url='/')
def coordinator_edit_member_post(request):
    name = request.POST["name"]
    gender = request.POST["gender"]
    dob = request.POST["dob"]
    district = request.POST["district"]
    city = request.POST["city"]
    pin = request.POST["pin"]
    email = request.POST["email"]
    contact_no = request.POST["contact_no"]
    aadhaar_number = request.POST["aadhaar_number"]
    obj = Member.objects.get(id=request.session["memberid"])
    if Member.objects.filter(contact_no=contact_no).exclude(id=obj.id).exists():
        messages.error(request, 'Contact number already exists')
        return redirect('coordinator_edit_member', id=obj.id)
    if Member.objects.filter(email=email).exclude(id=obj.id).exists():
        messages.error(request, 'Email already exists')
        return redirect('coordinator_edit_member', id=obj.id)
    if Member.objects.filter(aadhaar_number=aadhaar_number).exclude(id=obj.id).exists():
        messages.error(request, 'Aadhaar number already exists')
        return redirect('coordinator_edit_member', id=obj.id)
    obj.name = name
    obj.gender = gender
    obj.dob = dob
    obj.district = district
    obj.city = city
    obj.pin = pin
    obj.email = email
    obj.contact_no = contact_no
    obj.aadhaar_number = aadhaar_number
    obj.save()
    messages.success(request, 'Member Edited')
    return redirect('/coordinator_manage_members')


@login_required(login_url='/')
def coordinator_search_member(request):
    login_id = request.session.get('lid')
    coordinator = CampCoordinator.objects.get(LOGIN_id=login_id)
    name=request.POST['Member']
    ob=Member.objects.filter(CAMP=coordinator.CAMP,name__icontains=name)
    return render (request,'coordinator/manage member.html', {"val": ob})



##########  MISSING ASSET  ##########

@login_required(login_url='/')
def coordinator_register_missing_asset(request):
    login_id = request.session.get('lid')
    coordinator = CampCoordinator.objects.get(LOGIN_id=login_id)
    names = Member.objects.filter(CAMP=coordinator.CAMP)
    return render(request,'coordinator/register missing asset.html',{'names':names})


@login_required(login_url='/')
def coordinator_register_missing_asset_post(request):
    member = request.POST["member"]
    category = request.POST["category"]
    assetname = request.POST["assetname"]
    description = request.POST["description"]
    date = request.POST["date"]
    status = 'Pending'
    obj = Asset()
    obj.MEMBER_id = member
    obj.category = category
    obj.asset = assetname
    obj.description = description
    obj.missing_date =date
    obj.status=status
    obj.save()
    messages.success(request, 'Missing Asset Registered')
    return redirect('/coordinator_manage_missing_asset')


@login_required(login_url='/')
def coordinator_manage_missing_asset(request):
    login_id = request.session.get('lid')
    coordinator = CampCoordinator.objects.get(LOGIN_id=login_id)
    names = Member.objects.filter(CAMP=coordinator.CAMP)
    ob = Asset.objects.filter(MEMBER__CAMP=coordinator.CAMP)  
    return render(request, 'coordinator/manage asset registration.html', {'val': ob, 'names': names})


@login_required(login_url='/')
def coordinator_delete_asset_registration(request,id):
    Asset.objects.get(id=id).delete()
    messages.success(request, 'Asset Registration Deleted ')
    return redirect('/coordinator_manage_missing_asset')


@login_required(login_url='/')
def coordinator_edit_asset_registration(request,id):
    request.session["assetid"] = id
    ob = Asset.objects.get(id=id)
    return render(request, 'coordinator/edit missing asset.html', {"ob": ob})


@login_required(login_url='/')
def coordinator_edit_asset_registration_post(request):
    category = request.POST["category"]
    asset = request.POST["asset"]
    description = request.POST["description"]
    date = request.POST["date"]
    obj = Asset.objects.get(id=request.session["assetid"])
    obj.category = category
    obj.asset = asset
    obj.description = description
    obj.missing_date = date
    obj.save()
    messages.success(request, 'Asset Registration Edited')
    return redirect('/coordinator_manage_missing_asset')


@login_required(login_url='/')
def coordinator_search_asset_registration(request):
    login_id = request.session.get('lid')
    coordinator = CampCoordinator.objects.get(LOGIN_id=login_id)
    names = Member.objects.filter(CAMP=coordinator.CAMP)
    if request.method == 'POST':
        name = request.POST.get('Member', '').strip()
        if name:
            ob = Asset.objects.filter(MEMBER__name__icontains=name)
        else:
            ob = Asset.objects.none()
    else:
        ob = Asset.objects.none()
    return render(request, 'coordinator/manage asset registration.html', {
        'val': ob,
        'names': names
    })



#########  ADD AND MANAGE NEEDS  #########

@login_required(login_url='/')
def coordinator_add_needs(request):
    ob=CampCoordinator.objects.get(LOGIN=request.session["lid"])
    return render(request, 'coordinator/add needs.html',{"ob":ob})


@login_required(login_url='/')
def coordinator_add_needs_post(request):
    category = request.POST["category"]
    product = request.POST["product"]
    name = request.POST["name"]
    quantity = request.POST["quantity"]
    unit = request.POST["unit"]
    coordinator = CampCoordinator.objects.get(LOGIN_id=request.session["lid"])
    obj = Needs()
    obj.CAMP = coordinator.CAMP  
    obj.category = category
    obj.product = product
    obj.quantity = quantity
    obj.name = name
    obj.unit = unit
    obj.save()
    messages.success(request, 'Needs Added')
    return redirect('/coordinator_manage_needs')


@login_required(login_url='/')
def coordinator_manage_needs(request):
    login_id = request.session.get('lid')
    coordinator = CampCoordinator.objects.get(LOGIN_id=login_id)
    ob = Needs.objects.filter(CAMP=coordinator.CAMP)
    return render(request, 'coordinator/manage needs.html', {"val": ob})


@login_required(login_url='/')
def coordinator_edit_needs(request,id):
    request.session["needsid"] = id
    ob = Needs.objects.get(id=id)
    return render(request, 'coordinator/edit needs.html', {"ob": ob})


@login_required(login_url='/')
def coordinator_edit_needs_post(request):
    quantity = request.POST["quantity"]
    unit = request.POST["unit"]
    obj = Needs.objects.get(id=request.session["needsid"])
    obj.quantity = quantity
    obj.unit = unit
    obj.save()
    messages.success(request, 'Needs Edited')
    return redirect('/coordinator_manage_needs')


@login_required(login_url='/')
def coordinator_delete_needs(request,id):
    Needs.objects.get(id=id).delete()
    messages.success(request, 'Needs Deleted')
    return redirect('/coordinator_manage_needs')


@login_required(login_url='/')
def coordinator_search_needs(request):
    login_id = request.session.get('lid')
    coordinator = CampCoordinator.objects.get(LOGIN_id=login_id)
    product = request.POST['product']
    ob = Needs.objects.filter(CAMP=coordinator.CAMP, product__icontains=product)
    return render(request, 'coordinator/manage needs.html', {"val": ob})



##########  ADD AND MANAGE VOLUNTEER  ##########

@login_required(login_url='/')
def coordinator_volunteer_registration(request):
    return render(request,'coordinator/register volunteer.html')


@login_required(login_url='/')
def coordinator_volunteer_registration_post(request):
    coid = CampCoordinator.objects.get(LOGIN=request.session['lid'])
    name = request.POST["name"]
    gender = request.POST["gender"]
    dob = request.POST["dob"]
    contactno = request.POST["contactno"]
    email = request.POST["email"]
    district = request.POST["district"]
    city = request.POST["city"]
    pin = request.POST["pin"]
    aadhaar_number = request.POST["aadhaar_number"]
    username = request.POST["username"]
    password = request.POST["password"]
    photo = request.FILES["photo"]
    if Volunteer.objects.filter(contact_no=contactno).exists():
        messages.error(request, 'Contact number already exists!')
        return redirect('/coordinator_volunteer_registration')
    if Volunteer.objects.filter(email=email).exists():
        messages.error(request, 'Email already exists!')
        return redirect('/coordinator_volunteer_registration')
    if Volunteer.objects.filter(aadhaar_number=aadhaar_number).exists():
        messages.error(request, 'Aadhaar number already exists!')
        return redirect('/coordinator_volunteer_registration')
    if Login.objects.filter(username=username).exists():
        messages.error(request, 'Username already exists!')
        return redirect('/coordinator_volunteer_registration')
    fs = FileSystemStorage()
    fsave = fs.save(photo.name, photo)
    ob = Login()
    ob.username = username
    ob.password = password
    ob.type = "Volunteer"
    ob.save()
    obj = Volunteer()
    obj.LOGIN = ob
    obj.name = name
    obj.gender = gender
    obj.dob = dob
    obj.contact_no = contactno
    obj.email = email
    obj.district = district
    obj.city = city
    obj.pin = pin
    obj.aadhaar_number = aadhaar_number
    obj.photo = fsave
    obj.CAMP = coid.CAMP
    obj.save()
    messages.success(request, 'Volunteer Registered')
    return redirect('/coordinator_manage_volunteer')


@login_required(login_url='/')
def coordinator_manage_volunteer(request):
    coid = CampCoordinator.objects.filter(LOGIN=request.session['lid']).first()
    volunteers = Volunteer.objects.filter(LOGIN__type='Volunteer',CAMP=coid.CAMP) if coid else []
    return render(request, 'coordinator/manage volunteer.html', {"val": volunteers})


@login_required(login_url='/')
def coordinator_search_volunteer(request):
    coid = CampCoordinator.objects.get(LOGIN=request.session['lid'])
    name = request.POST.get('volunteername', '')
    volunteers = Volunteer.objects.filter(CAMP=coid.CAMP, name__icontains=name)
    return render(request, 'coordinator/manage volunteer.html', {"val": volunteers})


@login_required(login_url='/')
def coordinator_edit_volunteer(request,id):
    request.session["volunteerid"] = id
    ob = Volunteer.objects.get(id=id)
    return render(request, 'coordinator/edit volunteer.html', {"ob": ob})


@login_required(login_url='/')
def coordinator_edit_volunteer_post(request):
    name = request.POST["name"]
    gender = request.POST["gender"]
    dob = request.POST["dob"]
    contactno = request.POST["contactno"]
    email = request.POST["email"]
    district = request.POST["district"]
    city = request.POST["city"]
    pin = request.POST["pin"]
    aadhaar_number = request.POST["aadhaar_number"]
    obj = Volunteer.objects.get(id=request.session["volunteerid"])
    if Volunteer.objects.filter(contact_no=contactno).exclude(id=obj.id).exists():
        messages.error(request, 'Contact number already exists!')
        return redirect(f'/coordinator_edit_volunteer/{obj.id}')
    if Volunteer.objects.filter(email=email).exclude(id=obj.id).exists():
        messages.error(request, 'Email already exists!')
        return redirect(f'/coordinator_edit_volunteer/{obj.id}')
    if Volunteer.objects.filter(aadhaar_number=aadhaar_number).exclude(id=obj.id).exists():
        messages.error(request, 'Aadhaar number already exists!')
        return redirect(f'/coordinator_edit_volunteer/{obj.id}')
    obj.name = name
    obj.gender = gender
    obj.dob = dob
    obj.contact_no = contactno
    obj.email = email
    obj.district = district
    obj.city = city
    obj.pin = pin
    obj.aadhaar_number = aadhaar_number
    obj.save()
    messages.success(request, 'Volunteer Edited')
    return redirect('/coordinator_manage_volunteer')


@login_required(login_url='/')
def coordinator_delete_volunteer(request, id):
    if Volunteer.objects.filter(id=id).exists():
        volunteer = Volunteer.objects.get(id=id)
        if volunteer.photo:
            file_path = os.path.join(settings.MEDIA_ROOT, volunteer.photo.name)
            if os.path.exists(file_path):
                os.remove(file_path)
        volunteer.delete()
        messages.success(request, 'Volunteer Deleted')
    else:
        messages.error(request, 'Volunteer not found')
    return redirect('/coordinator_manage_volunteer')



##########  VERIFY VOLUNTEER  ##########

@login_required(login_url='/')
def coordinator_verify_volunteer(request):
    coid = CampCoordinator.objects.filter(LOGIN=request.session['lid']).first()
    obb = Volunteer.objects.filter(LOGIN__type='VolPending', CAMP=coid.CAMP)
    return render(request, 'coordinator/verify volunteer.html', {"val": obb})

@login_required(login_url='/')
def accept_vol(request, id):
    try:
        login = Login.objects.get(id=id)
        public_user = Public.objects.get(LOGIN=login)
        login.type = 'Volunteer'
        login.save()
        subject = 'Volunteer Application Accepted'
        message = f'Dear {public_user.name},\n\nYour volunteer application has been accepted. Welcome to the team!\n\nBest regards,\nThe Coordinator Team'
        from_email = settings.EMAIL_HOST_USER
        recipient_list = [public_user.email]
        send_mail(subject, message, from_email, recipient_list, fail_silently=False)
        public_user.delete()
        messages.success(request, "Volunteer accepted successfully and email sent!")
    except Exception as e:
        messages.error(request, f"Error: {str(e)}")
    return redirect('/coordinator_verify_volunteer')



@login_required(login_url='/')
def reject_vol(request, id):
    try:
        login = Login.objects.get(id=id)
        volunteer = Volunteer.objects.get(LOGIN=login)
        public_user = Public.objects.get(LOGIN=login)
        volunteer.delete()
        login.type = 'Public'
        login.save()
        subject = 'Volunteer Application Rejected'
        message = f'Dear {public_user.name},\n\nWe regret to inform you that your volunteer application has been rejected.\n\nBest regards,\nThe Coordinator Team'
        from_email = settings.EMAIL_HOST_USER
        recipient_list = [public_user.email]
        send_mail(subject, message, from_email, recipient_list, fail_silently=False)
        messages.success(request, "Volunteer rejected successfully and email sent!")
    except Exception as e:
        messages.error(request, f"Error: {str(e)}")
    return redirect('/coordinator_verify_volunteer')



##########  ASSIGN TASK  ##########

@login_required(login_url='/')
def coordinator_assign_task(request):
    coid = CampCoordinator.objects.filter(LOGIN=request.session['lid']).first()
    volunteers = Volunteer.objects.filter(LOGIN__type='Volunteer', CAMP=coid.CAMP) if coid else []
    return render(request, 'coordinator/assign task.html', {"val": volunteers})


@login_required(login_url='/')
def coordinator_task_search_volunteer(request):
    coid = CampCoordinator.objects.get(LOGIN=request.session['lid'])
    name = request.POST.get('volunteername', '')
    volunteers = Volunteer.objects.filter(LOGIN__type='Volunteer', CAMP=coid.CAMP, name__icontains=name)
    return render(request, 'coordinator/assign task.html', {"val": volunteers})


@login_required(login_url='/')
def coordinator_task_select_volunteer(request, id):
    request.session["volunteerid"] = id
    volunteer = Volunteer.objects.get(id=id)
    tasks = Task.objects.filter(VOLUNTEER=volunteer)
    reversed_tasks = tasks[::-1]  
    return render(request, 'coordinator/view task.html', {"ob": volunteer, "tasks": reversed_tasks})


@login_required(login_url='/')
def coordinator_delete_task(request,id):
    Task.objects.get(id=id).delete()
    messages.success(request, 'Task Deleted')
    return redirect('/coordinator_task_select_volunteer/'+str(request.session["volunteerid"]))


@login_required(login_url='/')
def coordinator_add_task_post(request):
    task = request.POST["task"]
    volunteer = Volunteer.objects.get(id=request.session["volunteerid"])
    obj = Task()
    obj.VOLUNTEER = volunteer
    obj.task = task
    obj.save()
    messages.success(request, 'Task Added')
    return redirect('/coordinator_task_select_volunteer/'+str(request.session["volunteerid"]))



##########  VIEW NOTIFICATION  ##########

@login_required(login_url='/')
def coordinator_view_notification(request):
    ob = Notification.objects.all().order_by('-posted_date', '-posted_time')
    return render (request,'coordinator/view notification.html', {"val": ob})


@login_required(login_url='/')
def coordinator_search_notification(request):
    date = request.POST['date']
    ob = Notification.objects.filter(posted_date__icontains=date)
    return render(request,'coordinator/view notification.html', {"val": ob})





##################################################  EMERGENCY TEAM  ##################################################

@login_required(login_url='/')
def ert_dashboard(request):
    user_id = request.session.get('lid')
    try:
        emergency_team = EmergencyTeam.objects.get(LOGIN__id=user_id)
        total_pending_request = EmergencyRequest.objects.filter(EMERGENCY_TEAM=emergency_team, status='Pending').count()
        total_resolved_request = EmergencyRequest.objects.filter(EMERGENCY_TEAM=emergency_team, status='Resolved').count()
        total_ontheway_request = EmergencyRequest.objects.filter(EMERGENCY_TEAM=emergency_team, status='On The Way').count()
    except EmergencyTeam.DoesNotExist:
        total_pending_request = 0
        total_resolved_request = 0
        total_ontheway_request = 0
    context = {
        'total_camp': Camp.objects.count(),
        'total_ert': Login.objects.filter(type='ERT').count(),
        'total_pending_request': total_pending_request,
        'total_resolved_request': total_resolved_request,
        'total_ontheway_request': total_ontheway_request,
    }
    return render(request, 'emergency/dashboard.html', context)



##########  VIEW CAMP  ##########

@login_required(login_url='/')
def ert_view_camp(request):
    camps = Camp.objects.annotate(
        member_count=Count('member'),
        occupancy_rate=ExpressionWrapper(
            (F('member_count') * 100.0) / F('capacity'),
            output_field=FloatField()
        )
    )
    camp_data = []
    for camp in camps:
        try:
            camp_coordinator = camp.campcoordinator 
        except CampCoordinator.DoesNotExist:
            camp_coordinator = None 

        camp_data.append({
            'camp': camp,
            'coordinator': camp_coordinator
        })
    return render(request, 'emergency/view camp.html', {'camp_data': camp_data})



@login_required(login_url='/')
def ert_search_camp(request):
    district = request.POST.get('district', '')
    camps = Camp.objects.filter(district__icontains=district).annotate(
        member_count=Count('member'),
        occupancy_rate=ExpressionWrapper(
            (F('member_count') * 100) / F('capacity'),
            output_field=FloatField()
        )
    )
    camp_data = []
    for camp in camps:
        try:
            camp_coordinator = camp.campcoordinator  
        except CampCoordinator.DoesNotExist:
            camp_coordinator = None  

        camp_data.append({
            'camp': camp,
            'coordinator': camp_coordinator
        })
    return render(request, 'emergency/view camp.html', {'camp_data': camp_data})




##########  VIEW NOTIFICATION  ##########

@login_required(login_url='/')
def ert_view_notification(request):
    ob = Notification.objects.all().order_by('-posted_date', '-posted_time')
    return render (request,'emergency/view notification.html', {"val": ob})


@login_required(login_url='/')
def ert_search_notification(request):
    date = request.POST['date']
    ob = Notification.objects.filter(posted_date__icontains=date)
    return render(request,'emergency/view notification.html', {"val": ob})


@login_required(login_url='/')
def ert_view_emergency_request(request):
    ob = EmergencyRequest.objects.filter(EMERGENCY_TEAM__LOGIN_id=request.session['lid']).order_by('-posted_date', '-posted_time')
    return render(request, 'emergency/emergency request.html', {"val": ob})

@login_required(login_url='/')
def ert_popup_emergency_request(request):
    if request.headers.get('x-requested-with') == 'XMLHttpRequest':
        ob = EmergencyRequest.objects.filter(EMERGENCY_TEAM__LOGIN_id=request.session['lid']).order_by('-posted_date', '-posted_time')
        data = [{
            'id': req.id,
            'name': req.PUBLIC.name,
            'photo_url': req.PUBLIC.photo.url,
            'city': req.PUBLIC.city,
            'district': req.PUBLIC.district,
            'pin': req.PUBLIC.pin,
            'email': req.PUBLIC.email,
            'contact_no': req.PUBLIC.contact_no,
            'request': req.request,
            'posted_date': req.posted_date,
            'posted_time': req.posted_time,
            'status': req.status
        } for req in ob]
        return JsonResponse(data, safe=False)
    else:
        # Handle initial page load
        return render(request, 'emergency/emergency request.html')


@login_required(login_url='/')
def ert_search_emergency_request(request):
    status = request.POST['status'] 
    ob = EmergencyRequest.objects.filter(status__icontains=status)
    return render (request,'emergency/emergency request.html',{'val':ob})

@login_required(login_url='/')
def ert_select_emergency_request(request,id):
    request.session["emergencyid"]=id
    ob=EmergencyRequest.objects.get(id=id)
    return render(request, 'emergency/select emergency request.html',{"ob":ob})


@login_required(login_url='/')
def ert_status_emergency_post(request):
    status=request.POST["status"]
    obj = EmergencyRequest.objects.get(id=request.session["emergencyid"])
    obj.status=status
    obj.save()
    messages.success(request, 'Update Status')
    return redirect('/ert_view_emergency_request')

###############################################################################################################
##################################################  FLUTTER  ##################################################
###############################################################################################################


def logincode(request):
    print(request.POST)
    un = request.POST['username']
    pwd = request.POST['password']
    print(un, pwd)
    try:
        ob = Login.objects.get(username=un, password=pwd)
        if ob is None:
            data = {"task": "invalid"}
        else:
            print("in user function")
            data = {"task": "valid", "lid": ob.id,"type":ob.type}
        r = json.dumps(data)
        print(r)
        return HttpResponse(r)
    except:
        data = {"task": "invalid"}
        r = json.dumps(data)
        print(r)
        return HttpResponse(r)



def public_registration(request):
    if request.method == 'POST':
        name = request.POST["name"]
        gender = request.POST["gender"]
        dob = request.POST["dob"]
        contactno = request.POST["contactno"]
        email = request.POST["email"]
        district = request.POST["district"]
        city = request.POST["city"]
        pin = request.POST["pin"]
        username = request.POST["username"]
        password = request.POST["password"]
        aadhaar_number = request.POST["aadhaar"] 
        photo = request.FILES["image"]
        if Login.objects.filter(username=username).exists():
            return JsonResponse({"status": "error", "message": "Username already exists"})
        if Public.objects.filter(email=email).exists():
            return JsonResponse({"status": "error", "message": "Email already exists"})
        if Public.objects.filter(contact_no=contactno).exists():
            return JsonResponse({"status": "error", "message": "Contact number already exists"})
        if Public.objects.filter(aadhaar_number=aadhaar_number).exists():
            return JsonResponse({"status": "error", "message": "Aadhaar number already exists"})
        fs = FileSystemStorage()
        fsave = fs.save(photo.name, photo)
        login_obj = Login(username=username, password=password, type="Public")
        login_obj.save()
        public_obj = Public(
            LOGIN=login_obj,
            name=name,
            gender=gender,
            dob=dob,
            contact_no=contactno,
            email=email,
            district=district,
            city=city,
            pin=pin,
            aadhaar_number=aadhaar_number,  
            photo=fsave
        )
        public_obj.save()
        messages.success(request, 'Volunteer Registered')
        return JsonResponse({"status": "ok"})
    return JsonResponse({"status": "error", "message": "Invalid request method"})



def verify_current_password(request):
    if request.method == 'POST':
        id = request.POST['id']
        current_password = request.POST['current_password']
        if Login.objects.filter(id=id, password=current_password).exists():
            return JsonResponse({"status": "ok"})
        else:
            return JsonResponse({"status": "error", "message": "Current password is incorrect"})
    return JsonResponse({"status": "error", "message": "Invalid request method"})



def changepassword(request):
    if request.method == 'POST':
        id = request.POST['id']
        new_password = request.POST['new_password']
        confirm_password = request.POST['confirm_password']
        if new_password == confirm_password:
            ob = Login.objects.get(id=id)
            ob.password = new_password
            ob.save()
            return JsonResponse({"status": "ok"})
        else:
            return JsonResponse({"status": "error", "message": "New password and confirm password do not match"})
    return JsonResponse({"status": "error", "message": "Invalid request method"})



def view_notification(request):
    ob=Notification.objects.all()
    print(ob,"HHHHHHHHHHHHHHH")
    mdata=[]
    for i in ob:
        data={'title':i.title,'notification':i.notification,'posted_date':i.posted_date,'posted_time':i.posted_time,'id':i.id}
        mdata.append(data)
        print(mdata)
    return JsonResponse({"status":"ok","data":mdata})





##################################################  PUBLIC  ##################################################


def public_view_needs(request):
    ob=Needs.objects.all()
    print(ob,"HHHHHHHHHHHHHHH")
    mdata=[]
    for i in ob:
        data={'CAMP':i.CAMP.camp_name,'category':i.category,'product':i.product,'quantity':str(i.quantity),'name':i.name,'unit':i.unit,'added_on':i.added_on,'id':i.id}
        mdata.append(data)
        print(mdata)
    return JsonResponse({"status":"ok","data":mdata})



def public_donate_goods(request):
    lid=request.POST['lid']
    category=request.POST["category"]
    product=request.POST["product"]
    name=request.POST["name"]
    quantity = request.POST["quantity"]
    unit=request.POST["unit"]
    obj=Goods()
    obj.PUBLIC=Public.objects.get(LOGIN_id=lid)
    obj.category=category
    obj.product=product
    obj.name=name
    obj.quantity=quantity
    obj.unit=unit
    obj.status="Pending"
    obj.save()
    return JsonResponse({"status":"ok"})



def public_view_donations(request):
    lid = request.GET.get('lid')
    if lid is None:
        return JsonResponse({"status": "error", "message": "Missing lid parameter"}, status=400)
    ob = Goods.objects.filter(PUBLIC__LOGIN_id=lid)
    mdata = []
    for i in ob:
        data = {
            'id': i.id, 
            'category': i.category,
            'product': i.product,
            'name': i.name,
            'quantity': i.quantity,
            'donated_on': str(i.donated_on),
            'status': i.status,
            'volunteer_name': i.VOLENTEER.name if i.VOLENTEER else 'No Volunteer Assigned',
            'volunteer_phone': i.VOLENTEER.contact_no if i.VOLENTEER else 'No Volunteer Assigned'
        }
        mdata.append(data)
    return JsonResponse({"status": "ok", "data": mdata})



def delete_donation(request):
    id = request.GET.get('id') 
    if id is None:
        return JsonResponse({"status": "error", "message": "Missing id parameter"}, status=400)
    try:
        donation = Goods.objects.get(id=id)
        donation.delete()
        return JsonResponse({"status": "ok", "message": "Donation deleted successfully"})
    except Goods.DoesNotExist:
        return JsonResponse({"status": "error", "message": "Donation not found"}, status=404)
    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)}, status=500)



def public_vol_registration(request):
    try:
        login_id = request.POST['login_id']
        camp_id = request.POST['camp_id']
        public = Public.objects.get(LOGIN_id=login_id)
        camp = Camp.objects.get(id=camp_id)
        login = public.LOGIN
        login.type = 'VolPending'
        login.save()
        Volunteer.objects.create(
            CAMP=camp,
            LOGIN=login,
            name=public.name,
            gender=public.gender,
            dob=public.dob,
            district=public.district,
            city=public.city,
            pin=public.pin,
            email=public.email,
            aadhaar_number = public.aadhaar_number,
            contact_no=public.contact_no,
            photo=public.photo
        )
        return JsonResponse({"status": "ok"})
    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)})



def get_camps(request):
    ob = Camp.objects.all()
    mdata = []
    for i in ob:
        data = {'camp_name': i.camp_name,'id': i.id}
        mdata.append(data)
        print(mdata)
    return JsonResponse({"status": "ok", "data": mdata})



def public_pay_donation(request):
    lid = request.POST['lid']
    amount = request.POST['amount']
    obj = Payment()
    obj.PUBLIC = Public.objects.get(LOGIN_id=lid)
    obj.amount = amount 
    obj.save()
    return JsonResponse({"status": "ok"})



def public_view_payments(request):
    lid = request.GET.get('lid')
    if lid is None:
        return JsonResponse({"status": "error", "message": "Missing lid parameter"}, status=400)
    ob = Payment.objects.filter(PUBLIC__LOGIN_id=lid)
    mdata = []
    for i in ob:
        data = {
            'id': i.id, 
            'amount': i.amount,
            'payment_date': str(i.payment_date),
            'payment_time': str(i.payment_time)
        }
        mdata.append(data)
    return JsonResponse({"status": "ok", "data": mdata})


def public_view_emergency_request(request):
    lid = request.GET.get('lid')
    if lid is None:
        return JsonResponse({"status": "error", "message": "Missing lid parameter"}, status=400)
    ob = EmergencyRequest.objects.filter(PUBLIC__LOGIN_id=lid)
    mdata = []

    for i in ob:
        data = {
            'id': i.id,
            'request': i.request,
            'status': i.status,
            'posted_date': str(i.posted_date),
            'posted_time': str(i.posted_time),
            'updated_date': str(i.updated_date),
            'updated_time': str(i.updated_time),
            'latitude': i.latitude,
            'longitude': i.longitude,
        }
        mdata.append(data)

    return JsonResponse({"status": "ok", "data": mdata})







def public_view_profile(request):
    lid = request.POST.get('lid', None)
    if not lid:
        return JsonResponse({"status": "error", "message": "Missing login ID"})
    try:
        ob = Public.objects.filter(LOGIN_id=lid)
        if not ob.exists():
            return JsonResponse({"status": "error", "message": "No user found"})
        mdata = []
        for i in ob:
            login_instance = i.LOGIN 
            data = {
                'name': i.name,
                'gender': i.gender,
                'dob': str(i.dob),
                'district': i.district,
                'city': i.city,
                'pin': str(i.pin),
                'email': i.email,
                'contact_no': str(i.contact_no),
                'photo': i.photo.url if i.photo else "",
                'id': str(i.id),
                'aadhaar_number': str(i.aadhaar_number),
                'joined_date': str(i.joined_date),
                'login_type': login_instance.type  
            }
            mdata.append(data)
        return JsonResponse({"status": "ok", "data": mdata})
    except Exception as e:
        return JsonResponse({"status": "error", "message": str(e)})
    


def public_edit_profile(request):
    print(request.POST, "++++++++++++++++=================+++++++++++++++=")
    lid = request.POST.get('lid', None)
    name = request.POST.get('name', None)
    gender = request.POST.get('gender', None)
    dob = request.POST.get('dob', None)
    district = request.POST.get('district', None)
    city = request.POST.get('city', None)
    pin = request.POST.get('pin', None)
    email = request.POST.get('email', None)
    contact_no = request.POST.get('contact_no', None)
    aadhaar_number = request.POST.get('aadhaar_number', None)
    if Public.objects.filter(email=email).exclude(LOGIN_id=lid).exists():
        return JsonResponse({'status': 'error', 'message': 'Email already exists'})
    if Public.objects.filter(contact_no=contact_no).exclude(LOGIN_id=lid).exists():
        return JsonResponse({'status': 'error', 'message': 'Contact number already exists'})
    if Public.objects.filter(aadhaar_number=aadhaar_number).exclude(LOGIN_id=lid).exists():
        return JsonResponse({'status': 'error', 'message': 'Aadhaar number already exists'})
    p = Public.objects.get(LOGIN_id=lid)
    if 'photo' in request.FILES:
        photo = request.FILES['photo']
        fs = FileSystemStorage()
        fp = fs.save(photo.name, photo)
        p.photo = fp
        p.save()
    p.name = name
    p.gender = gender
    p.dob = dob
    p.district = district
    p.city = city
    p.pin = pin
    p.email = email
    p.contact_no = contact_no
    p.aadhaar_number = aadhaar_number
    p.save()
    return JsonResponse({'status': 'ok'})




##################################################  VOLUNTEER  ##################################################


def volunteer_view_needs(request):
    lid = request.GET.get('lid') 
    volunteer = Volunteer.objects.get(LOGIN_id=lid)
    ob = Needs.objects.filter(CAMP=volunteer.CAMP)
    mdata = []
    for i in ob:
        data = {
            'name': i.name,
            'unit': i.unit,
            'category': i.category,
            'product': i.product,
            'quantity': i.quantity,
            'added_on': i.added_on.strftime('%Y-%m-%d %H:%M:%S'), 
            'id': i.id,
            'CAMP': i.CAMP.camp_name if i.CAMP.camp_name else "Unknown Camp"
        }
        mdata.append(data)
    return JsonResponse({"status": "ok", "data": mdata})



def vol_view_goods(request):
    goods = Goods.objects.filter(status='Pending')   
    mdata = []
    for item in goods:
        data = {
            'id': item.id, 
            'category': item.category,
            'product': item.product,
            'name': item.name,
            'quantity': item.quantity,
            'donated_on': item.donated_on.strftime('%Y-%m-%d %H:%M:%S'),
            'status': item.status,
            'volunteer_name': item.VOLENTEER.name if item.VOLENTEER else 'No Volunteer Assigned',
            'volunteer_phone': item.VOLENTEER.contact_no if item.VOLENTEER else 'No Volunteer Assigned'
        }
        mdata.append(data)
    return JsonResponse({"status": "ok", "data": mdata})



def update_pickup(request):
    print(request.POST,'++++++++++++==================')
    gid = request.POST['gid']
    lid = request.POST['lid']
    goods = Goods.objects.get(id=gid)
    goods.VOLENTEER = Volunteer.objects.get(LOGIN_id=lid)
    goods.status = 'Ready for pickup' 
    goods.save()
    return JsonResponse({"status": "ok"})



def vol_view_pickup(request):
    lid = request.GET.get('lid')
    ob = Goods.objects.filter(VOLENTEER__LOGIN_id=lid, status='Ready for pickup')
    mdata = []
    for i in ob:
        data = {
            'id': i.id,
            'category': i.category,
            'product': i.product,
            'name': i.name,
            'quantity': i.quantity,
            'donated_on': i.donated_on.strftime('%Y-%m-%d %H:%M:%S'),
            'status': i.status,
            'public_name': i.PUBLIC.name,
            'public_phone': i.PUBLIC.contact_no
        }
        mdata.append(data)
    return JsonResponse({"status": "ok", "data": mdata})



def vol_cancel_pickup(request):
    gid = request.POST.get('gid')
    try:
        goods = Goods.objects.get(id=gid)
        goods.VOLENTEER = None
        goods.status = 'Pending'
        goods.save()
        return JsonResponse({"status": "ok"})
    except Goods.DoesNotExist:
        return JsonResponse({"status": "error", "message": "Goods not found"})
    


def vol_collected_goods(request):
    gid = request.POST['gid']
    goods = Goods.objects.get(id=gid)
    goods.status = 'Donated'
    goods.save()

    ob=Stock()
    ob.CAMP_id=goods.VOLENTEER.CAMP.id
    ob.category=goods.category
    ob.product=goods.product
    ob.name=goods.name
    ob.quantity=goods.quantity 
    ob.unit=goods.unit 
    ob.donated=goods.PUBLIC.name
    ob.save()
    return JsonResponse({"status": "ok"})



def vol_show_completed_pickup(request):
    lid = request.POST.get('lid')
    ob = Goods.objects.filter(VOLENTEER__LOGIN_id=lid, status='Donated')
    mdata = []
    for i in ob:
        data = {
            'id': i.id,
            'category': i.category,
            'product': i.product,
            'name': i.name,
            'quantity': i.quantity,
            'donated_on': i.donated_on.strftime('%Y-%m-%d %H:%M:%S'),
            'public_name': i.PUBLIC.name,
            'public_phone': i.PUBLIC.contact_no
        }
        mdata.append(data)
    return JsonResponse({"status": "ok", "data": mdata})



def volunteer_view_task(request):
    lid = request.GET.get('lid')
    if lid is None:
        return JsonResponse({"status": "error", "message": "Missing lid parameter"}, status=400)

    ob = Task.objects.filter(VOLUNTEER__LOGIN_id=lid)
    mdata = []
    for i in ob:
        data = {
            'id': i.id,
            'task': i.task,
            'assigned_on': str(i.posted_date),
            'status': i.status
        }
        mdata.append(data)
    return JsonResponse({"status": "ok", "data": mdata})



def toggle_status_old(request):
    tid = request.POST.get('tid')
    if tid is None:
        return JsonResponse({"status": "error", "message": "Missing tid parameter"}, status=400)
    try:
        ob = Task.objects.get(id=tid)
        ob.status = '0' if ob.status == '1' else '1'
        ob.save()
        return JsonResponse({"status": "ok", "new_status": ob.status})
    except Task.DoesNotExist:
        return JsonResponse({"status": "error", "message": "Task not found"}, status=404)



def toggle_status(request):
    tid = request.POST.get('tid')
    if tid is None:
        return JsonResponse({"status": "error", "message": "Missing tid parameter"}, status=400)
    try:
        ob = Task.objects.get(id=tid)
        ob.status = '1' if ob.status == '0' else '0'
        ob.save()
        return JsonResponse({"status": "ok", "new_status": ob.status})
    except Task.DoesNotExist:
        return JsonResponse({"status": "error", "message": "Task not found"}, status=404)



def volunteer_view_profile(request):
    lid = request.POST.get('lid') 
    print(lid,"+++++++++++++")
    i = Volunteer.objects.get(LOGIN=lid)
    data = [{
        'name': i.name,
        'gender': i.gender,
        'dob': str(i.dob),
        'district': i.district,
        'city': i.city,
        'pin': str(i.pin),
        'email': i.email,
        'contact_no': str(i.contact_no),
        'photo': i.photo.url if i.photo else "",
        'aadhaar_number': str(i.aadhaar_number),
        'joined_date': str(i.posted_date),
        'id': str(i.id)
        }]
    print(data)
    return JsonResponse({"status": "ok", "data": data})



def volunteer_edit_profile(request):
    print(request.POST, "++++++++++++++++=================+++++++++++++++=")
    lid = request.POST.get('lid', None)
    name = request.POST.get('name', None)
    gender = request.POST.get('gender', None)
    dob = request.POST.get('dob', None)
    district = request.POST.get('district', None)
    city = request.POST.get('city', None)
    pin = request.POST.get('pin', None)
    email = request.POST.get('email', None)
    contact_no = request.POST.get('contact_no', None)
    aadhaar_number = request.POST.get('aadhaar_number', None)
    if Volunteer.objects.filter(email=email).exclude(LOGIN_id=lid).exists():
        return JsonResponse({'status': 'error', 'message': 'Email already exists'})
    if Volunteer.objects.filter(contact_no=contact_no).exclude(LOGIN_id=lid).exists():
        return JsonResponse({'status': 'error', 'message': 'Contact number already exists'})
    if Volunteer.objects.filter(aadhaar_number=aadhaar_number).exclude(LOGIN_id=lid).exists():
        return JsonResponse({'status': 'error', 'message': 'Aadhaar number already exists'})
    p = Volunteer.objects.get(LOGIN_id=lid)
    if 'photo' in request.FILES:
        photo = request.FILES['photo']
        fs = FileSystemStorage()
        fp = fs.save(photo.name, photo)
        p.photo = fp
        p.save()
    p.name = name
    p.gender = gender
    p.dob = dob
    p.district = district
    p.city = city
    p.pin = pin
    p.email = email
    p.contact_no = contact_no
    p.aadhaar_number = aadhaar_number
    p.save()
    return JsonResponse({'status': 'ok'})




def public_send_complaint(request):
    lid = request.POST['lid']
    complaint = request.POST['complaint']
    obj=Complaint()
    obj.PUBLIC=Public.objects.get(LOGIN_id=lid)
    obj.complaint=complaint
    obj.status="Pending"
    obj.reply="Not Replied"
    obj.save()
    return JsonResponse({"status":"ok"})



def updatelocation(request):
    lid = request.POST['lid']
    lati = request.POST['lat']
    loni = request.POST['lon']
    print(lati,loni,"kkkkkkkkkkkkkkk")
    return JsonResponse({"status":"ok"})




def public_view_complaints(request):
    lid = request.GET.get('lid')
    complaints = Complaint.objects.filter(PUBLIC__LOGIN_id=lid)
    mdata = []
    for item in complaints:
        data = {
            'id': item.id,
            'complaint': item.complaint,
            'status': item.status,
            'posted_on': item.posted_at.strftime('%Y-%m-%d %H:%M:%S'),  
            'reply': item.reply,
            'updated_on': item.updated_at.strftime('%Y-%m-%d %H:%M:%S')  
        }
        mdata.append(data)
    return JsonResponse({"status": "ok", "data": mdata})



def send_emergency_request(request):
    tid=request.POST['tid']
    lid=request.POST['lid']
    latitude=request.POST['latitude']
    longitude=request.POST['longitude']
    request=request.POST['request']
    obj=EmergencyRequest()
    obj.PUBLIC=Public.objects.get(LOGIN_id=lid)
    obj.EMERGENCY_TEAM=EmergencyTeam.objects.get(id=tid)
    obj.latitude=latitude
    obj.longitude=longitude
    obj.request=request
    obj.status="Pending"
    obj.save()
    return JsonResponse({"status":"ok"})






def public_delete_complaint(request):
    cid = request.POST.get('cid')
    try:
        Complaint.objects.get(id=cid).delete()
        return JsonResponse({"status": "ok"})
    except Complaint.DoesNotExist:
        return JsonResponse({"status": "error", "message": "Complaint not found"})



def public_view_emergency_team(request):
    ob = EmergencyTeam.objects.filter(LOGIN__type="ERT")
    mdata = []
    for i in ob:
        data = {'department': i.department,
                'district' : i.district,
                'city' : i.city,
                'pin' : i.pin,
                'email' : i.email,
                'contact_no' : i.contact_no,
                'joined_date' : i.joined_date,
                'id': i.id
            }
        mdata.append(data)
        print(mdata)
    return JsonResponse({"status": "ok", "data": mdata})


def vol_view_missing_asset(request):
    lid = request.POST['lid']
    print(lid)
    obx=Volunteer.objects.get(LOGIN_id=lid)
    ob = Asset.objects.filter(MEMBER__CAMP_id=obx.CAMP.id)
    mdata = []
    for i in ob:
        data = {
            'id': i.id,
            'category': i.category,
            'asset': i.asset,
            'description': i.description,
            'status': i.status,
            'missing_date': i.missing_date.strftime('%Y-%m-%d %H:%M:%S'),
            'posted_date': i.posted_date,
        }
        mdata.append(data)
    print(mdata)
    return JsonResponse({"status": "ok", "data": mdata})



def vol_lost_asset(request):
    print(request.POST,'++++++++++++==================')
    lid = request.POST['lid']
    aid = request.POST['aid']
    asset = Asset.objects.get(id=aid)
    asset.VOLENTEER = Volunteer.objects.get(LOGIN_id=lid)
    asset.status = 'Lost' 
    asset.save()
    return JsonResponse({"status": "ok"})



def vol_found_asset(request):
    print(request.POST,'++++++++++++==================')
    lid = request.POST['lid']
    aid = request.POST['aid']
    asset = Asset.objects.get(id=aid)
    asset.VOLENTEER = Volunteer.objects.get(LOGIN_id=lid)
    asset.status = 'Found' 
    asset.save()
    return JsonResponse({"status": "ok"})




####################  Group Chat  #########################33


def user_viewchat(request):
    cid = request.POST["camp_id"]
    obv=Volunteer.objects.get(LOGIN__id=cid)
    res = GroupChat.objects.filter(CAMP__id=obv.CAMP.id).order_by("id")
    l = []
    for i in res:
        if str(i.LOGIN_id) == cid:
            l.append({"id": i.id, "msg": i.message, "from": i.LOGIN_id, "date": i.date, })
        else:
            l.append({"id": i.id, "msg": i.LOGIN.username+"("+i.LOGIN.type+"): "+i.message, "from": i.LOGIN_id, "date": i.date, })
    return JsonResponse({"status":"ok",'data':l})





def user_sendchat(request):
    LOGIN_id=request.POST['lid']
    print(LOGIN_id)
    msg=request.POST['message']
    obv=Volunteer.objects.get(LOGIN__id=LOGIN_id)
    from  datetime import datetime
    c=GroupChat()
    c.LOGIN_id=LOGIN_id
    c.CAMP=obv.CAMP
    c.message=msg
    c.date=datetime.now()
    c.save()
    return JsonResponse({'status':"ok"})




def cod_view_chat(request):
    cid = request.POST["camp_id"]
    obv=Volunteer.objects.get(LOGIN__id=cid)
    res = GroupChat.objects.filter(CAMP__id=obv.CAMP.id).order_by("id")
    l = []
    for i in res:
        if str(i.LOGIN_id) == cid:
            l.append({"id": i.id, "msg": i.message, "from": i.LOGIN_id, "date": i.date, })
        else:
            l.append({"id": i.id, "msg": i.LOGIN.username+"("+i.LOGIN.type+"): "+i.message, "from": i.LOGIN_id, "date": i.date, })
    return JsonResponse({"status":"ok",'data':l})





@login_required(login_url='/')
def cod_groupchat(request):
    ob=CampCoordinator.objects.get(LOGIN_id=request.session['lid'])
    return render(request,"coordinator/group chat.html",{"cname":ob.CAMP.camp_name})





def coun_insert_chat(request,msg):
    print("===",msg)
    obc=CampCoordinator.objects.get(LOGIN_id=request.session['lid'])
    
    ob=GroupChat()
    ob.LOGIN=Login.objects.get(id=request.session['lid'])
    ob.CAMP=obc.CAMP
    ob.message=msg
    ob.date = datetime.now().strftime("%Y-%m-%d")
    ob.save()

    return JsonResponse({"task":"ok"})
    


def coun_msg(request):
    obc = CampCoordinator.objects.get(LOGIN__id=request.session['lid'])
    ob1 = GroupChat.objects.filter(CAMP__id=obc.CAMP.id)
    combined_chat = ob1
    combined_chat = combined_chat.order_by('id')
    
    res = []
    today = timezone.now().date()
    yesterday = today - timedelta(days=1)
    
    for i in combined_chat:
        message_date = i.date
        if message_date == today:
            date_label = "Today"
        elif message_date == yesterday:
            date_label = "Yesterday"
        else:
            date_label = message_date.strftime("%Y-%m-%d")
        
        sender = None
        photo_url = None
        sender_name = "Unknown"
        
        sender = Volunteer.objects.filter(LOGIN=i.LOGIN).first()
        if sender:
            photo_url = sender.photo.url if sender.photo else None
            sender_name = sender.name
        else:
            sender = CampCoordinator.objects.filter(LOGIN=i.LOGIN).first()
            if sender:
                photo_url = sender.photo.url if sender.photo else None
                sender_name = sender.name
        
        res.append({
            "from_id": i.LOGIN.id,
            "msg": i.message,
            "date": date_label,
            "time": i.time.strftime("%I:%M %p"),
            "chat_id": i.id,
            "photo_url": photo_url, 
            "sender_name": sender_name,  
        })
    
    obu = CampCoordinator.objects.get(LOGIN__id=request.session['lid'])
    return JsonResponse({"data": res, "name": obu.name, "user_lid": obu.LOGIN.id})































    












API_KEY = '1717e579aed7448b891f8f5328ca0f86'

def map_start(request):
    return render(request, 'emergency/map_start.html')

def get_predicttt(request):
    if request.method == 'POST':
        try:
            lat = float(request.POST['lat'])
            lon = float(request.POST['lon'])
            distance_str = "1000"

            # Fetch river data
            river_data = get_rivers_near_location(lat, lon)
            if "error" in river_data:
                print(river_data["error"])
            else:
                print(f"Rivers near location ({lat}, {lon}):")
                for river in river_data:
                    if isinstance(river["distance_km"], (float, int)):
                        distance_str = float(river['distance_km'])
                        break
                    else:
                        distance_str = "Distance not available"
                        break

            # Fetch elevation, soil type, and slope angle
            elevation, soil_type, slope_angle = getmaindata(float(lat), float(lon))
            print(elevation, soil_type, slope_angle, distance_str)

            if lat is None or lon is None:
                return render(request, "emergency/result.html", {"val": "invalid"})

            # Fetch current weather data
            current_weather_url = f'https://api.weatherbit.io/v2.0/current?lat={lat}&lon={lon}&key={API_KEY}'
            current_response = requests.get(current_weather_url)
            current_weather_data = current_response.json()
            print("Current Weather Data:", current_weather_data)  # Debug: Print current weather data

            # Fetch weather forecast data
            forecast_url = f'https://api.weatherbit.io/v2.0/forecast/daily?lat={lat}&lon={lon}&key={API_KEY}&days=7'
            forecast_response = requests.get(forecast_url)
            forecast_weather_data = forecast_response.json()
            print("Forecast Weather Data:", forecast_weather_data)  # Debug: Print forecast weather data

            # Fetch hourly weather data
            hourly_weather_url = f'https://api.weatherbit.io/v2.0/forecast/hourly?lat={lat}&lon={lon}&key={API_KEY}&hours=24'
            hourly_response = requests.get(hourly_weather_url)
            hourly_weather_data = hourly_response.json()
            print("Hourly Weather Data:", hourly_weather_data)  # Debug: Print hourly weather data

            # Convert timestamp_local to datetime object if it's a string
            for hour in hourly_weather_data['data']:
                if isinstance(hour['timestamp_local'], str):
                    hour['timestamp_local'] = datetime.strptime(hour['timestamp_local'], '%Y-%m-%dT%H:%M:%S')

            # Calculate today and tomorrow
            today = datetime.now().date()
            tomorrow = today + timedelta(days=1)

            # Convert wind speed from m/s to km/h
            wind_speed_kmh = current_weather_data['data'][0]['wind_spd'] * 3.6

            # Extract city, state, and country from current weather data
            city_name = current_weather_data['data'][0]['city_name']
            state_code = current_weather_data['data'][0]['state_code']  # State code (e.g., "NY")
            country_code = current_weather_data['data'][0]['country_code']  # Country code (e.g., "US")

            # Get full state name
            try:
                state = pycountry.subdivisions.get(code=f"{country_code}-{state_code}").name
            except AttributeError:
                state = state_code  # Fallback to state code if full name not found

            # Get full country name
            try:
                country = pycountry.countries.get(alpha_2=country_code).name
            except AttributeError:
                country = country_code  # Fallback to country code if full name not found

        except json.JSONDecodeError as e:
            print(e)
            return render(request, "emergency/result.html", {"val": "invalid"})

    # Load the KNN model
    knn = joblib.load(r"C:\Users\shaha\Desktop\Project\Web\app\knn-model1.joblib")

    try:
        st = [
            'Fluvisols', 'Andosols', 'Arenosols', 'Chernozem', 'Gleysols', 'Histosols',
            'Kastanozems', 'Luvisols', 'Nitisols', 'Regosols', 'Vertisols', 'Solonchaks',
            'Podzols', 'Alisols', 'Cambisols', 'Calcisols', 'Phaeozems', 'Acrisols',
            'Plinthosols', 'Clay', 'Entisols', 'Inceptisols', 'Alfisols', 'Mollisols',
            'Aridisols', 'Spodosols', 'Ultisols', 'Oxisols', 'Andisols', 'Sandy Soil',
            'Clay Soil', 'Silt Soil', 'Loamy Soil', 'Peaty Soil', 'Chalky Soil'
        ]

        try:
            row = [float(lat), float(lon), float(elevation), float(distance_str), float(slope_angle),
                   current_weather_data['data'][0]['precip'], st.index(soil_type), current_weather_data['data'][0]['rh'],
                   current_weather_data['data'][0]['rh']]  # Adjust as necessary
        except:
            row = [float(lat), float(lon), float(elevation), float(distance_str), float(slope_angle), 1,
                   st.index(soil_type), 1, 1]  # Adjust as necessary

        if len(row) != knn.n_features_in_:
            raise ValueError(f"Expected {knn.n_features_in_} features, but got {len(row)}")

        res = knn.predict([row])
        print(res, "++++++++++++++++++")

        if res[0] == 0:
            try:
                return render(request, "emergency/result.html", {
                    'status': 'ok',
                    'val': 'Non-landslide',
                    'weather_data': current_weather_data,
                    'forecast_data': forecast_weather_data,
                    'hourly_weather_data': hourly_weather_data,  # Pass hourly weather data to the template
                    'st': soil_type,
                    'river': distance_str,
                    'altitude': elevation,
                    'rainfall': current_weather_data['data'][0]['precip'],
                    'city_name': city_name,
                    'state': state,
                    'country': country,
                    'today': today,
                    'tomorrow': tomorrow,
                    'wind_speed_kmh': wind_speed_kmh
                })
            except Exception as e:
                print("Error in rendering non-landslide result:", e)
                return render(request, "emergency/result.html", {
                    'status': 'ok',
                    'val': 'Non-landslide',
                    'weather_data': current_weather_data,
                    'forecast_data': forecast_weather_data,
                    'hourly_weather_data': hourly_weather_data,  # Pass hourly weather data to the template
                    'st': soil_type,
                    'river': distance_str,
                    'altitude': elevation,
                    'rainfall': 5,
                    'city_name': "",
                    'state': "",
                    'country': "",
                    'today': today,
                    'tomorrow': tomorrow,
                    'wind_speed_kmh': wind_speed_kmh
                })
        else:
            try:
                return HttpResponse({
                    'status': 'not ok',
                    'val': 'Landslide',
                    'weather_data': current_weather_data,
                    'forecast_data': forecast_weather_data,
                    'hourly_weather_data': hourly_weather_data,  # Pass hourly weather data to the template
                    'st': soil_type,
                    'river': distance_str,
                    'altitude': elevation,
                    'rainfall': current_weather_data['data'][0]['precip'],
                    'city_name': city_name,
                    'state': state,
                    'country': country,
                    'today': today,
                    'tomorrow': tomorrow,
                    'wind_speed_kmh': wind_speed_kmh
                })
            except Exception as e:
                print("Error in rendering landslide result:", e)
                return HttpResponse({
                    'status': 'not ok',
                    'val': 'Landslide',
                    'weather_data': current_weather_data,
                    'forecast_data': forecast_weather_data,
                    'hourly_weather_data': hourly_weather_data,  # Pass hourly weather data to the template
                    'st': soil_type,
                    'river': distance_str,
                    'altitude': elevation,
                    'rainfall': 5,
                    'city_name': "",
                    'state': "",
                    'country': "",
                    'today': today,
                    'tomorrow': tomorrow,
                    'wind_speed_kmh': wind_speed_kmh
                })

    except ValueError as e:
        print("Error in prediction:", str(e))
        return JsonResponse({'error': 'Prediction failed', 'details': str(e)}, status=500)
    return JsonResponse({'status': 'not ok', 'val': 'Landslide', 'weather_data': current_weather_data})
