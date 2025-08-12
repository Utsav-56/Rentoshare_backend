from rest_framework import generics, permissions, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from django.utils import timezone
from .models import KYC
from .serializers import (
    KYCSerializer, KYCCreateSerializer, KYCStatusUpdateSerializer, KYCPublicSerializer
)

class KYCCreateView(generics.CreateAPIView):
    serializer_class = KYCCreateSerializer
    permission_classes = [IsAuthenticated]
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class KYCDetailView(generics.RetrieveUpdateAPIView):
    serializer_class = KYCSerializer
    permission_classes = [IsAuthenticated]
    
    def get_object(self):
        try:
            return KYC.objects.get(user=self.request.user)
        except KYC.DoesNotExist:
            return None
    
    def get(self, request, *args, **kwargs):
        kyc = self.get_object()
        if not kyc:
            return Response(
                {"detail": "KYC not found for this user."}, 
                status=status.HTTP_404_NOT_FOUND
            )
        serializer = self.get_serializer(kyc)
        return Response(serializer.data)

class KYCListView(generics.ListAPIView):
    queryset = KYC.objects.all()
    serializer_class = KYCSerializer
    permission_classes = [IsAdminUser]
    
    def get_queryset(self):
        queryset = super().get_queryset()
        kyc_status = self.request.query_params.get('status', None)
        if kyc_status:
            queryset = queryset.filter(kyc_status=kyc_status)
        return queryset

class KYCStatusUpdateView(generics.UpdateAPIView):
    queryset = KYC.objects.all()
    serializer_class = KYCStatusUpdateSerializer
    permission_classes = [IsAdminUser]
    
    def perform_update(self, serializer):
        instance = serializer.save(
            verified_by=self.request.user,
            verified_at=timezone.now() if serializer.validated_data.get('kyc_status') == 'approved' else None,
            is_verified=serializer.validated_data.get('kyc_status') == 'approved'
        )

@api_view(['GET'])
@permission_classes([permissions.AllowAny])
def kyc_public_status(request, user_id):
    """Public endpoint to check KYC verification status of a user"""
    try:
        kyc = KYC.objects.get(user_id=user_id)
        serializer = KYCPublicSerializer(kyc)
        return Response(serializer.data)
    except KYC.DoesNotExist:
        return Response(
            {"detail": "KYC not found for this user."}, 
            status=status.HTTP_404_NOT_FOUND
        )
