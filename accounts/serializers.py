# // filepath: d:\4th sem project\rentoshare_backend\accounts\serializers.py
from rest_framework import serializers
from djoser.serializers import UserCreateSerializer as BaseUserCreateSerializer
from djoser.serializers import UserSerializer as BaseUserSerializer
from .models import User

class UserCreateSerializer(BaseUserCreateSerializer):
    class Meta(BaseUserCreateSerializer.Meta):
        model = User
        fields = ('id', 'email', 'full_name', 'phone', 'password', 'role')

class UserSerializer(BaseUserSerializer):
    class Meta(BaseUserSerializer.Meta):
        model = User
        fields = ('id', 'email', 'full_name', 'phone', 'bio', 'profile_picture', 
                 'role', 'is_verified', 'created_at')
        read_only_fields = ('id', 'is_verified', 'created_at')