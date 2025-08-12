from rest_framework import serializers
from .models import Transaction
from listings.serializers import ListingSerializer
from accounts.serializers import UserSerializer

class TransactionSerializer(serializers.ModelSerializer):
    listing_title = serializers.CharField(source='listing.title', read_only=True)
    vendor_email = serializers.CharField(source='vendor.email', read_only=True)
    consumer_email = serializers.CharField(source='consumer.email', read_only=True)
    duration_days = serializers.ReadOnlyField()
    
    class Meta:
        model = Transaction
        fields = [
            'id', 'listing', 'listing_title', 'vendor', 'vendor_email', 
            'consumer', 'consumer_email', 'start_date', 'end_date', 
            'total_price', 'status', 'is_refunded', 'payment_hold_expires',
            'created_at', 'duration_days'
        ]
        read_only_fields = ['id', 'vendor', 'created_at', 'is_refunded']

class TransactionCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transaction
        fields = ['listing', 'start_date', 'end_date']
        
    def validate(self, data):
        if data['start_date'] >= data['end_date']:
            raise serializers.ValidationError("End date must be after start date.")
        return data

class TransactionDetailSerializer(serializers.ModelSerializer):
    listing = ListingSerializer(read_only=True)
    vendor = UserSerializer(read_only=True)
    consumer = UserSerializer(read_only=True)
    duration_days = serializers.ReadOnlyField()
    
    class Meta:
        model = Transaction
        fields = [
            'id', 'listing', 'vendor', 'consumer', 'start_date', 'end_date',
            'total_price', 'status', 'is_refunded', 'payment_hold_expires',
            'created_at', 'duration_days'
        ]

class TransactionStatusUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transaction
        fields = ['status']
