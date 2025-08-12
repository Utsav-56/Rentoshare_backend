from django.db import models
from django.contrib.auth import get_user_model
from listings.models import Listing

User = get_user_model()

class RequestStatus(models.TextChoices):
    PENDING = 'pending', 'Pending'
    ACCEPTED = 'accepted', 'Accepted'
    REJECTED = 'rejected', 'Rejected'

class DonationRequest(models.Model):
    listing = models.ForeignKey(Listing, on_delete=models.CASCADE, related_name='donation_requests')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='donation_requests')
    
    message = models.TextField(blank=True, null=True)
    status = models.CharField(max_length=10, choices=RequestStatus.choices, default=RequestStatus.PENDING)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = [['listing', 'user']]
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Donation request for {self.listing.title} by {self.user.email} ({self.status})"
