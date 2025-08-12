from django.urls import path
from . import views

urlpatterns = [
    # User dispute endpoints
    path('', views.DisputeListView.as_view(), name='dispute-list'),
    path('create/', views.DisputeCreateView.as_view(), name='dispute-create'),
    path('<int:pk>/', views.DisputeDetailView.as_view(), name='dispute-detail'),
    path('stats/', views.my_dispute_stats, name='dispute-stats'),
    
    # Admin dispute endpoints
    path('admin/list/', views.AdminDisputeListView.as_view(), name='admin-dispute-list'),
    path('admin/<int:pk>/', views.AdminDisputeDetailView.as_view(), name='admin-dispute-detail'),
    path('admin/<int:pk>/resolve/', views.DisputeResolveView.as_view(), name='admin-dispute-resolve'),
]
