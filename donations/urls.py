from django.urls import path
from . import views

urlpatterns = [
    # User donation request endpoints
    path('', views.DonationRequestListView.as_view(), name='donation-request-list'),
    path('create/', views.DonationRequestCreateView.as_view(), name='donation-request-create'),
    path('<int:pk>/', views.DonationRequestDetailView.as_view(), name='donation-request-detail'),
    path('received/', views.ReceivedDonationRequestsView.as_view(), name='received-donation-requests'),
    path('<int:pk>/status/', views.DonationRequestStatusUpdateView.as_view(), name='donation-request-status-update'),
    path('stats/', views.my_donation_stats, name='donation-stats'),
    
    # Public donation endpoints
    path('listing/<int:listing_id>/', views.listing_donation_requests, name='listing-donation-requests'),
]
