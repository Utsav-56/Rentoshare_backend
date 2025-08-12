from rest_framework import generics, permissions, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from django.db.models import Q
from django.utils import timezone
from .models import Dispute
from .serializers import (
    DisputeSerializer, DisputeCreateSerializer, 
    DisputeDetailSerializer, DisputeResolveSerializer
)

class DisputeCreateView(generics.CreateAPIView):
    serializer_class = DisputeCreateSerializer
    permission_classes = [IsAuthenticated]
    
    def perform_create(self, serializer):
        serializer.save(raised_by=self.request.user)

class DisputeListView(generics.ListAPIView):
    serializer_class = DisputeSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        return Dispute.objects.filter(
            Q(raised_by=user) | 
            Q(transaction__vendor=user) | 
            Q(transaction__consumer=user)
        ).order_by('-created_at')

class DisputeDetailView(generics.RetrieveAPIView):
    serializer_class = DisputeDetailSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        return Dispute.objects.filter(
            Q(raised_by=user) | 
            Q(transaction__vendor=user) | 
            Q(transaction__consumer=user)
        )

class AdminDisputeListView(generics.ListAPIView):
    queryset = Dispute.objects.all()
    serializer_class = DisputeSerializer
    permission_classes = [IsAdminUser]
    
    def get_queryset(self):
        queryset = super().get_queryset()
        dispute_status = self.request.query_params.get('status', None)
        if dispute_status:
            queryset = queryset.filter(status=dispute_status)
        return queryset.order_by('-created_at')

class AdminDisputeDetailView(generics.RetrieveAPIView):
    queryset = Dispute.objects.all()
    serializer_class = DisputeDetailSerializer
    permission_classes = [IsAdminUser]

class DisputeResolveView(generics.UpdateAPIView):
    queryset = Dispute.objects.all()
    serializer_class = DisputeResolveSerializer
    permission_classes = [IsAdminUser]
    
    def perform_update(self, serializer):
        serializer.save(
            resolved_by=self.request.user,
            resolved_at=timezone.now()
        )

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_dispute_stats(request):
    """Get dispute statistics for the authenticated user"""
    user = request.user
    raised_disputes = Dispute.objects.filter(raised_by=user)
    involved_disputes = Dispute.objects.filter(
        Q(transaction__vendor=user) | Q(transaction__consumer=user)
    )
    
    stats = {
        'raised_by_me': {
            'total': raised_disputes.count(),
            'open': raised_disputes.filter(status='open').count(),
            'resolved': raised_disputes.filter(status='resolved').count(),
            'rejected': raised_disputes.filter(status='rejected').count(),
        },
        'involving_me': {
            'total': involved_disputes.count(),
            'open': involved_disputes.filter(status='open').count(),
            'resolved': involved_disputes.filter(status='resolved').count(),
            'rejected': involved_disputes.filter(status='rejected').count(),
        }
    }
    
    return Response(stats)
