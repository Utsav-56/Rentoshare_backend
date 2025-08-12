from django.urls import path
from . import views

urlpatterns = [
    # User KYC endpoints
    path('', views.KYCDetailView.as_view(), name='kyc-detail'),
    path('create/', views.KYCCreateView.as_view(), name='kyc-create'),
    path('public/<int:user_id>/', views.kyc_public_status, name='kyc-public-status'),
    
    # Admin KYC endpoints
    path('admin/list/', views.KYCListView.as_view(), name='admin-kyc-list'),
    path('admin/<int:pk>/status/', views.KYCStatusUpdateView.as_view(), name='admin-kyc-status-update'),
]
