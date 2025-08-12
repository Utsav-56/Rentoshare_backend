from django.db import models
from django.contrib.auth import get_user_model
from listings.models import Listing

User = get_user_model()

class TransactionStatus(models.TextChoices):
    PENDING = 'pending', 'Pending'
    ACTIVE = 'active', 'Active'
    COMPLETED = 'completed', 'Completed'
    CANCELLED = 'cancelled', 'Cancelled'
    DISPUTED = 'disputed', 'Disputed'

class Transaction(models.Model):
    listing = models.ForeignKey(Listing, on_delete=models.CASCADE, related_name='transactions')
    vendor = models.ForeignKey(User, on_delete=models.CASCADE, related_name='vendor_transactions')
    consumer = models.ForeignKey(User, on_delete=models.CASCADE, related_name='consumer_transactions')
    
    start_date = models.DateTimeField()
    end_date = models.DateTimeField()
    total_price = models.DecimalField(max_digits=10, decimal_places=2)
    
    status = models.CharField(max_length=15, choices=TransactionStatus.choices, default=TransactionStatus.PENDING)
    is_refunded = models.BooleanField(default=False)
    payment_hold_expires = models.DateTimeField(blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Transaction {self.id} - {self.listing.title} ({self.status})"
    
    @property
    def duration_days(self):
        return (self.end_date - self.start_date).days
