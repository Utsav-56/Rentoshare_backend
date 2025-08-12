from rest_framework import serializers
from .models import KYC

class KYCSerializer(serializers.ModelSerializer):
    user_email = serializers.CharField(source='user.email', read_only=True)
    user_full_name = serializers.CharField(source='user.full_name', read_only=True)
    
    class Meta:
        model = KYC
        fields = [
            'id', 'user', 'user_email', 'user_full_name', 'gov_id_number', 
            'document_type', 'document_front_picture', 'document_back_picture',
            'is_verified', 'kyc_status', 'temp_address', 'permanent_address',
            'date_of_birth', 'nationality', 'occupation', 'annual_income',
            'emergency_contact_name', 'emergency_contact_phone', 'emergency_contact_relation',
            'submitted_at', 'verified_at', 'verified_by', 'rejection_reason'
        ]
        read_only_fields = ['id', 'user', 'is_verified', 'submitted_at', 'verified_at', 'verified_by']

class KYCCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = KYC
        fields = [
            'gov_id_number', 'document_type', 'document_front_picture', 
            'document_back_picture', 'temp_address', 'permanent_address',
            'date_of_birth', 'nationality', 'occupation', 'annual_income',
            'emergency_contact_name', 'emergency_contact_phone', 'emergency_contact_relation'
        ]

class KYCStatusUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = KYC
        fields = ['kyc_status', 'rejection_reason']
        
    def validate(self, data):
        if data.get('kyc_status') == 'rejected' and not data.get('rejection_reason'):
            raise serializers.ValidationError("Rejection reason is required when rejecting KYC.")
        return data

class KYCPublicSerializer(serializers.ModelSerializer):
    """Public serializer for KYC status - only shows basic verification info"""
    user_email = serializers.CharField(source='user.email', read_only=True)
    
    class Meta:
        model = KYC
        fields = ['user_email', 'is_verified', 'kyc_status', 'verified_at']
