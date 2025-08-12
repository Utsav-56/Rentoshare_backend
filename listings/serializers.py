from rest_framework import serializers
from .models import Listing

class ListingSerializer(serializers.ModelSerializer):
    user_email = serializers.EmailField(source='user.email', read_only=True)
    user_name = serializers.CharField(source='user.full_name', read_only=True)

    class Meta:
        model = Listing
        fields = [
            'id', 'user', 'user_email', 'user_name', 'title', 'description',
            'listing_type', 'price_per_day', 'location', 'images', 'is_active',
            'available_from', 'available_to', 'extra_details', 'created_at'
        ]
        read_only_fields = ['id', 'created_at', 'user']

    def create(self, validated_data):
        # Set the user to the current authenticated user
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)

class ListingCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Listing
        fields = [
            'title', 'description', 'listing_type', 'price_per_day',
            'location', 'images', 'available_from', 'available_to', 'extra_details'
        ]

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)
    