from django.contrib import admin
from .models import User

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ['id', 'email', 'full_name', 'role', 'is_verified', 'is_active', 'is_staff', 'created_at']
    list_filter = ['role', 'is_verified', 'is_active', 'is_staff', 'created_at']
    search_fields = ['email', 'full_name', 'phone']
    readonly_fields = ['created_at']
    fieldsets = (
        ('User Info', {'fields': ('email', 'full_name', 'phone', 'role', 'bio', 'profile_picture')}),
        ('Permissions', {'fields': ('is_verified', 'is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Timestamps', {'fields': ('created_at',)}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'full_name', 'phone', 'password1', 'password2', 'role', 'is_verified', 'is_active', 'is_staff'),
        }),
    )
    ordering = ['-created_at']
