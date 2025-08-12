from django.db import models
from django.conf import settings

class Listing(models.Model):
    LISTING_TYPES = [
        ('product', 'Product'),
        ('service', 'Service'),
        ('donation', 'Donation'),
    ]

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='listings'
    )
    title = models.CharField(max_length=200)
    description = models.TextField()
    listing_type = models.CharField(max_length=10, choices=LISTING_TYPES)
    price_per_day = models.FloatField(null=True, blank=True)
    location = models.TextField(blank=True, null=True)
    images = models.JSONField(default=list, blank=True)  # Store image URLs/paths
    is_active = models.BooleanField(default=True)
    available_from = models.DateTimeField(null=True, blank=True)
    available_to = models.DateTimeField(null=True, blank=True)
    extra_details = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'listings'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} - {self.user.email}"