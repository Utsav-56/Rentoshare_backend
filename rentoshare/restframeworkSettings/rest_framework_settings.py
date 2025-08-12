
# Django REST Framework settings

# Set append slash to False to avoid double slashes in URLs
from datetime import timedelta


APPEND_SLASH = True


# https://www.django-rest-framework.org/api-guide/settings/
CUSTOM_REST_FRAMEWORK_SETTINGS = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    
    ),
     'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',  # Default: require auth
    ]
}

# Optional: JWT settings
CUSTOM_SIMPLE_JWT_SETTINGS = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=60),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=7),
}
