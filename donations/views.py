from rest_framework import generics, permissions, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q
from .models import DonationRequest
from .serializers import (
    DonationRequestSerializer, DonationRequestCreateSerializer,
    DonationRequestDetailSerializer, DonationRequestStatusUpdateSerializer
)

class DonationRequestCreateView(generics.CreateAPIView):
    serializer_class = DonationRequestCreateSerializer
    permission_classes = [IsAuthenticated]
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class DonationRequestListView(generics.ListAPIView):
    serializer_class = DonationRequestSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        return DonationRequest.objects.filter(user=user).order_by('-created_at')

class DonationRequestDetailView(generics.RetrieveAPIView):
    serializer_class = DonationRequestDetailSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        return DonationRequest.objects.filter(
            Q(user=user) | Q(listing__user=user)
        )

class ReceivedDonationRequestsView(generics.ListAPIView):
    """View for donation requests received for user's listings"""
    serializer_class = DonationRequestSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        return DonationRequest.objects.filter(
            listing__user=user
        ).order_by('-created_at')

class DonationRequestStatusUpdateView(generics.UpdateAPIView):
    serializer_class = DonationRequestStatusUpdateSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        # Only listing owners can update donation request status
        user = self.request.user
        return DonationRequest.objects.filter(listing__user=user)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_donation_stats(request):
    """Get donation statistics for the authenticated user"""
    user = request.user
    
    # Requests made by user
    made_requests = DonationRequest.objects.filter(user=user)
    
    # Requests received for user's listings
    received_requests = DonationRequest.objects.filter(listing__user=user)
    
    stats = {
        'requests_made': {
            'total': made_requests.count(),
            'pending': made_requests.filter(status='pending').count(),
            'accepted': made_requests.filter(status='accepted').count(),
            'rejected': made_requests.filter(status='rejected').count(),
        },
        'requests_received': {
            'total': received_requests.count(),
            'pending': received_requests.filter(status='pending').count(),
            'accepted': received_requests.filter(status='accepted').count(),
            'rejected': received_requests.filter(status='rejected').count(),
        }
    }
    
    return Response(stats)

@api_view(['GET'])
@permission_classes([permissions.AllowAny])
def listing_donation_requests(request, listing_id):
    """Get all donation requests for a specific listing (public view)"""
    requests = DonationRequest.objects.filter(
        listing_id=listing_id, 
        status='accepted'
    ).order_by('-created_at')
    
    serializer = DonationRequestSerializer(requests, many=True)
    return Response(serializer.data)
