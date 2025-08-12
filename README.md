# RentoShare Backend API

A Django REST Framework based backend application for RentoShare - a platform for sharing and renting items within communities.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [API Documentation](#api-documentation)
- [Authentication](#authentication)
- [Endpoints](#endpoints)
- [Setup Guide](#setup-guide)

## 🚀 Prerequisites

Before you begin, you'll need:

1. **Git** - Version control system
2. **Python 3.8+** - Programming language
3. **pipenv** - Python dependency management

## 🏁 Quick Start

1. Clone the repository:

```bash
git clone <repository-url>
cd rentoshare_backend
```

2. Install dependencies:

```bash
pipenv install
```

3. Activate virtual environment:

```bash
pipenv shell
```

4. Run migrations:

```bash
python manage.py migrate
```

5. Start the development server:

```bash
python manage.py runserver
```

The API will be available at `http://127.0.0.1:8000/`

## 🔐 Authentication

This API uses JWT (JSON Web Token) authentication. Most endpoints require authentication.

### Authentication Headers

```
Authorization: Bearer <your-jwt-token>
```

### Getting Tokens

- **Login**: `POST /api/auth/jwt/create/`
- **Refresh Token**: `POST /api/auth/jwt/refresh/`

## 📚 API Documentation

All API endpoints are prefixed with `/api/`. The API follows RESTful conventions and returns JSON responses.

### Base URL: `http://127.0.0.1:8000/api/`

---

## 🔐 Authentication Endpoints

### User Registration

- **Endpoint**: `POST /api/auth/users/`
- **Auth Required**: No
- **Description**: Register a new user account

**Request Body:**

```json
{
	"email": "user@example.com",
	"password": "securepassword123",
	"full_name": "John Doe",
	"phone": "+1234567890",
	"role": "vendor" // or "consumer"
}
```

**Response:**

```json
{
	"id": 1,
	"email": "user@example.com",
	"full_name": "John Doe"
}
```

### User Login

- **Endpoint**: `POST /api/auth/jwt/create/`
- **Auth Required**: No
- **Description**: Login and get JWT tokens

**Request Body:**

```json
{
	"email": "user@example.com",
	"password": "securepassword123"
}
```

**Response:**

```json
{
	"access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
	"refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

### Refresh Token

- **Endpoint**: `POST /api/auth/jwt/refresh/`
- **Auth Required**: No
- **Description**: Refresh access token

**Request Body:**

```json
{
	"refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

---

## 🏠 Listings Endpoints

### Get All Listings

- **Endpoint**: `GET /api/listings/`
- **Auth Required**: No
- **Description**: Get all active listings
- **Query Parameters**:
    - `listing_type`: Filter by type (product, service, donation)
    - `search`: Search in title and description

**Response:**

```json
[
	{
		"id": 1,
		"title": "Electric Drill",
		"description": "Powerful electric drill for rent",
		"listing_type": "product",
		"price_per_day": 15.0,
		"location": "Downtown",
		"is_active": true,
		"user": {
			"id": 1,
			"email": "vendor@example.com",
			"full_name": "John Vendor"
		}
	}
]
```

### Create Listing

- **Endpoint**: `POST /api/listings/`
- **Auth Required**: Yes
- **Description**: Create a new listing

**Request Body:**

```json
{
	"title": "Electric Drill",
	"description": "Powerful electric drill for rent",
	"listing_type": "product",
	"price_per_day": 15.0,
	"location": "Downtown",
	"available_from": "2025-08-15T09:00:00Z",
	"available_to": "2025-12-31T18:00:00Z"
}
```

### Get Single Listing

- **Endpoint**: `GET /api/listings/{id}/`
- **Auth Required**: No
- **Description**: Get detailed listing information

### Update Listing

- **Endpoint**: `PUT /api/listings/{id}/`
- **Auth Required**: Yes (Owner only)
- **Description**: Update listing details

### Delete Listing

- **Endpoint**: `DELETE /api/listings/{id}/`
- **Auth Required**: Yes (Owner only)
- **Description**: Delete a listing

---

## 🔍 KYC (Know Your Customer) Endpoints

### Submit KYC

- **Endpoint**: `POST /api/kyc/create/`
- **Auth Required**: Yes
- **Description**: Submit KYC documents for verification

**Request Body:**

```json
{
	"gov_id_number": "ID123456789",
	"document_type": "national_id",
	"document_front_picture": "https://example.com/front.jpg",
	"document_back_picture": "https://example.com/back.jpg",
	"permanent_address": "123 Main St, City",
	"temp_address": "456 Temp St, City",
	"date_of_birth": "1990-01-01",
	"nationality": "Country",
	"occupation": "Software Developer",
	"annual_income": 50000.0,
	"emergency_contact_name": "Jane Doe",
	"emergency_contact_phone": "+1234567890",
	"emergency_contact_relation": "Sister"
}
```

### Get My KYC Status

- **Endpoint**: `GET /api/kyc/`
- **Auth Required**: Yes
- **Description**: Get current user's KYC status

**Response:**

```json
{
	"id": 1,
	"kyc_status": "pending",
	"is_verified": false,
	"submitted_at": "2025-08-12T10:00:00Z",
	"document_type": "national_id"
}
```

### Check User KYC Status (Public)

- **Endpoint**: `GET /api/kyc/public/{user_id}/`
- **Auth Required**: No
- **Description**: Check if a user is KYC verified (public info only)

**Response:**

```json
{
	"user_email": "user@example.com",
	"is_verified": true,
	"kyc_status": "approved",
	"verified_at": "2025-08-12T15:30:00Z"
}
```

### Admin: List All KYCs

- **Endpoint**: `GET /api/kyc/admin/list/`
- **Auth Required**: Yes (Admin only)
- **Query Parameters**: `status` (pending, approved, rejected, under_review)

### Admin: Update KYC Status

- **Endpoint**: `PUT /api/kyc/admin/{kyc_id}/status/`
- **Auth Required**: Yes (Admin only)

**Request Body:**

```json
{
	"kyc_status": "approved", // or "rejected"
	"rejection_reason": "Invalid document" // required if rejected
}
```

---

## 💰 Transaction Endpoints

### Create Transaction

- **Endpoint**: `POST /api/transactions/create/`
- **Auth Required**: Yes
- **Description**: Create a rental transaction

**Request Body:**

```json
{
	"listing": 1,
	"start_date": "2025-08-15T09:00:00Z",
	"end_date": "2025-08-20T18:00:00Z"
}
```

### Get My Transactions

- **Endpoint**: `GET /api/transactions/`
- **Auth Required**: Yes
- **Description**: Get all transactions (as vendor or consumer)

**Response:**

```json
[
	{
		"id": 1,
		"listing_title": "Electric Drill",
		"vendor_email": "vendor@example.com",
		"consumer_email": "consumer@example.com",
		"start_date": "2025-08-15T09:00:00Z",
		"end_date": "2025-08-20T18:00:00Z",
		"total_price": 75.0,
		"status": "active",
		"duration_days": 5
	}
]
```

### Get Transaction Details

- **Endpoint**: `GET /api/transactions/{id}/`
- **Auth Required**: Yes (Participants only)

### Update Transaction Status

- **Endpoint**: `PUT /api/transactions/{id}/status/`
- **Auth Required**: Yes (Vendor only)

**Request Body:**

```json
{
	"status": "completed" // pending, active, completed, cancelled, disputed
}
```

### Get Transaction Statistics

- **Endpoint**: `GET /api/transactions/stats/`
- **Auth Required**: Yes
- **Description**: Get user's transaction statistics

**Response:**

```json
{
	"vendor_stats": {
		"total": 15,
		"active": 3,
		"completed": 10,
		"total_earnings": 1250.0
	},
	"consumer_stats": {
		"total": 8,
		"active": 2,
		"completed": 6,
		"total_spent": 450.0
	}
}
```

---

## ⭐ Review Endpoints

### Create Review

- **Endpoint**: `POST /api/reviews/create/`
- **Auth Required**: Yes
- **Description**: Create a review for another user

**Request Body:**

```json
{
	"reviewed": 2,
	"rating": 4.5,
	"comment": "Great experience! Very reliable and friendly."
}
```

### Get My Given Reviews

- **Endpoint**: `GET /api/reviews/`
- **Auth Required**: Yes
- **Description**: Get reviews I have given to others

### Get My Received Reviews

- **Endpoint**: `GET /api/reviews/received/`
- **Auth Required**: Yes
- **Description**: Get reviews I have received from others

### Get User's Reviews (Public)

- **Endpoint**: `GET /api/reviews/user/{user_id}/`
- **Auth Required**: No
- **Description**: Get all reviews for a specific user

**Response:**

```json
[
	{
		"id": 1,
		"reviewer_name": "John Smith",
		"rating": 4.5,
		"comment": "Great experience!",
		"created_at": "2025-08-12T10:00:00Z"
	}
]
```

### Get User Rating Statistics

- **Endpoint**: `GET /api/reviews/user/{user_id}/stats/`
- **Auth Required**: No
- **Description**: Get rating statistics for a user

**Response:**

```json
{
	"average_rating": 4.2,
	"total_reviews": 25,
	"rating_distribution": {
		"1": 1,
		"2": 2,
		"3": 5,
		"4": 8,
		"5": 9
	}
}
```

### Get My Rating Statistics

- **Endpoint**: `GET /api/reviews/stats/`
- **Auth Required**: Yes

---

## 🚨 Dispute Endpoints

### Create Dispute

- **Endpoint**: `POST /api/disputes/create/`
- **Auth Required**: Yes
- **Description**: Raise a dispute for a transaction

**Request Body:**

```json
{
	"transaction": 1,
	"reason": "Item was not as described and had damages"
}
```

### Get My Disputes

- **Endpoint**: `GET /api/disputes/`
- **Auth Required**: Yes
- **Description**: Get all disputes I'm involved in

**Response:**

```json
[
	{
		"id": 1,
		"transaction_id": 5,
		"raised_by_email": "consumer@example.com",
		"reason": "Item was damaged",
		"status": "open",
		"created_at": "2025-08-12T10:00:00Z"
	}
]
```

### Get Dispute Details

- **Endpoint**: `GET /api/disputes/{id}/`
- **Auth Required**: Yes (Participants only)

### Get Dispute Statistics

- **Endpoint**: `GET /api/disputes/stats/`
- **Auth Required**: Yes

**Response:**

```json
{
	"raised_by_me": {
		"total": 3,
		"open": 1,
		"resolved": 2,
		"rejected": 0
	},
	"involving_me": {
		"total": 5,
		"open": 2,
		"resolved": 3,
		"rejected": 0
	}
}
```

### Admin: List All Disputes

- **Endpoint**: `GET /api/disputes/admin/list/`
- **Auth Required**: Yes (Admin only)
- **Query Parameters**: `status` (open, resolved, rejected)

### Admin: Resolve Dispute

- **Endpoint**: `PUT /api/disputes/admin/{id}/resolve/`
- **Auth Required**: Yes (Admin only)

**Request Body:**

```json
{
	"status": "resolved",
	"resolution_notes": "Refund has been processed to the consumer"
}
```

---

## 🎁 Donation Request Endpoints

### Create Donation Request

- **Endpoint**: `POST /api/donations/create/`
- **Auth Required**: Yes
- **Description**: Request a donation item

**Request Body:**

```json
{
	"listing": 1,
	"message": "I really need this for my studies. Would be very grateful!"
}
```

### Get My Donation Requests

- **Endpoint**: `GET /api/donations/`
- **Auth Required**: Yes
- **Description**: Get donation requests I have made

### Get Received Donation Requests

- **Endpoint**: `GET /api/donations/received/`
- **Auth Required**: Yes
- **Description**: Get donation requests for my listings

**Response:**

```json
[
	{
		"id": 1,
		"listing_title": "Old Textbooks",
		"user_email": "student@example.com",
		"user_name": "Jane Student",
		"message": "Need for studies",
		"status": "pending",
		"created_at": "2025-08-12T10:00:00Z"
	}
]
```

### Update Donation Request Status

- **Endpoint**: `PUT /api/donations/{id}/status/`
- **Auth Required**: Yes (Listing owner only)

**Request Body:**

```json
{
	"status": "accepted" // or "rejected"
}
```

### Get Donation Statistics

- **Endpoint**: `GET /api/donations/stats/`
- **Auth Required**: Yes

**Response:**

```json
{
	"requests_made": {
		"total": 5,
		"pending": 2,
		"accepted": 2,
		"rejected": 1
	},
	"requests_received": {
		"total": 8,
		"pending": 3,
		"accepted": 4,
		"rejected": 1
	}
}
```

### Get Listing Donation Requests (Public)

- **Endpoint**: `GET /api/donations/listing/{listing_id}/`
- **Auth Required**: No
- **Description**: Get accepted donation requests for a listing

---

## 📊 Response Format

### Success Response

```json
{
    "status": "success",
    "data": { ... }
}
```

### Error Response

```json
{
	"status": "error",
	"message": "Error description",
	"errors": {
		"field_name": ["Error message"]
	}
}
```

### HTTP Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

---

## 🔧 Development Setup

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

## 🔧 Development Setup

### Prerequisites

1. **Git** - Version control system
2. **Python 3.8+** - Programming language
3. **pipenv** - Python dependency management

### Installation Steps

1. **Clone the repository:**

```bash
git clone <repository-url>
cd rentoshare_backend
```

2. **Install pipenv (if not already installed):**

```bash
pip install pipenv
```

3. **Install dependencies:**

```bash
pipenv install
```

4. **Activate virtual environment:**

```bash
pipenv shell
```

5. **Run database migrations:**

```bash
python manage.py makemigrations
python manage.py migrate
```

6. **Create a superuser (optional):**

```bash
python manage.py createsuperuser
```

7. **Run the development server:**

```bash
python manage.py runserver
```

### Environment Variables

Create a `.env` file in the project root:

```env
DEBUG=True
SECRET_KEY=your-secret-key-here
DATABASE_URL=postgresql://user:password@localhost:5432/rentoshare_db
ALLOWED_HOSTS=localhost,127.0.0.1
```

### Database Configuration

For production, update `settings.py` to use PostgreSQL:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'rentoshare_db',
        'USER': 'your_username',
        'PASSWORD': 'your_password',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

---

## 🧪 Testing

Run tests with:

```bash
python manage.py test
```

Run specific app tests:

```bash
python manage.py test kyc
python manage.py test transactions
python manage.py test reviews
python manage.py test disputes
python manage.py test donations
```

---

## 📝 Important Notes

### Authentication Requirements

**Endpoints requiring authentication:**

- All `POST`, `PUT`, `DELETE` operations (except registration/login)
- User-specific data retrieval
- Personal statistics and dashboards

**Public endpoints (no auth required):**

- User registration and login
- Viewing listings
- Public user profiles and reviews
- KYC verification status (limited info)

### Admin-Only Endpoints

These require admin privileges:

- `/api/kyc/admin/` - KYC management
- `/api/disputes/admin/` - Dispute resolution
- `/api/transactions/admin/` - Transaction oversight

### Rate Limiting

API endpoints are rate-limited:

- **Authentication endpoints**: 5 requests per minute
- **General endpoints**: 100 requests per minute
- **Admin endpoints**: 200 requests per minute

### File Upload

For file uploads (KYC documents, listing images), use multipart/form-data:

```javascript
const formData = new FormData();
formData.append("document_front_picture", file);

fetch("/api/kyc/create/", {
	method: "POST",
	headers: {
		Authorization: "Bearer " + token,
	},
	body: formData,
});
```

---

## 🚀 Deployment

### Production Checklist

1. Set `DEBUG = False` in settings
2. Configure proper database (PostgreSQL recommended)
3. Set up static file serving
4. Configure CORS for frontend
5. Set up HTTPS
6. Configure email backend for notifications
7. Set up monitoring and logging

### Docker Deployment

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY Pipfile Pipfile.lock ./
RUN pip install pipenv && pipenv install --system --deploy

COPY . .
RUN python manage.py collectstatic --noinput

EXPOSE 8000
CMD ["gunicorn", "rentoshare.wsgi:application", "--bind", "0.0.0.0:8000"]
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 📞 Support

For support and questions:

- Create an issue on GitHub
- Contact the development team
- Check the documentation

---

## 🔄 API Versioning

Current API version: `v1`

Future versions will be accessible via:

- `/api/v2/` for version 2
- `/api/v3/` for version 3

---

**Happy coding! 🚀**
