from rest_framework import serializers
from .models import Dispute
from transactions.serializers import TransactionSerializer
from accounts.serializers import UserSerializer

class DisputeSerializer(serializers.ModelSerializer):
    transaction_id = serializers.IntegerField(source='transaction.id', read_only=True)
    raised_by_email = serializers.CharField(source='raised_by.email', read_only=True)
    raised_by_name = serializers.CharField(source='raised_by.full_name', read_only=True)
    resolved_by_email = serializers.CharField(source='resolved_by.email', read_only=True)
    
    class Meta:
        model = Dispute
        fields = [
            'id', 'transaction', 'transaction_id', 'raised_by', 'raised_by_email', 
            'raised_by_name', 'reason', 'status', 'created_at', 'resolved_at',
            'resolved_by', 'resolved_by_email', 'resolution_notes'
        ]
        read_only_fields = ['id', 'raised_by', 'created_at', 'resolved_at', 'resolved_by']

class DisputeCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Dispute
        fields = ['transaction', 'reason']

class DisputeDetailSerializer(serializers.ModelSerializer):
    transaction = TransactionSerializer(read_only=True)
    raised_by = UserSerializer(read_only=True)
    resolved_by = UserSerializer(read_only=True)
    
    class Meta:
        model = Dispute
        fields = [
            'id', 'transaction', 'raised_by', 'reason', 'status',
            'created_at', 'resolved_at', 'resolved_by', 'resolution_notes'
        ]

class DisputeResolveSerializer(serializers.ModelSerializer):
    class Meta:
        model = Dispute
        fields = ['status', 'resolution_notes']
        
    def validate_status(self, value):
        if value not in ['resolved', 'rejected']:
            raise serializers.ValidationError("Status must be 'resolved' or 'rejected'")
        return value
