from django.contrib import admin
from .models import Listing

@admin.register(Listing)
class ListingAdmin(admin.ModelAdmin):
    list_display = ['title', 'user', 'listing_type', 'price_per_day', 'is_active', 'created_at']
    list_filter = ['listing_type', 'is_active', 'created_at']
    search_fields = ['title', 'description', 'user__email', 'user__full_name']
    readonly_fields = ['created_at']
    
    def get_queryset(self, request):
        return super().get_queryset(request).select_related('user')