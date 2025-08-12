from django.shortcuts import render

from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Listing
from .serializers import ListingSerializer, ListingCreateSerializer

class ListingViewSet(viewsets.ModelViewSet):
    queryset = Listing.objects.all()
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_serializer_class(self):
        if self.action == 'create':
            return ListingCreateSerializer
        return ListingSerializer

    def get_queryset(self):
        queryset = Listing.objects.filter(is_active=True)
        listing_type = self.request.query_params.get('type', None)
        if listing_type is not None:
            queryset = queryset.filter(listing_type=listing_type)
        return queryset

    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def my_listings(self, request):
        """Get current user's listings"""
        listings = Listing.objects.filter(user=request.user)
        serializer = self.get_serializer(listings, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['patch'], permission_classes=[permissions.IsAuthenticated])
    def toggle_active(self, request, pk=None):
        """Toggle listing active status"""
        listing = self.get_object()
        if listing.user != request.user:
            return Response(
                {'error': 'You can only modify your own listings'},
                status=status.HTTP_403_FORBIDDEN
            )
        listing.is_active = not listing.is_active
        listing.save()
        serializer = self.get_serializer(listing)
        return Response(serializer.data)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def perform_update(self, serializer):
        # Only allow users to update their own listings
        if serializer.instance.user != self.request.user:
            raise PermissionError("You can only modify your own listings")
        serializer.save()

    def perform_destroy(self, instance):
        # Only allow users to delete their own listings
        if instance.user != self.request.user:
            raise PermissionError("You can only delete your own listings")
        instance.delete()