#Requires -Version 5.1
[CmdletBinding()]
param()

# Global variables
$Script:IsWingetInstalled = $null

# Function to check if a command exists
function Test-CommandExists {
    param([string]$Command)
    return $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Function to install packages using winget
function Install-Package {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$PackageId,
        
        [string]$PackageName = $PackageId
    )

    if (-not $Script:IsWingetInstalled) {
        Write-Error "winget is not installed. Cannot install $PackageName."
        exit 1
    }

    Write-Host "Installing $PackageName using winget..." -ForegroundColor Yellow
    $result = winget install $PackageId --accept-package-agreements --accept-source-agreements
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "$PackageName installed successfully." -ForegroundColor Green
    } else {
        Write-Error "Failed to install $PackageName. Exit code: $LASTEXITCODE"
        exit 1
    }
}

# Function to execute command with error handling
function Invoke-CommandWithCheck {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Command,
        
        [Parameter(Mandatory)]
        [string]$SuccessMessage,
        
        [Parameter(Mandatory)]
        [string]$ErrorMessage
    )

    Write-Host "Executing: $Command" -ForegroundColor Cyan
    Invoke-Expression $Command
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host $SuccessMessage -ForegroundColor Green
        return $true
    } else {
        Write-Error "$ErrorMessage Exit code: $LASTEXITCODE"
        return $false
    }
}

# Function to create Django superuser
function New-DjangoSuperuser {
    Write-Host "`nCreating Django superuser..." -ForegroundColor Yellow
    
    do {
        $username = Read-Host "Enter username for superuser"
    } while ([string]::IsNullOrWhiteSpace($username))
    
    do {
        $email = Read-Host "Enter email for superuser"
    } while ([string]::IsNullOrWhiteSpace($email) -or $email -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$')
    
    do {
        $password = Read-Host "Enter password for superuser" -AsSecureString
        $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
        )
    } while ([string]::IsNullOrWhiteSpace($plainPassword))

    # Set environment variables
    $env:DJANGO_SUPERUSER_USERNAME = $username
    $env:DJANGO_SUPERUSER_EMAIL = $email
    $env:DJANGO_SUPERUSER_PASSWORD = $plainPassword

    if (Invoke-CommandWithCheck -Command "python manage.py createsuperuser --noinput" -SuccessMessage "Superuser created successfully." -ErrorMessage "Failed to create superuser.") {
        Write-Host "`nDjango Admin Credentials:" -ForegroundColor Green
        Write-Host "URL: http://localhost:8000/admin/" -ForegroundColor Cyan
        Write-Host "Username: $username" -ForegroundColor White
        Write-Host "Email: $email" -ForegroundColor White
        Write-Host "Password: $plainPassword" -ForegroundColor White
        return $true
    }
    return $false
}

# Main script execution
try {
    Write-Host "=== Django Project Setup Script ===" -ForegroundColor Magenta
    
    # Check winget availability
    $Script:IsWingetInstalled = Test-CommandExists -Command "winget"
    
    if ($Script:IsWingetInstalled) {
        Write-Host "✓ Winget found. Will use it for installations." -ForegroundColor Green
    } else {
        Write-Error "winget is not installed. Please install it manually from Microsoft Store or GitHub."
        exit 1
    }

    # Check and install Python
    if (Test-CommandExists -Command "python") {
        Write-Host "✓ Python is already installed." -ForegroundColor Green
    } else {
        Write-Host "Installing Python..." -ForegroundColor Yellow
        Install-Package -PackageId "Python.Python.3" -PackageName "Python"
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }

    # Check and install pip
    if (Test-CommandExists -Command "pip") {
        Write-Host "✓ pip is already installed." -ForegroundColor Green
    } else {
        Write-Warning "pip not found. It should come with Python. Please check your Python installation."
    }

    # Check and install pipenv
    if (Test-CommandExists -Command "pipenv") {
        Write-Host "✓ pipenv is already installed." -ForegroundColor Green
    } else {
        Write-Host "Installing pipenv..." -ForegroundColor Yellow
        if (-not (Invoke-CommandWithCheck -Command "pip install pipenv" -SuccessMessage "pipenv installed successfully." -ErrorMessage "Failed to install pipenv.")) {
            exit 1
        }
    }

    # Install dependencies
    Write-Host "`nInstalling project dependencies..." -ForegroundColor Yellow
    if (-not (Invoke-CommandWithCheck -Command "pipenv install" -SuccessMessage "Dependencies installed successfully." -ErrorMessage "Failed to install dependencies.")) {
        exit 1
    }

    # Run migrations
    Write-Host "`nRunning Django migrations..." -ForegroundColor Yellow
    
    if (-not (Invoke-CommandWithCheck -Command "pipenv run python manage.py makemigrations" -SuccessMessage "Migrations created successfully." -ErrorMessage "Failed to create migrations.")) {
        exit 1
    }
    
    if (-not (Invoke-CommandWithCheck -Command "pipenv run python manage.py migrate" -SuccessMessage "Migrations applied successfully." -ErrorMessage "Failed to apply migrations.")) {
        exit 1
    }

    # Create superuser
    $createSuperuser = Read-Host "`nWould you like to create a Django superuser? (y/N)"
    if ($createSuperuser -match '^[Yy]') {
        if (-not (New-DjangoSuperuser)) {
            Write-Warning "Superuser creation failed, but continuing with setup."
        }
    }

    # Final instructions
    Write-Host "`n=== Setup Complete ===" -ForegroundColor Green
    Write-Host "To start the development server, run:" -ForegroundColor Cyan
    Write-Host "  pipenv run python manage.py runserver" -ForegroundColor White
    Write-Host "`nTo enter the virtual environment, run:" -ForegroundColor Cyan
    Write-Host "  pipenv shell" -ForegroundColor White
    
    # Ask if user wants to start the server now
    $startServer = Read-Host "`nWould you like to start the Django development server now? (y/N)"
    if ($startServer -match '^[Yy]') {
        Write-Host "`nStarting Django development server..." -ForegroundColor Yellow
        pipenv run python manage.py runserver
    }

} catch {
    Write-Error "An unexpected error occurred: $_"
    exit 1
} finally {
    # Cleanup sensitive environment variables
    Remove-Item Env:DJANGO_SUPERUSER_USERNAME -ErrorAction SilentlyContinue
    Remove-Item Env:DJANGO_SUPERUSER_EMAIL -ErrorAction SilentlyContinue
    Remove-Item Env:DJANGO_SUPERUSER_PASSWORD -ErrorAction SilentlyContinue
}