from django.urls import path
from . import views

urlpatterns = [
    # User review endpoints
    path('', views.ReviewListView.as_view(), name='review-list'),
    path('create/', views.ReviewCreateView.as_view(), name='review-create'),
    path('<int:pk>/', views.ReviewDetailView.as_view(), name='review-detail'),
    path('received/', views.MyReviewsReceivedView.as_view(), name='my-reviews-received'),
    path('stats/', views.my_rating_stats, name='my-rating-stats'),
    
    # Public review endpoints
    path('user/<int:user_id>/', views.UserReviewsReceivedView.as_view(), name='user-reviews'),
    path('user/<int:user_id>/stats/', views.user_rating_stats, name='user-rating-stats'),
]
