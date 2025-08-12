from django.db import models
from django.contrib.auth import get_user_model
from django.core.validators import MinValueValidator, MaxValueValidator

User = get_user_model()

class DocumentType(models.TextChoices):
    LICENSE = 'license', 'License'
    PASSPORT = 'passport', 'Passport'
    NATIONAL_ID = 'national_id', 'National ID'
    VOTER_ID = 'voter_id', 'Voter ID'
    PAN_CARD = 'pan_card', 'PAN Card'
    AADHAAR = 'aadhaar', 'Aadhaar'
    OTHER = 'other', 'Other'

class KYCStatus(models.TextChoices):
    PENDING = 'pending', 'Pending'
    APPROVED = 'approved', 'Approved'
    REJECTED = 'rejected', 'Rejected'
    UNDER_REVIEW = 'under_review', 'Under Review'

class KYC(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='kyc')
    gov_id_number = models.CharField(max_length=50)
    document_type = models.CharField(max_length=20, choices=DocumentType.choices)
    document_front_picture = models.TextField()  # URL/path to front image
    document_back_picture = models.TextField(blank=True, null=True)  # URL/path to back image
    is_verified = models.BooleanField(default=False)
    kyc_status = models.CharField(max_length=15, choices=KYCStatus.choices, default=KYCStatus.PENDING)
    
    # Address Information
    temp_address = models.TextField(blank=True, null=True)
    permanent_address = models.TextField()
    
    # Personal Information
    date_of_birth = models.DateField(blank=True, null=True)
    nationality = models.CharField(max_length=50, blank=True, null=True)
    occupation = models.CharField(max_length=100, blank=True, null=True)
    annual_income = models.DecimalField(max_digits=12, decimal_places=2, blank=True, null=True)
    
    # Emergency Contact
    emergency_contact_name = models.CharField(max_length=100, blank=True, null=True)
    emergency_contact_phone = models.CharField(max_length=20, blank=True, null=True)
    emergency_contact_relation = models.CharField(max_length=50, blank=True, null=True)
    
    # Verification Information
    submitted_at = models.DateTimeField(auto_now_add=True)
    verified_at = models.DateTimeField(blank=True, null=True)
    verified_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='verified_kycs')
    rejection_reason = models.TextField(blank=True, null=True)
    
    class Meta:
        unique_together = [['gov_id_number', 'document_type']]
        verbose_name = 'KYC'
        verbose_name_plural = 'KYCs'
    
    def __str__(self):
        return f"KYC for {self.user.email} - {self.kyc_status}"
