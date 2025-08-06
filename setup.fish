#!/usr/bin/env fish
# filepath: d:\4th sem project\rentoshare_backend\setup.fish

# Set error handling
set -g fish_trace 1

# Global variables
set -g SCRIPT_DIR (dirname (realpath (status filename)))
set -g IS_HOMEBREW_INSTALLED ""
set -g IS_APT_AVAILABLE ""
set -g IS_YUM_AVAILABLE ""

# Colors for output
set -g color_red (set_color red)
set -g color_green (set_color green)
set -g color_yellow (set_color yellow)
set -g color_blue (set_color blue)
set -g color_cyan (set_color cyan)
set -g color_magenta (set_color magenta)
set -g color_white (set_color white)
set -g color_reset (set_color normal)

# Function to print colored output
function print_color
    set color_name $argv[1]
    set message $argv[2..-1]
    
    switch $color_name
        case red
            echo $color_red$message$color_reset
        case green
            echo $color_green$message$color_reset
        case yellow
            echo $color_yellow$message$color_reset
        case blue
            echo $color_blue$message$color_reset
        case cyan
            echo $color_cyan$message$color_reset
        case magenta
            echo $color_magenta$message$color_reset
        case white
            echo $color_white$message$color_reset
        case '*'
            echo $message
    end
end

# Function to check if a command exists
function command_exists
    command -v $argv[1] >/dev/null 2>&1
end

# Function to detect package manager
function detect_package_manager
    switch (uname)
        case Darwin
            if command_exists brew
                set -g IS_HOMEBREW_INSTALLED true
                print_color green "✓ Homebrew found. Will use it for installations."
            else
                print_color red "Homebrew is not installed. Please install it from https://brew.sh/"
                exit 1
            end
        case Linux
            if command_exists apt-get
                set -g IS_APT_AVAILABLE true
                print_color green "✓ APT found. Will use it for installations."
            else if command_exists yum
                set -g IS_YUM_AVAILABLE true
                print_color green "✓ YUM found. Will use it for installations."
            else
                print_color red "No supported package manager found (apt or yum)."
                exit 1
            end
        case '*'
            print_color red "Unsupported operating system: "(uname)
            exit 1
    end
end

# Function to install packages
function install_package
    set package_name $argv[1]
    set display_name $argv[2]
    if test -z "$display_name"
        set display_name $package_name
    end
    
    print_color yellow "Installing $display_name..."
    
    if test "$IS_HOMEBREW_INSTALLED" = "true"
        if brew install $package_name
            print_color green "$display_name installed successfully."
        else
            print_color red "Failed to install $display_name."
            exit 1
        end
    else if test "$IS_APT_AVAILABLE" = "true"
        if sudo apt-get update; and sudo apt-get install -y $package_name
            print_color green "$display_name installed successfully."
        else
            print_color red "Failed to install $display_name."
            exit 1
        end
    else if test "$IS_YUM_AVAILABLE" = "true"
        if sudo yum install -y $package_name
            print_color green "$display_name installed successfully."
        else
            print_color red "Failed to install $display_name."
            exit 1
        end
    end
end

# Function to execute command with error handling
function execute_with_check
    set command $argv[1]
    set success_message $argv[2]
    set error_message $argv[3]
    
    print_color cyan "Executing: $command"
    
    if eval $command
        print_color green "$success_message"
        return 0
    else
        set exit_code $status
        print_color red "$error_message Exit code: $exit_code"
        return 1
    end
end

# Function to validate email
function validate_email
    set email $argv[1]
    echo $email | grep -E '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' >/dev/null
end

# Function to create Django superuser
function create_django_superuser
    print_color yellow "\nCreating Django superuser..."
    
    # Get username
    while true
        read -P "Enter username for superuser: " username
        if test -n "$username"
            break
        end
        print_color red "Username cannot be empty."
    end
    
    # Get email
    while true
        read -P "Enter email for superuser: " email
        if test -n "$email"; and validate_email $email
            break
        end
        print_color red "Please enter a valid email address."
    end
    
    # Get password
    while true
        read -s -P "Enter password for superuser: " password
        echo
        if test -n "$password"
            break
        end
        print_color red "Password cannot be empty."
    end
    
    # Set environment variables
    set -x DJANGO_SUPERUSER_USERNAME $username
    set -x DJANGO_SUPERUSER_EMAIL $email
    set -x DJANGO_SUPERUSER_PASSWORD $password
    
    if execute_with_check "python manage.py createsuperuser --noinput" "Superuser created successfully." "Failed to create superuser."
        print_color green "\nDjango Admin Credentials:"
        print_color cyan "URL: http://localhost:8000/admin/"
        print_color white "Username: $username"
        print_color white "Email: $email"
        print_color white "Password: $password"
        return 0
    end
    return 1
end

# Function to cleanup environment variables
function cleanup_env_vars
    set -e DJANGO_SUPERUSER_USERNAME
    set -e DJANGO_SUPERUSER_EMAIL
    set -e DJANGO_SUPERUSER_PASSWORD
end

# Function to prompt for yes/no
function prompt_yn
    set prompt $argv[1]
    read -P "$prompt (y/N): " response
    test "$response" = "y"; or test "$response" = "Y"
end

# Function to handle cleanup on exit
function cleanup_on_exit --on-event fish_exit
    cleanup_env_vars
end

# Main script execution
function main
    print_color magenta "=== Django Project Setup Script ==="
    
    # Detect package manager
    detect_package_manager
    
    # Check and install Python
    if command_exists python3
        print_color green "✓ Python3 is already installed."
    else if command_exists python
        print_color green "✓ Python is already installed."
    else
        print_color yellow "Installing Python..."
        if test "$IS_HOMEBREW_INSTALLED" = "true"
            install_package "python@3.11" "Python"
        else if test "$IS_APT_AVAILABLE" = "true"
            install_package "python3 python3-pip" "Python"
        else if test "$IS_YUM_AVAILABLE" = "true"
            install_package "python3 python3-pip" "Python"
        end
    end
    
    # Set python command
    set python_cmd python3
    if not command_exists python3; and command_exists python
        set python_cmd python
    end
    
    # Check and install pip
    if command_exists pip3; or command_exists pip
        print_color green "✓ pip is already installed."
    else
        print_color yellow "pip not found. It should come with Python. Please check your Python installation."
    end
    
    # Set pip command
    set pip_cmd pip3
    if not command_exists pip3; and command_exists pip
        set pip_cmd pip
    end
    
    # Check and install pipenv
    if command_exists pipenv
        print_color green "✓ pipenv is already installed."
    else
        print_color yellow "Installing pipenv..."
        if not execute_with_check "$pip_cmd install pipenv" "pipenv installed successfully." "Failed to install pipenv."
            exit 1
        end
    end
    
    # Install dependencies
    print_color yellow "\nInstalling project dependencies..."
    if not execute_with_check "pipenv install" "Dependencies installed successfully." "Failed to install dependencies."
        exit 1
    end
    
    # Run migrations
    print_color yellow "\nRunning Django migrations..."
    
    if not execute_with_check "pipenv run python manage.py makemigrations" "Migrations created successfully." "Failed to create migrations."
        exit 1
    end
    
    if not execute_with_check "pipenv run python manage.py migrate" "Migrations applied successfully." "Failed to apply migrations."
        exit 1
    end
    
    # Create superuser
    if prompt_yn "\nWould you like to create a Django superuser?"
        if not create_django_superuser
            print_color yellow "Superuser creation failed, but continuing with setup."
        end
    end
    
    # Final instructions
    print_color green "\n=== Setup Complete ==="
    print_color cyan "To start the development server, run:"
    print_color white "  pipenv run python manage.py runserver"
    print_color cyan "\nTo enter the virtual environment, run:"
    print_color white "  pipenv shell"
    
    # Ask if user wants to start the server now
    if prompt_yn "\nWould you like to start the Django development server now?"
        print_color yellow "\nStarting Django development server..."
        pipenv run python manage.py runserver
    end
    
    cleanup_env_vars
end

# Run main function
main $argv