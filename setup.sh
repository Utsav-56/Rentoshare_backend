#!/bin/bash
# filepath: d:\4th sem project\rentoshare_backend\setup.sh

set -euo pipefail

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IS_HOMEBREW_INSTALLED=""
IS_APT_AVAILABLE=""
IS_YUM_AVAILABLE=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect package manager
detect_package_manager() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command_exists brew; then
            IS_HOMEBREW_INSTALLED="true"
            print_color $GREEN "✓ Homebrew found. Will use it for installations."
        else
            print_color $RED "Homebrew is not installed. Please install it from https://brew.sh/"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists apt-get; then
            IS_APT_AVAILABLE="true"
            print_color $GREEN "✓ APT found. Will use it for installations."
        elif command_exists yum; then
            IS_YUM_AVAILABLE="true"
            print_color $GREEN "✓ YUM found. Will use it for installations."
        else
            print_color $RED "No supported package manager found (apt or yum)."
            exit 1
        fi
    else
        print_color $RED "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Function to install packages
install_package() {
    local package_name=$1
    local display_name=${2:-$package_name}
    
    print_color $YELLOW "Installing $display_name..."
    
    if [[ "$IS_HOMEBREW_INSTALLED" == "true" ]]; then
        if brew install "$package_name"; then
            print_color $GREEN "$display_name installed successfully."
        else
            print_color $RED "Failed to install $display_name."
            exit 1
        fi
    elif [[ "$IS_APT_AVAILABLE" == "true" ]]; then
        if sudo apt-get update && sudo apt-get install -y "$package_name"; then
            print_color $GREEN "$display_name installed successfully."
        else
            print_color $RED "Failed to install $display_name."
            exit 1
        fi
    elif [[ "$IS_YUM_AVAILABLE" == "true" ]]; then
        if sudo yum install -y "$package_name"; then
            print_color $GREEN "$display_name installed successfully."
        else
            print_color $RED "Failed to install $display_name."
            exit 1
        fi
    fi
}

# Function to execute command with error handling
execute_with_check() {
    local command=$1
    local success_message=$2
    local error_message=$3
    
    print_color $CYAN "Executing: $command"
    
    if eval "$command"; then
        print_color $GREEN "$success_message"
        return 0
    else
        print_color $RED "$error_message Exit code: $?"
        return 1
    fi
}

# Function to validate email
validate_email() {
    local email=$1
    if [[ $email =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to create Django superuser
create_django_superuser() {
    print_color $YELLOW "\nCreating Django superuser..."
    
    while true; do
        read -p "Enter username for superuser: " username
        if [[ -n "$username" ]]; then
            break
        fi
        print_color $RED "Username cannot be empty."
    done
    
    while true; do
        read -p "Enter email for superuser: " email
        if [[ -n "$email" ]] && validate_email "$email"; then
            break
        fi
        print_color $RED "Please enter a valid email address."
    done
    
    while true; do
        read -s -p "Enter password for superuser: " password
        echo
        if [[ -n "$password" ]]; then
            break
        fi
        print_color $RED "Password cannot be empty."
    done
    
    # Set environment variables
    export DJANGO_SUPERUSER_USERNAME="$username"
    export DJANGO_SUPERUSER_EMAIL="$email"
    export DJANGO_SUPERUSER_PASSWORD="$password"
    
    if execute_with_check "python manage.py createsuperuser --noinput" "Superuser created successfully." "Failed to create superuser."; then
        print_color $GREEN "\nDjango Admin Credentials:"
        print_color $CYAN "URL: http://localhost:8000/admin/"
        print_color $WHITE "Username: $username"
        print_color $WHITE "Email: $email"
        print_color $WHITE "Password: $password"
        return 0
    fi
    return 1
}

# Function to cleanup environment variables
cleanup_env_vars() {
    unset DJANGO_SUPERUSER_USERNAME
    unset DJANGO_SUPERUSER_EMAIL
    unset DJANGO_SUPERUSER_PASSWORD
}

# Main script execution
main() {
    print_color $MAGENTA "=== Django Project Setup Script ==="
    
    # Detect package manager
    detect_package_manager
    
    # Check and install Python
    if command_exists python3; then
        print_color $GREEN "✓ Python3 is already installed."
    elif command_exists python; then
        print_color $GREEN "✓ Python is already installed."
    else
        print_color $YELLOW "Installing Python..."
        if [[ "$IS_HOMEBREW_INSTALLED" == "true" ]]; then
            install_package "python@3.11" "Python"
        elif [[ "$IS_APT_AVAILABLE" == "true" ]]; then
            install_package "python3 python3-pip" "Python"
        elif [[ "$IS_YUM_AVAILABLE" == "true" ]]; then
            install_package "python3 python3-pip" "Python"
        fi
    fi
    
    # Set python command
    PYTHON_CMD="python3"
    if ! command_exists python3 && command_exists python; then
        PYTHON_CMD="python"
    fi
    
    # Check and install pip
    if command_exists pip3 || command_exists pip; then
        print_color $GREEN "✓ pip is already installed."
    else
        print_color $YELLOW "pip not found. It should come with Python. Please check your Python installation."
    fi
    
    # Set pip command
    PIP_CMD="pip3"
    if ! command_exists pip3 && command_exists pip; then
        PIP_CMD="pip"
    fi
    
    # Check and install pipenv
    if command_exists pipenv; then
        print_color $GREEN "✓ pipenv is already installed."
    else
        print_color $YELLOW "Installing pipenv..."
        if ! execute_with_check "$PIP_CMD install pipenv" "pipenv installed successfully." "Failed to install pipenv."; then
            exit 1
        fi
    fi
    
    # Install dependencies
    print_color $YELLOW "\nInstalling project dependencies..."
    if ! execute_with_check "pipenv install" "Dependencies installed successfully." "Failed to install dependencies."; then
        exit 1
    fi
    
    # Run migrations
    print_color $YELLOW "\nRunning Django migrations..."
    
    if ! execute_with_check "pipenv run python manage.py makemigrations" "Migrations created successfully." "Failed to create migrations."; then
        exit 1
    fi
    
    if ! execute_with_check "pipenv run python manage.py migrate" "Migrations applied successfully." "Failed to apply migrations."; then
        exit 1
    fi
    
    # Create superuser
    read -p $'\n'"Would you like to create a Django superuser? (y/N): " create_superuser
    if [[ $create_superuser =~ ^[Yy]$ ]]; then
        if ! create_django_superuser; then
            print_color $YELLOW "Superuser creation failed, but continuing with setup."
        fi
    fi
    
    # Final instructions
    print_color $GREEN "\n=== Setup Complete ==="
    print_color $CYAN "To start the development server, run:"
    print_color $WHITE "  pipenv run python manage.py runserver"
    print_color $CYAN "\nTo enter the virtual environment, run:"
    print_color $WHITE "  pipenv shell"
    
    # Ask if user wants to start the server now
    read -p $'\n'"Would you like to start the Django development server now? (y/N): " start_server
    if [[ $start_server =~ ^[Yy]$ ]]; then
        print_color $YELLOW "\nStarting Django development server..."
        pipenv run python manage.py runserver
    fi
}

# Trap to ensure cleanup on exit
trap cleanup_env_vars EXIT

# Run main function
main "$@"