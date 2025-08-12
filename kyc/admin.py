from django.contrib import admin
from .models import KYC

@admin.register(KYC)
class KYCAdmin(admin.ModelAdmin):
    list_display = ['user', 'kyc_status', 'document_type', 'is_verified', 'submitted_at']
    list_filter = ['kyc_status', 'document_type', 'is_verified', 'submitted_at']
    search_fields = ['user__email', 'user__full_name', 'gov_id_number']
    readonly_fields = ['submitted_at', 'verified_at']
    
    fieldsets = (
        ('User Information', {
            'fields': ('user', 'kyc_status', 'is_verified')
        }),
        ('Document Information', {
            'fields': ('gov_id_number', 'document_type', 'document_front_picture', 'document_back_picture')
        }),
        ('Address Information', {
            'fields': ('permanent_address', 'temp_address')
        }),
        ('Personal Information', {
            'fields': ('date_of_birth', 'nationality', 'occupation', 'annual_income')
        }),
        ('Emergency Contact', {
            'fields': ('emergency_contact_name', 'emergency_contact_phone', 'emergency_contact_relation')
        }),
        ('Verification Details', {
            'fields': ('submitted_at', 'verified_at', 'verified_by', 'rejection_reason')
        }),
    )
    
    def get_readonly_fields(self, request, obj=None):
        readonly_fields = list(super().get_readonly_fields(request, obj))
        if obj:  # Editing existing object
            readonly_fields.extend(['user', 'gov_id_number', 'document_type'])
        return readonly_fields
