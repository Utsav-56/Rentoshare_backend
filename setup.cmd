@echo off
REM filepath: d:\4th sem project\rentoshare_backend\setup.bat
setlocal enabledelayedexpansion

REM Check if running as administrator for package installations
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Warning: Not running as administrator. Some installations may fail.
    echo Consider running as administrator if you encounter issues.
    echo.
)

REM Function to print colored text (simulated with echo)
goto :main

:print_color
set "color=%~1"
set "message=%~2"
if "%color%"=="red" (
    echo [91m%message%[0m
) else if "%color%"=="green" (
    echo [92m%message%[0m
) else if "%color%"=="yellow" (
    echo [93m%message%[0m
) else if "%color%"=="blue" (
    echo [94m%message%[0m
) else if "%color%"=="cyan" (
    echo [96m%message%[0m
) else if "%color%"=="magenta" (
    echo [95m%message%[0m
) else if "%color%"=="white" (
    echo [97m%message%[0m
) else (
    echo %message%
)
goto :eof

:command_exists
where "%~1" >nul 2>&1
goto :eof

:execute_with_check
set "command=%~1"
set "success_message=%~2"
set "error_message=%~3"

call :print_color cyan "Executing: %command%"
call %command%
if !errorlevel! equ 0 (
    call :print_color green "%success_message%"
    exit /b 0
) else (
    call :print_color red "%error_message% Exit code: !errorlevel!"
    exit /b 1
)

:validate_email
set "email=%~1"
echo %email% | findstr /r "^[A-Za-z0-9._%+-]*@[A-Za-z0-9.-]*\.[A-Za-z][A-Za-z]*$" >nul
goto :eof

:create_django_superuser
call :print_color yellow ""
call :print_color yellow "Creating Django superuser..."

:username_loop
set /p username="Enter username for superuser: "
if "%username%"=="" (
    call :print_color red "Username cannot be empty."
    goto :username_loop
)

:email_loop
set /p email="Enter email for superuser: "
if "%email%"=="" (
    call :print_color red "Email cannot be empty."
    goto :email_loop
)
call :validate_email "%email%"
if !errorlevel! neq 0 (
    call :print_color red "Please enter a valid email address."
    goto :email_loop
)

:password_loop
set "password="
set /p password="Enter password for superuser: "
if "%password%"=="" (
    call :print_color red "Password cannot be empty."
    goto :password_loop
)

REM Set environment variables
set "DJANGO_SUPERUSER_USERNAME=%username%"
set "DJANGO_SUPERUSER_EMAIL=%email%"
set "DJANGO_SUPERUSER_PASSWORD=%password%"

call :execute_with_check "python manage.py createsuperuser --noinput" "Superuser created successfully." "Failed to create superuser."
if !errorlevel! equ 0 (
    call :print_color green ""
    call :print_color green "Django Admin Credentials:"
    call :print_color cyan "URL: http://localhost:8000/admin/"
    call :print_color white "Username: %username%"
    call :print_color white "Email: %email%"
    call :print_color white "Password: %password%"
    exit /b 0
)
exit /b 1

:cleanup_env_vars
set "DJANGO_SUPERUSER_USERNAME="
set "DJANGO_SUPERUSER_EMAIL="
set "DJANGO_SUPERUSER_PASSWORD="
goto :eof

:main
call :print_color magenta "=== Django Project Setup Script ==="

REM Check for winget
call :command_exists winget
if !errorlevel! equ 0 (
    call :print_color green "✓ Winget found. Will use it for installations."
    set "HAS_WINGET=true"
) else (
    call :print_color red "winget is not installed. Please install it manually from Microsoft Store or GitHub."
    exit /b 1
)

REM Check and install Python
call :command_exists python
if !errorlevel! equ 0 (
    call :print_color green "✓ Python is already installed."
) else (
    call :print_color yellow "Installing Python..."
    winget install Python.Python.3 --accept-package-agreements --accept-source-agreements
    if !errorlevel! neq 0 (
        call :print_color red "Failed to install Python."
        exit /b 1
    )
    call :print_color green "Python installed successfully."
    REM Refresh PATH
    call refreshenv >nul 2>&1 || (
        call :print_color yellow "Please restart your command prompt or refresh your PATH to use Python."
    )
)

REM Check and install pip
call :command_exists pip
if !errorlevel! equ 0 (
    call :print_color green "✓ pip is already installed."
) else (
    call :print_color yellow "pip not found. It should come with Python. Please check your Python installation."
)

REM Check and install pipenv
call :command_exists pipenv
if !errorlevel! equ 0 (
    call :print_color green "✓ pipenv is already installed."
) else (
    call :print_color yellow "Installing pipenv..."
    call :execute_with_check "pip install pipenv" "pipenv installed successfully." "Failed to install pipenv."
    if !errorlevel! neq 0 exit /b 1
)

REM Install dependencies
call :print_color yellow ""
call :print_color yellow "Installing project dependencies..."
call :execute_with_check "pipenv install" "Dependencies installed successfully." "Failed to install dependencies."
if !errorlevel! neq 0 exit /b 1

REM Run migrations
call :print_color yellow ""
call :print_color yellow "Running Django migrations..."

call :execute_with_check "pipenv run python manage.py makemigrations" "Migrations created successfully." "Failed to create migrations."
if !errorlevel! neq 0 exit /b 1

call :execute_with_check "pipenv run python manage.py migrate" "Migrations applied successfully." "Failed to apply migrations."
if !errorlevel! neq 0 exit /b 1

REM Create superuser
echo.
set /p create_superuser="Would you like to create a Django superuser? (y/N): "
if /i "%create_superuser%"=="y" (
    call :create_django_superuser
    if !errorlevel! neq 0 (
        call :print_color yellow "Superuser creation failed, but continuing with setup."
    )
)

REM Final instructions
call :print_color green ""
call :print_color green "=== Setup Complete ==="
call :print_color cyan "To start the development server, run:"
call :print_color white "  pipenv run python manage.py runserver"
call :print_color cyan ""
call :print_color cyan "To enter the virtual environment, run:"
call :print_color white "  pipenv shell"

REM Ask if user wants to start the server now
echo.
set /p start_server="Would you like to start the Django development server now? (y/N): "
if /i "%start_server%"=="y" (
    call :print_color yellow ""
    call :print_color yellow "Starting Django development server..."
    pipenv run python manage.py runserver
)

call :cleanup_env_vars
goto :eof