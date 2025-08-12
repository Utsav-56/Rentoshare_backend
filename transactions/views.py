from rest_framework import generics, permissions, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from django.db.models import Q
from .models import Transaction
from .serializers import (
    TransactionSerializer, TransactionCreateSerializer, 
    TransactionDetailSerializer, TransactionStatusUpdateSerializer
)

class TransactionCreateView(generics.CreateAPIView):
    serializer_class = TransactionCreateSerializer
    permission_classes = [IsAuthenticated]
    
    def perform_create(self, serializer):
        listing = serializer.validated_data['listing']
        
        # Calculate total price
        start_date = serializer.validated_data['start_date']
        end_date = serializer.validated_data['end_date']
        days = (end_date - start_date).days
        total_price = listing.price_per_day * days if listing.price_per_day else 0
        
        serializer.save(
            consumer=self.request.user,
            vendor=listing.user,
            total_price=total_price
        )

class TransactionListView(generics.ListAPIView):
    serializer_class = TransactionSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        return Transaction.objects.filter(
            Q(vendor=user) | Q(consumer=user)
        ).order_by('-created_at')

class TransactionDetailView(generics.RetrieveAPIView):
    serializer_class = TransactionDetailSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        return Transaction.objects.filter(
            Q(vendor=user) | Q(consumer=user)
        )

class TransactionStatusUpdateView(generics.UpdateAPIView):
    serializer_class = TransactionStatusUpdateSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        return Transaction.objects.filter(vendor=user)

class AdminTransactionListView(generics.ListAPIView):
    queryset = Transaction.objects.all()
    serializer_class = TransactionSerializer
    permission_classes = [IsAdminUser]
    
    def get_queryset(self):
        queryset = super().get_queryset()
        transaction_status = self.request.query_params.get('status', None)
        if transaction_status:
            queryset = queryset.filter(status=transaction_status)
        return queryset

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_transaction_stats(request):
    """Get transaction statistics for the authenticated user"""
    user = request.user
    vendor_transactions = Transaction.objects.filter(vendor=user)
    consumer_transactions = Transaction.objects.filter(consumer=user)
    
    stats = {
        'vendor_stats': {
            'total': vendor_transactions.count(),
            'active': vendor_transactions.filter(status='active').count(),
            'completed': vendor_transactions.filter(status='completed').count(),
            'total_earnings': sum(t.total_price for t in vendor_transactions.filter(status='completed'))
        },
        'consumer_stats': {
            'total': consumer_transactions.count(),
            'active': consumer_transactions.filter(status='active').count(),
            'completed': consumer_transactions.filter(status='completed').count(),
            'total_spent': sum(t.total_price for t in consumer_transactions.filter(status='completed'))
        }
    }
    
    return Response(stats)
