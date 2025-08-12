from rest_framework import generics, permissions, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from django.db.models import Avg
from .models import Review
from .serializers import (
    ReviewSerializer, ReviewCreateSerializer, 
    ReviewDetailSerializer, ReviewPublicSerializer
)

class ReviewCreateView(generics.CreateAPIView):
    serializer_class = ReviewCreateSerializer
    permission_classes = [IsAuthenticated]
    
    def perform_create(self, serializer):
        serializer.save(reviewer=self.request.user)

class ReviewListView(generics.ListAPIView):
    serializer_class = ReviewSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        return Review.objects.filter(reviewer=user).order_by('-created_at')

class ReviewDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = ReviewDetailSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Review.objects.filter(reviewer=self.request.user)

class UserReviewsReceivedView(generics.ListAPIView):
    serializer_class = ReviewPublicSerializer
    permission_classes = [permissions.AllowAny]
    
    def get_queryset(self):
        user_id = self.kwargs.get('user_id')
        return Review.objects.filter(reviewed_id=user_id).order_by('-created_at')

class MyReviewsReceivedView(generics.ListAPIView):
    serializer_class = ReviewSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Review.objects.filter(reviewed=self.request.user).order_by('-created_at')

@api_view(['GET'])
@permission_classes([permissions.AllowAny])
def user_rating_stats(request, user_id):
    """Get rating statistics for a user"""
    reviews = Review.objects.filter(reviewed_id=user_id)
    
    if not reviews.exists():
        return Response({
            'average_rating': 0,
            'total_reviews': 0,
            'rating_distribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}
        })
    
    avg_rating = reviews.aggregate(avg=Avg('rating'))['avg']
    total_reviews = reviews.count()
    
    # Rating distribution
    rating_distribution = {}
    for i in range(1, 6):
        rating_distribution[i] = reviews.filter(rating__gte=i-0.5, rating__lt=i+0.5).count()
    
    return Response({
        'average_rating': round(avg_rating, 1) if avg_rating else 0,
        'total_reviews': total_reviews,
        'rating_distribution': rating_distribution
    })

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_rating_stats(request):
    """Get rating statistics for the authenticated user"""
    user_id = request.user.id
    return user_rating_stats(request, user_id)
