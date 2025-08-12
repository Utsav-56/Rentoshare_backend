from django.contrib import admin
from .models import Dispute

@admin.register(Dispute)
class DisputeAdmin(admin.ModelAdmin):
    list_display = ['id', 'transaction', 'raised_by', 'status', 'created_at', 'resolved_at']
    list_filter = ['status', 'created_at', 'resolved_at']
    search_fields = ['transaction__id', 'raised_by__email', 'reason']
    readonly_fields = ['created_at', 'resolved_at']
    
    fieldsets = (
        ('Dispute Information', {
            'fields': ('transaction', 'raised_by', 'reason', 'status')
        }),
        ('Resolution', {
            'fields': ('resolved_by', 'resolution_notes')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'resolved_at')
        }),
    )
