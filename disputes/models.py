from django.db import models
from django.contrib.auth import get_user_model
from transactions.models import Transaction

User = get_user_model()

class DisputeStatus(models.TextChoices):
    OPEN = 'open', 'Open'
    RESOLVED = 'resolved', 'Resolved'
    REJECTED = 'rejected', 'Rejected'

class Dispute(models.Model):
    transaction = models.ForeignKey(Transaction, on_delete=models.CASCADE, related_name='disputes')
    raised_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='raised_disputes')
    
    reason = models.TextField()
    status = models.CharField(max_length=10, choices=DisputeStatus.choices, default=DisputeStatus.OPEN)
    
    created_at = models.DateTimeField(auto_now_add=True)
    resolved_at = models.DateTimeField(blank=True, null=True)
    resolved_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='resolved_disputes')
    resolution_notes = models.TextField(blank=True, null=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Dispute {self.id} - Transaction {self.transaction.id} ({self.status})"
