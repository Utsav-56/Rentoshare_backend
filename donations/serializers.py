from rest_framework import serializers
from .models import DonationRequest
from listings.serializers import ListingSerializer
from accounts.serializers import UserSerializer

class DonationRequestSerializer(serializers.ModelSerializer):
    listing_title = serializers.CharField(source='listing.title', read_only=True)
    user_email = serializers.CharField(source='user.email', read_only=True)
    user_name = serializers.CharField(source='user.full_name', read_only=True)
    
    class Meta:
        model = DonationRequest
        fields = [
            'id', 'listing', 'listing_title', 'user', 'user_email', 'user_name',
            'message', 'status', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'user', 'created_at', 'updated_at']

class DonationRequestCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = DonationRequest
        fields = ['listing', 'message']

class DonationRequestDetailSerializer(serializers.ModelSerializer):
    listing = ListingSerializer(read_only=True)
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = DonationRequest
        fields = [
            'id', 'listing', 'user', 'message', 'status',
            'created_at', 'updated_at'
        ]

class DonationRequestStatusUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = DonationRequest
        fields = ['status']
        
    def validate_status(self, value):
        if value not in ['accepted', 'rejected']:
            raise serializers.ValidationError("Status must be 'accepted' or 'rejected'")
        return value
