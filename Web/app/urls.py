from django.contrib import admin
from django.urls import path
from app import views

urlpatterns = [
    # LOGIN PAGE
    path('', views.login, name='login'),
    path('login_post/', views.login_post, name='login_post'),
    path('logout/', views.logout, name='logout'),
    path('forgotpass/', views.forgotpass, name='forgotpass'),
    path('change_password/', views.change_password, name='change_password'),
    path('register_ert/', views.register_ert, name='register_ert'),
    path('register_ert_post/', views.register_ert_post, name='register_ert_post'),
    path('ert_registration_status/', views.ert_registration_status, name='ert_registration_status'),

    # ***** ADMIN *****
    path('admin_dashboard/', views.admin_dashboard, name='admin_dashboard'),

    # ADD & MANAGE CAMP
    path('admin_add_camp/', views.admin_add_camp, name='admin_add_camp'),
    path('admin_add_camp_post/', views.admin_add_camp_post, name='admin_add_camp_post'),
    path('admin_manage_camp/', views.admin_manage_camp, name='admin_manage_camp'),
    path('admin_search_camp/', views.admin_search_camp, name='admin_search_camp'),
    path('admin_edit_camp/<id>/', views.admin_edit_camp, name='admin_edit_camp'),
    path('admin_edit_camp_post/', views.admin_edit_camp_post, name='admin_edit_camp_post'),
    path('admin_delete_camp/<id>/', views.admin_delete_camp, name='admin_delete_camp'),

    # ADD & MANAGE CAMP COORDINATOR
    path('admin_add_coordinator/', views.admin_add_coordinator, name='admin_add_coordinator'),
    path('admin_add_coordinator_post/', views.admin_add_coordinator_post, name='admin_add_coordinator_post'),
    path('admin_manage_coordinator/', views.admin_manage_coordinator, name='admin_manage_coordinator'),
    path('admin_search_coordinator/', views.admin_search_coordinator, name='admin_search_coordinator'),
    path('admin_edit_coordinator/<id>/', views.admin_edit_coordinator, name='admin_edit_coordinator'),
    path('admin_edit_coordinator_post/', views.admin_edit_coordinator_post, name='admin_edit_coordinator_post'),
    path('admin_delete_coordinator/<int:id>/', views.admin_delete_coordinator, name='admin_delete_coordinator'),

    # ADD & MANAGE GUIDELINES
    path('admin_send_guideline/', views.admin_send_guideline, name='admin_send_guideline'),
    path('admin_send_guideline_post/', views.admin_send_guideline_post, name='admin_send_guideline_post'),
    path('admin_manage_guideline/', views.admin_manage_guideline, name='admin_manage_guideline'),
    path('admin_search_guideline/', views.admin_search_guideline, name='admin_search_guideline'),
    path('admin_delete_guideline/<id>/', views.admin_delete_guideline, name='admin_delete_guideline'),

    # VERIFY EMERGENCY TEAM
    path('admin_verify_ert/', views.admin_verify_ert, name='admin_verify_ert'),
    path('admin_manage_ert/', views.admin_manage_ert, name='admin_manage_ert'),
    path('admin_accept_ert/<int:id>/', views.admin_accept_ert, name='admin_accept_ert'),
    path('admin_reject_ert/<int:id>/', views.admin_reject_ert, name='admin_reject_ert'),
    path('admin_search_verify_ert/', views.admin_search_verify_ert, name='admin_search_verify_ert'),
    path('admin_search_accept_ert/', views.admin_search_accept_ert, name='admin_search_accept_ert'),
    path('admin_search_reject_ert/', views.admin_search_reject_ert, name='admin_search_reject_ert'),


    # MANAGE NOTIFICATION
    path('admin_send_notification/',views.admin_send_notification),
    path('admin_send_notification_post/',views.admin_send_notification_post),
    path('admin_manage_notification/',views.admin_manage_notification),
    path('admin_delete_notification/<id>',views.admin_delete_notification),
    path('admin_edit_notification/<id>',views.admin_edit_notification),
    path('admin_edit_notification_post/',views.admin_edit_notification_post),
    path('admin_search_notification/',views.admin_search_notification),


# # MANAGE COMPLAINT
    path('admin_view_donation/',views.admin_view_donation),


# # MANAGE COMPLAINT
    path('admin_manage_complaint/',views.admin_manage_complaint),
    path('admin_reply_complaint/<id>',views.admin_reply_complaint),
    path('admin_reply_complaint_post/',views.admin_reply_complaint_post),
    path('admin_search_complaint/',views.admin_search_complaint),




    # ***** CAMP COORDINATOR *****
    path('coordinator_dashboard/', views.coordinator_dashboard, name='coordinator_dashboard'),
    path('coordinator_profile/', views.coordinator_profile, name='coordinator_profile'),
    path('update_coordinator_profile/', views.update_coordinator_profile, name='update_coordinator_profile'),

    # ADD AND MANAGE STOCK
    path('coordinator_add_stock/', views.coordinator_add_stock, name='coordinator_add_stock'),
    path('coordinator_add_stock_post/', views.coordinator_add_stock_post, name='coordinator_add_stock_post'),
    path('coordinator_manage_stock/', views.coordinator_manage_stock, name='coordinator_manage_stock'),
    path('coordinator_detailed_stock/', views.coordinator_detailed_stock, name='coordinator_detailed_stock'),
    path('coordinator_edit_stock/<id>/', views.coordinator_edit_stock, name='coordinator_edit_stock'),
    path('coordinator_edit_stock_post/', views.coordinator_edit_stock_post, name='coordinator_edit_stock_post'),
    path('coordinator_delete_stock/<id>/', views.coordinator_delete_stock, name='coordinator_delete_stock'),
    path('coordinator_search_stock/', views.coordinator_search_stock, name='coordinator_search_stock'),


# ADD AND MANAGE MEMBER
    path('coordinator_register_member/', views.coordinator_register_member, name='coordinator_register_member'),
    path('coordinator_register_member_post/',views.coordinator_register_member_post, name='coordinator_register_member_post'),
    path('coordinator_manage_members/',views.coordinator_manage_members, name='coordinator_manage_members'),
    path('coordinator_edit_member/<id>',views.coordinator_edit_member, name='coordinator_edit_member'),
    path('coordinator_edit_member_post/',views.coordinator_edit_member_post, name='coordinator_edit_member_post'),
    path('coordinator_delete_member/<id>',views.coordinator_delete_member, name='coordinator_delete_member'),
    path('coordinator_search_member/',views.coordinator_search_member, name='coordinator_search_member'),


# # REGISTER AND MANAGE MISSING ASSET
    path('coordinator_register_missing_asset/',views.coordinator_register_missing_asset),
    path('coordinator_register_missing_asset_post/',views.coordinator_register_missing_asset_post),
    path('coordinator_manage_missing_asset/', views.coordinator_manage_missing_asset),
    path('coordinator_edit_asset_registration/<id>',views.coordinator_edit_asset_registration),
    path('coordinator_edit_asset_registration_post/', views.coordinator_edit_asset_registration_post),
    path('coordinator_delete_asset_registration/<id>',views.coordinator_delete_asset_registration),
    path('coordinator_search_asset_registration/',views.coordinator_search_asset_registration),



# ADD AND MANAGE NEEDS    
    path('coordinator_add_needs/',views.coordinator_add_needs),
    path('coordinator_add_needs_post/',views.coordinator_add_needs_post),
    path('coordinator_manage_needs/', views.coordinator_manage_needs),
    path('coordinator_edit_needs/<id>',views.coordinator_edit_needs),
    path('coordinator_edit_needs_post/', views.coordinator_edit_needs_post),
    path('coordinator_delete_needs/<id>', views.coordinator_delete_needs),
    path('coordinator_search_needs/', views.coordinator_search_needs),


# REGISTER AND MANAGE VOLUNTEER
    path('coordinator_volunteer_registration/',views.coordinator_volunteer_registration),
    path('coordinator_volunteer_registration_post/',views.coordinator_volunteer_registration_post),
    path('coordinator_manage_volunteer/',views.coordinator_manage_volunteer),
    path('coordinator_search_volunteer/',views.coordinator_search_volunteer),
    path('coordinator_edit_volunteer/<id>',views.coordinator_edit_volunteer),
    path('coordinator_edit_volunteer_post/', views.coordinator_edit_volunteer_post),
    path('coordinator_delete_volunteer/<id>', views.coordinator_delete_volunteer),

# VIEW NOTIFICATION
    path('coordinator_view_notification/', views.coordinator_view_notification),
    path('coordinator_search_notification/', views.coordinator_search_notification),


# ASSIGN TASK 

    path('coordinator_assign_task/', views.coordinator_assign_task),
    path('coordinator_task_search_volunteer/', views.coordinator_task_search_volunteer),
    path('coordinator_task_select_volunteer/<id>', views.coordinator_task_select_volunteer),
    path('coordinator_add_task_post/', views.coordinator_add_task_post),
    path('coordinator_delete_task/<id>', views.coordinator_delete_task),

    path('ert_dashboard/', views.ert_dashboard),
    path('ert_view_camp/', views.ert_view_camp),
    path('ert_search_camp/', views.ert_search_camp),
    path('ert_view_notification/', views.ert_view_notification),
    path('ert_search_notification/', views.ert_search_notification),




    path('coordinator_verify_volunteer/', views.coordinator_verify_volunteer),

      ## FLUTTER
    path('logincode', views.logincode),
    path('public_registration', views.public_registration),
    path('changepassword', views.changepassword),

    path('public_view_needs', views.public_view_needs),
    path('view_notification', views.view_notification),
    path('public_view_profile', views.public_view_profile),
    path('public_edit_profile',views.public_edit_profile),
    path('public_donate_goods',views.public_donate_goods),
    path('public_view_donations', views.public_view_donations, name='public_view_donations'),
    path('delete_donation', views.delete_donation, name='delete_donation'),


      
    path('reject_vol/<id>',views.reject_vol),
    path('accept_vol/<id>',views.accept_vol),
    path('volunteer_view_needs',views.volunteer_view_needs),
    path('/public_send_complaint',views.public_send_complaint),
    path('public_view_complaints',views.public_view_complaints),
    path('public_delete_complaint',views.public_delete_complaint),
    path('get_camps',views.get_camps, name='get_camps-for-volunteer'),

    path('public_vol_registration',views.public_vol_registration, name='public_vol_registration'),

    path('volunteer_view_profile', views.volunteer_view_profile),
    path('verify_current_password', views.verify_current_password),
    path('/volunteer_view_task', views.volunteer_view_task),
    path('/toggle_status', views.toggle_status),
    path('/toggle_status_old', views.toggle_status_old),
    path('vol_view_goods', views.vol_view_goods),
    path('update_pickup', views.update_pickup),
    path('vol_view_pickup', views.vol_view_pickup),
    path('vol_collected_goods/', views.vol_collected_goods),
    path('/vol_cancel_pickup', views.vol_cancel_pickup),
    path('volunteer_edit_profile', views.volunteer_edit_profile),
    path('vol_show_completed_pickup', views.vol_show_completed_pickup),
    path('public_view_emergency_team', views.public_view_emergency_team),
    path('send_emergency_request', views.send_emergency_request),
    path('ert_view_emergency_request/', views.ert_view_emergency_request),
    path('ert_search_emergency_request/', views.ert_search_emergency_request),
    path('ert_select_emergency_request/<id>', views.ert_select_emergency_request),
    path('ert_status_emergency_post/', views.ert_status_emergency_post),

    path('vol_view_missing_asset', views.vol_view_missing_asset),
    path('cod_groupchat/', views.cod_groupchat),
    path('vol_found_asset', views.vol_found_asset),
    path('vol_lost_asset', views.vol_lost_asset),




    path('map_start',views.map_start),
    path('get_predicttt',views.get_predicttt),
    path('public_pay_donation',views.public_pay_donation),

    path('public_view_payments', views.public_view_payments),
    path('updatelocation', views.updatelocation),
    
    path('ert_popup_emergency_request/', views.ert_popup_emergency_request),
   
    path('user_viewchat', views.user_viewchat),
    path('user_sendchat', views.user_sendchat),
    path('coun_insert_chat/<msg>', views.coun_insert_chat),
    path('coun_msg', views.coun_msg),
    path('public_view_emergency_request', views.public_view_emergency_request),

]