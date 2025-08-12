from django.contrib import admin
from .models import Transaction

@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ['id', 'listing', 'vendor', 'consumer', 'status', 'total_price', 'start_date', 'end_date', 'created_at']
    list_filter = ['status', 'is_refunded', 'created_at', 'start_date']
    search_fields = ['listing__title', 'vendor__email', 'consumer__email']
    readonly_fields = ['created_at', 'duration_days']
    
    fieldsets = (
        ('Transaction Details', {
            'fields': ('listing', 'vendor', 'consumer', 'status')
        }),
        ('Rental Period', {
            'fields': ('start_date', 'end_date', 'duration_days')
        }),
        ('Financial Information', {
            'fields': ('total_price', 'is_refunded', 'payment_hold_expires')
        }),
        ('Timestamps', {
            'fields': ('created_at',)
        }),
    )
    
    def duration_days(self, obj):
        return obj.duration_days
    duration_days.short_description = 'Duration (days)'
