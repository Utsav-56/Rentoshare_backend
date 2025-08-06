# RentoShare Backend

A Django-based backend application for RentoShare - a platform for sharing and renting items within communities.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup Guide](#detailed-setup-guide)
- [Shell-Specific Setup](#shell-specific-setup)
- [Troubleshooting](#troubleshooting)
- [Development](#development)
- [Contributing](#contributing)

## 🚀 Prerequisites

Before you begin, you'll need to have the following installed on your system:

### Required Software

1. **Git** - Version control system
2. **Python 3.8+** - Programming language
3. **Package Manager** - Depends on your operating system

### Check What You Have

Not sure what's installed? Run these commands in your terminal/command prompt:

#### Check Git Installation

```bash
git --version
```

If you see a version number, Git is installed. If not, [install Git](https://git-scm.com/downloads).

#### Check Python Installation

```bash
python --version
# or
python3 --version
```

If you see a version number (3.8 or higher), Python is ready. If not, [install Python](https://python.org/downloads).

#### Find Your Shell (For Unix-like systems)

```bash
echo $SHELL
```

Common outputs:

- `/bin/bash` = Bash shell
- `/bin/zsh` = Zsh shell
- `/usr/bin/fish` = Fish shell
- `/bin/sh` = Standard shell

#### For Windows Users

- **Command Prompt (CMD)** - Default Windows terminal
- **PowerShell** - Enhanced Windows shell
- **Git Bash** - Bash shell that comes with Git for Windows
- **WSL** - Windows Subsystem for Linux (uses Linux shells)

## 🚀 Quick Start

### Option 1: Automatic Setup (Recommended)

1. **Clone the repository:**

    ```bash
    git clone https://github.com/yourusername/rentoshare_backend.git
    cd rentoshare_backend
    ```

2. **Run the appropriate setup script:**

    **Windows (PowerShell):**

    ```powershell
    .\setup.ps1
    ```

    **Windows (Command Prompt):**

    ```cmd
    setup.bat
    ```

    **Mac/Linux (Bash):**

    ```bash
    chmod +x setup.sh
    ./setup.sh
    ```

    **Mac/Linux (Zsh):**

    ```zsh
    chmod +x setup.zsh
    ./setup.zsh
    ```

    **Fish Shell:**

    ```fish
    chmod +x setup.fish
    ./setup.fish
    ```

3. **Follow the interactive prompts** to complete setup.

4. **Start developing!** The server will be running at `http://localhost:8000`

### Option 2: Manual Setup

If automatic setup doesn't work, follow the [Detailed Setup Guide](#detailed-setup-guide) below.

## 📖 Detailed Setup Guide

### Step 1: Install Prerequisites

#### Windows

1. **Install Git:**
    - Download from [git-scm.com](https://git-scm.com/download/win)
    - Or use winget: `winget install Git.Git`

2. **Install Python:**
    - Download from [python.org](https://www.python.org/downloads/)
    - Or use winget: `winget install Python.Python.3`

3. **Install winget (if not available):**
    - Download from [Microsoft Store](https://aka.ms/getwinget)

#### macOS

1. **Install Homebrew** (package manager):

    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

2. **Install Git and Python:**
    ```bash
    brew install git python@3.11
    ```

#### Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install git python3 python3-pip
```

#### Linux (CentOS/RHEL/Fedora)

```bash
sudo yum install git python3 python3-pip
# or for newer versions
sudo dnf install git python3 python3-pip
```

### Step 2: Clone the Repository

1. **Open your terminal/command prompt**

2. **Navigate to where you want the project:**

    ```bash
    cd ~/Documents  # Example location
    ```

3. **Clone the repository:**

    ```bash
    git clone https://github.com/yourusername/rentoshare_backend.git
    ```

4. **Enter the project directory:**
    ```bash
    cd rentoshare_backend
    ```

### Step 3: Manual Environment Setup

If automatic setup scripts don't work:

1. **Install pipenv:**

    ```bash
    pip install pipenv
    # or
    pip3 install pipenv
    ```

2. **Install dependencies:**

    ```bash
    pipenv install
    ```

3. **Activate virtual environment:**

    ```bash
    pipenv shell
    ```

4. **Run database migrations:**

    ```bash
    python manage.py makemigrations
    python manage.py migrate
    ```

5. **Create a superuser (optional):**

    ```bash
    python manage.py createsuperuser
    ```

6. **Start the development server:**
    ```bash
    python manage.py runserver
    ```

## 🐚 Shell-Specific Setup

### PowerShell (Windows)

```powershell
# Set execution policy if needed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Clone and setup
git clone https://github.com/yourusername/rentoshare_backend.git
cd rentoshare_backend
.\setup.ps1
```

### Command Prompt (Windows)

```cmd
git clone https://github.com/yourusername/rentoshare_backend.git
cd rentoshare_backend
setup.bat
```

### Bash (Linux/macOS/Git Bash)

```bash
git clone https://github.com/yourusername/rentoshare_backend.git
cd rentoshare_backend
chmod +x setup.sh
./setup.sh
```

### Zsh (macOS default, Linux)

```zsh
git clone https://github.com/yourusername/rentoshare_backend.git
cd rentoshare_backend
chmod +x setup.zsh
./setup.zsh
```

### Fish Shell

```fish
git clone https://github.com/yourusername/rentoshare_backend.git
cd rentoshare_backend
chmod +x setup.fish
./setup.fish
```

## 🔧 Troubleshooting

### Common Issues

#### "Command not found" errors

**Problem:** `git: command not found` or `python: command not found`
**Solution:** Install the missing software using the links in [Prerequisites](#prerequisites)

#### Permission denied errors (Unix-like systems)

**Problem:** `Permission denied` when running setup scripts
**Solution:** Make the script executable:

```bash
chmod +x setup.sh  # or setup.zsh, setup.fish
```

#### PowerShell execution policy errors

**Problem:** `execution of scripts is disabled on this system`
**Solution:** Change execution policy:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Python version conflicts

**Problem:** Multiple Python versions installed
**Solution:** Use specific version:

```bash
python3 -m pip install pipenv
python3 manage.py runserver
```

#### Port already in use

**Problem:** `Port 8000 is already in use`
**Solution:** Use a different port:

```bash
python manage.py runserver 8001
```

#### Virtual environment issues

**Problem:** Dependencies not installing properly
**Solution:** Clear and reinstall:

```bash
pipenv --rm  # Remove existing environment
pipenv install  # Reinstall dependencies
```

### Getting Help

1. **Check our [Issues](https://github.com/yourusername/rentoshare_backend/issues)** page
2. **Create a new issue** with:
    - Your operating system
    - Your shell/terminal
    - Complete error message
    - Steps you've tried

## 🛠 Development

### Daily Development Workflow

1. **Activate virtual environment:**

    ```bash
    pipenv shell
    ```

2. **Start development server:**

    ```bash
    python manage.py runserver
    ```

3. **Access the application:**
    - API: `http://localhost:8000/`
    - Admin Panel: `http://localhost:8000/admin/`

### Useful Commands

```bash
# Install new packages
pipenv install package_name

# Install development dependencies
pipenv install package_name --dev

# Run tests
python manage.py test

# Create new migrations
python manage.py makemigrations

# Apply migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Collect static files (for production)
python manage.py collectstatic
```

### Project Structure

```
rentoshare_backend/
├── setup.ps1           # PowerShell setup script
├── setup.bat           # CMD setup script
├── setup.sh            # Bash setup script
├── setup.zsh           # Zsh setup script
├── setup.fish          # Fish setup script
├── manage.py           # Django management script
├── Pipfile             # Python dependencies
├── Pipfile.lock        # Locked dependencies
├── requirements.txt    # Alternative dependency list
├── rentoshare/         # Main Django project
└── apps/               # Django applications
```

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch:**
    ```bash
    git checkout -b feature/your-feature-name
    ```
3. **Make your changes**
4. **Run tests:**
    ```bash
    python manage.py test
    ```
5. **Commit your changes:**
    ```bash
    git commit -m "Add your feature"
    ```
6. **Push to your fork:**
    ```bash
    git push origin feature/your-feature-name
    ```
7. **Create a Pull Request**

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Still Need Help?

### Beginner Resources

- **Git Tutorial:** [Git Handbook](https://guides.github.com/introduction/git-handbook/)
- **Python Tutorial:** [Python.org Tutorial](https://docs.python.org/3/tutorial/)
- **Django Tutorial:** [Django Documentation](https://docs.djangoproject.com/en/stable/intro/tutorial01/)

### Contact

- **Email:** your.email@example.com
- **GitHub Issues:** [Create an Issue](https://github.com/yourusername/rentoshare_backend/issues/new)
- **Discord:** [Join our server](https://discord.gg/yourserver)

---

**Happy coding! 🎉**

_If this Project or Guide helped you, please give us a ⭐ on GitHub!_
