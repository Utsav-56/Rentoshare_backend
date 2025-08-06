#!/usr/bin/env zsh
# filepath: d:\4th sem project\rentoshare_backend\setup.zsh

# Enable error handling
setopt ERR_EXIT
setopt PIPE_FAIL
setopt NO_UNSET

# Global variables
typeset -g SCRIPT_DIR="${0:A:h}"
typeset -g IS_HOMEBREW_INSTALLED=""
typeset -g IS_APT_AVAILABLE=""
typeset -g IS_YUM_AVAILABLE=""

# Colors for output
autoload -U colors && colors
typeset -A color_map=(
    [red]=$fg[red]
    [green]=$fg[green]
    [yellow]=$fg[yellow]
    [blue]=$fg[blue]
    [cyan]=$fg[cyan]
    [magenta]=$fg[magenta]
    [white]=$fg_bold[white]
    [reset]=$reset_color
)

# Function to print colored output
print_color() {
    local color_name=$1
    local message=$2
    print "${color_map[$color_name]}${message}${color_map[reset]}"
}

# Function to check if a command exists
command_exists() {
    (( $+commands[$1] ))
}

# Function to detect package manager
detect_package_manager() {
    case $OSTYPE in
        darwin*)
            if command_exists brew; then
                IS_HOMEBREW_INSTALLED="true"
                print_color green "✓ Homebrew found. Will use it for installations."
            else
                print_color red "Homebrew is not installed. Please install it from https://brew.sh/"
                exit 1
            fi
            ;;
        linux*)
            if command_exists apt-get; then
                IS_APT_AVAILABLE="true"
                print_color green "✓ APT found. Will use it for installations."
            elif command_exists yum; then
                IS_YUM_AVAILABLE="true"
                print_color green "✓ YUM found. Will use it for installations."
            else
                print_color red "No supported package manager found (apt or yum)."
                exit 1
            fi
            ;;
        *)
            print_color red "Unsupported operating system: $OSTYPE"
            exit 1
            ;;
    esac
}

# Function to install packages
install_package() {
    local package_name=$1
    local display_name=${2:-$package_name}
    
    print_color yellow "Installing $display_name..."
    
    if [[ "$IS_HOMEBREW_INSTALLED" == "true" ]]; then
        if brew install "$package_name"; then
            print_color green "$display_name installed successfully."
        else
            print_color red "Failed to install $display_name."
            exit 1
        fi
    elif [[ "$IS_APT_AVAILABLE" == "true" ]]; then
        if sudo apt-get update && sudo apt-get install -y "$package_name"; then
            print_color green "$display_name installed successfully."
        else
            print_color red "Failed to install $display_name."
            exit 1
        fi
    elif [[ "$IS_YUM_AVAILABLE" == "true" ]]; then
        if sudo yum install -y "$package_name"; then
            print_color green "$display_name installed successfully."
        else
            print_color red "Failed to install $display_name."
            exit 1
        fi
    fi
}

# Function to execute command with error handling
execute_with_check() {
    local command=$1
    local success_message=$2
    local error_message=$3
    
    print_color cyan "Executing: $command"
    
    if eval "$command"; then
        print_color green "$success_message"
        return 0
    else
        local exit_code=$?
        print_color red "$error_message Exit code: $exit_code"
        return 1
    fi
}

# Function to validate email
validate_email() {
    local email=$1
    if [[ $email =~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' ]]; then
        return 0
    else
        return 1
    fi
}

# Function to create Django superuser
create_django_superuser() {
    print_color yellow "\nCreating Django superuser..."
    
    local username email password
    
    while true; do
        vared -p "Enter username for superuser: " username
        if [[ -n "$username" ]]; then
            break
        fi
        print_color red "Username cannot be empty."
    done
    
    while true; do
        vared -p "Enter email for superuser: " email
        if [[ -n "$email" ]] && validate_email "$email"; then
            break
        fi
        print_color red "Please enter a valid email address."
    done
    
    while true; do
        read -s "password?Enter password for superuser: "
        print
        if [[ -n "$password" ]]; then
            break
        fi
        print_color red "Password cannot be empty."
    done
    
    # Set environment variables
    export DJANGO_SUPERUSER_USERNAME="$username"
    export DJANGO_SUPERUSER_EMAIL="$email"
    export DJANGO_SUPERUSER_PASSWORD="$password"
    
    if execute_with_check "python manage.py createsuperuser --noinput" "Superuser created successfully." "Failed to create superuser."; then
        print_color green "\nDjango Admin Credentials:"
        print_color cyan "URL: http://localhost:8000/admin/"
        print_color white "Username: $username"
        print_color white "Email: $email"
        print_color white "Password: $password"
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

# Function to prompt for yes/no
prompt_yn() {
    local prompt=$1
    local response
    vared -p "$prompt (y/N): " response
    [[ $response =~ '^[Yy]$' ]]
}

# Main script execution
main() {
    print_color magenta "=== Django Project Setup Script ==="
    
    # Detect package manager
    detect_package_manager
    
    # Check and install Python
    if command_exists python3; then
        print_color green "✓ Python3 is already installed."
    elif command_exists python; then
        print_color green "✓ Python is already installed."
    else
        print_color yellow "Installing Python..."
        if [[ "$IS_HOMEBREW_INSTALLED" == "true" ]]; then
            install_package "python@3.11" "Python"
        elif [[ "$IS_APT_AVAILABLE" == "true" ]]; then
            install_package "python3 python3-pip" "Python"
        elif [[ "$IS_YUM_AVAILABLE" == "true" ]]; then
            install_package "python3 python3-pip" "Python"
        fi
    fi
    
    # Set python command
    local python_cmd="python3"
    if ! command_exists python3 && command_exists python; then
        python_cmd="python"
    fi
    
    # Check and install pip
    if command_exists pip3 || command_exists pip; then
        print_color green "✓ pip is already installed."
    else
        print_color yellow "pip not found. It should come with Python. Please check your Python installation."
    fi
    
    # Set pip command
    local pip_cmd="pip3"
    if ! command_exists pip3 && command_exists pip; then
        pip_cmd="pip"
    fi
    
    # Check and install pipenv
    if command_exists pipenv; then
        print_color green "✓ pipenv is already installed."
    else
        print_color yellow "Installing pipenv..."
        if ! execute_with_check "$pip_cmd install pipenv" "pipenv installed successfully." "Failed to install pipenv."; then
            exit 1
        fi
    fi
    
    # Install dependencies
    print_color yellow "\nInstalling project dependencies..."
    if ! execute_with_check "pipenv install" "Dependencies installed successfully." "Failed to install dependencies."; then
        exit 1
    fi
    
    # Run migrations
    print_color yellow "\nRunning Django migrations..."
    
    if ! execute_with_check "pipenv run python manage.py makemigrations" "Migrations created successfully." "Failed to create migrations."; then
        exit 1
    fi
    
    if ! execute_with_check "pipenv run python manage.py migrate" "Migrations applied successfully." "Failed to apply migrations."; then
        exit 1
    fi
    
    # Create superuser
    if prompt_yn "\nWould you like to create a Django superuser?"; then
        if ! create_django_superuser; then
            print_color yellow "Superuser creation failed, but continuing with setup."
        fi
    fi
    
    # Final instructions
    print_color green "\n=== Setup Complete ==="
    print_color cyan "To start the development server, run:"
    print_color white "  pipenv run python manage.py runserver"
    print_color cyan "\nTo enter the virtual environment, run:"
    print_color white "  pipenv shell"
    
    # Ask if user wants to start the server now
    if prompt_yn "\nWould you like to start the Django development server now?"; then
        print_color yellow "\nStarting Django development server..."
        pipenv run python manage.py runserver
    fi
}

# Trap to ensure cleanup on exit
trap cleanup_env_vars EXIT

# Run main function
main "$@"