from django.urls import path
from . import views

urlpatterns = [
    # User transaction endpoints
    path('', views.TransactionListView.as_view(), name='transaction-list'),
    path('create/', views.TransactionCreateView.as_view(), name='transaction-create'),
    path('<int:pk>/', views.TransactionDetailView.as_view(), name='transaction-detail'),
    path('<int:pk>/status/', views.TransactionStatusUpdateView.as_view(), name='transaction-status-update'),
    path('stats/', views.user_transaction_stats, name='transaction-stats'),
    
    # Admin transaction endpoints
    path('admin/list/', views.AdminTransactionListView.as_view(), name='admin-transaction-list'),
]
