---
name: setup-django
description: Sets up a new Django project with RAPID architecture using uv. Creates horizontal layer structure with DRF, Docker/PostgreSQL support, and environment-based configuration. Use when the user wants to initialise a Django web application.
user-invocable: true
allowed-tools: Bash, Write, AskUserQuestion
---

# Setting Up a Django Project with RAPID Architecture

## Overview

This skill scaffolds a Django project using the RAPID horizontal layer architecture:
- **R**eaders - Read-only business logic
- **A**ctions - State-changing business logic
- **P**resentation (Interfaces) - HTTP endpoints, management commands, templates
- **I**nformation (Data) - Models and migrations
- **D**omain - The project configuration

## Workflow

### Step 1: Gather Project Details

Ask the user for:
1. **Python version** - default to 3.12 if not specified
2. **Project description** (optional) - for pyproject.toml and README

### Step 2: Initialise with uv

Run from the current directory (user has already created and cd'd into it):

```bash
uv init . --python <version>
```

### Step 3: Add Dependencies

Add runtime dependencies:

```bash
uv add django djangorestframework psycopg dj-database-url python-dotenv
```

Add dev dependencies:

```bash
uv add --dev ipython jupyterlab ruff pytest pytest-django pytest-cov
```

### Step 4: Create RAPID Directory Structure

Get the project name from the current directory:

```bash
PROJECT_NAME=$(basename "$(pwd)")
PACKAGE_NAME=$(echo "$PROJECT_NAME" | tr '-' '_')
```

Create the RAPID structure:

```bash
mkdir -p "$PACKAGE_NAME/data/migrations"
mkdir -p "$PACKAGE_NAME/data/models"
mkdir -p "$PACKAGE_NAME/readers"
mkdir -p "$PACKAGE_NAME/actions"
mkdir -p "$PACKAGE_NAME/interfaces/http/api"
mkdir -p "$PACKAGE_NAME/interfaces/http/templates"
mkdir -p "$PACKAGE_NAME/interfaces/management_commands/management/commands"
mkdir -p tests
mkdir -p scratch/scripts
mkdir -p scratch/nbs
```

Directory purposes:
- `<package>/data/models/` - Django models
- `<package>/data/migrations/` - Database migrations
- `<package>/readers/` - Read-only queries and data retrieval
- `<package>/actions/` - State-changing business logic
- `<package>/interfaces/http/api/` - DRF views, serializers, URLs
- `<package>/interfaces/http/templates/` - HTML templates
- `<package>/interfaces/management_commands/management/commands/` - Custom management commands
- `tests/` - Test files
- `scratch/` - Throwaway scripts and notebooks (gitignored)

### Step 5: Create Django Configuration Files

Create `<package>/__init__.py`:

```python
"""<project-name> Django application."""
```

Create `<package>/settings.py`:

```python
"""Django settings for <project-name>."""

import os
from pathlib import Path

import dj_database_url
from dotenv import load_dotenv

load_dotenv()

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = os.environ.get("SECRET_KEY", "django-insecure-change-me-in-production")

DEBUG = os.environ.get("DEBUG", "true").lower() in ("true", "1", "yes")

ALLOWED_HOSTS = [
    h.strip()
    for h in os.environ.get("ALLOWED_HOSTS", "localhost,127.0.0.1").split(",")
    if h.strip()
]

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "rest_framework",
    "<package_name>.data",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "<package_name>.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [BASE_DIR / "<package_name>" / "interfaces" / "http" / "templates"],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "<package_name>.wsgi.application"

DATABASE_URL = os.environ.get(
    "DATABASE_URL",
    "postgres://postgres:postgres@localhost:5432/<package_name>",
)
DATABASES = {"default": dj_database_url.parse(DATABASE_URL)}

AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

LANGUAGE_CODE = "en-gb"
TIME_ZONE = "UTC"
USE_I18N = True
USE_TZ = True

STATIC_URL = "static/"
STATIC_ROOT = BASE_DIR / "staticfiles"

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

REST_FRAMEWORK = {
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.AllowAny",
    ],
}
```

Create `<package>/urls.py`:

```python
"""URL configuration for <project-name>."""

from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/", include("<package_name>.interfaces.http.api.urls")),
]
```

Create `<package>/wsgi.py`:

```python
"""WSGI config for <project-name>."""

import os

from django.core.wsgi import get_wsgi_application

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "<package_name>.settings")

application = get_wsgi_application()
```

Create `<package>/asgi.py`:

```python
"""ASGI config for <project-name>."""

import os

from django.core.asgi import get_asgi_application

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "<package_name>.settings")

application = get_asgi_application()
```

### Step 6: Create Data Layer Files

Create `<package>/data/__init__.py`:

```python
"""Data layer - models and migrations."""
```

Create `<package>/data/apps.py`:

```python
"""Django app configuration for the data layer."""

from django.apps import AppConfig


class DataConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "<package_name>.data"
    label = "data"
```

Create `<package>/data/models/__init__.py`:

```python
"""Models for <project-name>."""

# Example model (uncomment and modify as needed):
#
# from django.db import models
#
#
# class Example(models.Model):
#     """Example model."""
#
#     name = models.CharField(max_length=255)
#     created_at = models.DateTimeField(auto_now_add=True)
#
#     class Meta:
#         db_table = "example"
#
#     def __str__(self):
#         return self.name
```

Create `<package>/data/migrations/__init__.py`:

```python
```

### Step 7: Create Reader and Action Layers

Create `<package>/readers/__init__.py`:

```python
"""Readers - read-only business logic.

Readers contain functions that retrieve and process data without side effects.
They should not modify database state or trigger external actions.

Example:

    def get_user_dashboard_data(user_id: int) -> dict:
        user = User.objects.get(id=user_id)
        return {
            "name": user.name,
            "recent_orders": list(user.orders.order_by("-created")[:5].values()),
        }
"""
```

Create `<package>/actions/__init__.py`:

```python
"""Actions - state-changing business logic.

Actions contain functions that modify state, either in the database or externally.
They encapsulate business rules and coordinate changes.

Example:

    def create_order(user_id: int, items: list[dict]) -> Order:
        user = User.objects.get(id=user_id)
        order = Order.objects.create(user=user, total=calculate_total(items))
        for item in items:
            OrderItem.objects.create(order=order, **item)
        send_order_confirmation_email(user, order)
        return order
"""
```

### Step 8: Create Interface Layer Files

Create `<package>/interfaces/__init__.py`:

```python
"""Interfaces - HTTP endpoints, management commands, templates."""
```

Create `<package>/interfaces/http/__init__.py`:

```python
"""HTTP interface."""
```

Create `<package>/interfaces/http/api/__init__.py`:

```python
"""API views and URLs."""
```

Create `<package>/interfaces/http/api/urls.py`:

```python
"""API URL configuration."""

from django.urls import path

from . import views

urlpatterns = [
    path("health/", views.health_check, name="health-check"),
]
```

Create `<package>/interfaces/http/api/views.py`:

```python
"""API views."""

from rest_framework.decorators import api_view
from rest_framework.response import Response


@api_view(["GET"])
def health_check(request):
    """Health check endpoint."""
    return Response({"status": "ok"})
```

Create `<package>/interfaces/management_commands/__init__.py`:

```python
"""Management commands interface."""
```

Create `<package>/interfaces/management_commands/management/__init__.py`:

```python
```

Create `<package>/interfaces/management_commands/management/commands/__init__.py`:

```python
```

### Step 9: Create manage.py

Create `manage.py` in the project root:

```python
#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""

import os
import sys


def main():
    """Run administrative tasks."""
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "<package_name>.settings")
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed?"
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == "__main__":
    main()
```

Make it executable:

```bash
chmod +x manage.py
```

### Step 10: Create Docker Configuration

Create `Dockerfile`:

```dockerfile
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

COPY pyproject.toml uv.lock* ./
RUN uv sync --frozen --no-install-project

COPY . .
RUN uv sync --frozen

EXPOSE 8000

CMD ["uv", "run", "python", "manage.py", "runserver", "0.0.0.0:8000"]
```

Create `docker-compose.yml`:

```yaml
services:
  db:
    image: postgres:16
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: <package_name>
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"

  web:
    build: .
    command: uv run python manage.py runserver 0.0.0.0:8000
    volumes:
      - .:/app
    ports:
      - "8000:8000"
    depends_on:
      - db
    environment:
      DATABASE_URL: postgres://postgres:postgres@db:5432/<package_name>
      DEBUG: "true"
      SECRET_KEY: django-insecure-dev-only-change-in-production

volumes:
  postgres_data:
```

Create `.env.example`:

```bash
DEBUG=true
SECRET_KEY=django-insecure-change-me-in-production
DATABASE_URL=postgres://postgres:postgres@localhost:5432/<package_name>
ALLOWED_HOSTS=localhost,127.0.0.1
```

### Step 11: Create Project Files

Create `tests/__init__.py`:

```python
```

Create `tests/conftest.py`:

```python
"""Pytest configuration."""

import django
from django.conf import settings


def pytest_configure():
    """Configure Django settings for pytest."""
    if not settings.configured:
        django.setup()
```

Create `tests/test_health.py`:

```python
"""Test health check endpoint."""

import pytest
from rest_framework.test import APIClient


@pytest.fixture
def api_client():
    return APIClient()


@pytest.mark.django_db
def test_health_check(api_client):
    response = api_client.get("/api/health/")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
```

Create `pytest.ini`:

```ini
[pytest]
DJANGO_SETTINGS_MODULE = <package_name>.settings
python_files = test_*.py
python_classes = Test*
python_functions = test_*
```

Create `.gitignore`:

```
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
*.egg-info/
.eggs/
dist/
build/

# Environment
.env
.venv/
venv/

# IDE
.idea/
.vscode/
*.swp
*.swo

# Project
scratch/
staticfiles/
*.sqlite3
.coverage
htmlcov/

# Docker
postgres_data/
```

Create `README.md`:

```markdown
# <project-name>

<description if provided>

## Development

### Local Development

```bash
# Start PostgreSQL
docker compose up -d db

# Run migrations
just migrate

# Start development server
just run
```

### Docker Development

```bash
# Start all services
just docker-up

# Run migrations
just docker-migrate
```

## Commands

Run `just` to see all available commands.
```

Create `CLAUDE.md`:

```markdown
# <project-name>

Django application using RAPID horizontal layer architecture with uv for dependency management.

## Commands

Run `just` to see available commands.

Key commands:
- `just run` - Start development server
- `just migrate` - Run database migrations
- `just test` - Run tests
- `just shell` - Django shell with IPython

## RAPID Architecture

This project follows the RAPID horizontal layer architecture:

### Data Layer (`<package>/data/`)
- `models/` - Django model definitions
- `migrations/` - Database migrations

### Readers (`<package>/readers/`)
Read-only business logic. Functions that retrieve and process data without side effects.

### Actions (`<package>/actions/`)
State-changing business logic. Functions that modify database state or trigger external actions.

### Interfaces (`<package>/interfaces/`)
- `http/api/` - DRF views, serializers, and URLs
- `http/templates/` - HTML templates
- `management_commands/management/commands/` - Custom Django management commands

## Dependencies

- Add runtime deps: `uv add <package>`
- Add dev deps: `uv add --dev <package>`
- Run anything: `uv run <command>`

## Environment Variables

Copy `.env.example` to `.env` and configure:
- `DEBUG` - Enable debug mode (default: true)
- `SECRET_KEY` - Django secret key (required in production)
- `DATABASE_URL` - PostgreSQL connection string
- `ALLOWED_HOSTS` - Comma-separated list of allowed hosts
```

Create `justfile`:

```just
# List available commands
default:
    @just --list

# Run development server
run:
    uv run python manage.py runserver

# Run database migrations
migrate:
    uv run python manage.py migrate

# Create new migration
makemigrations *args:
    uv run python manage.py makemigrations {{args}}

# Run tests
test *args:
    uv run pytest {{args}}

# Run tests with coverage
test-cov:
    uv run pytest --cov

# Format code
fmt:
    uv run ruff format .

# Lint code
lint:
    uv run ruff check .

# Lint and fix
lint-fix:
    uv run ruff check . --fix

# Format and lint
check: fmt lint

# Django shell with IPython
shell:
    uv run python manage.py shell -i ipython

# Create superuser
createsuperuser:
    uv run python manage.py createsuperuser

# Collect static files
collectstatic:
    uv run python manage.py collectstatic --noinput

# Start Jupyter Lab
jupyter:
    uv run jupyter lab

# Docker: start all services
docker-up:
    docker compose up -d

# Docker: stop all services
docker-down:
    docker compose down

# Docker: run migrations
docker-migrate:
    docker compose exec web uv run python manage.py migrate

# Docker: view logs
docker-logs:
    docker compose logs -f

# Docker: shell into web container
docker-shell:
    docker compose exec web bash
```

### Step 12: Git Repository Setup

**First, discover available GitHub organisations:**

```bash
gh org list
```

Then ask the user using AskUserQuestion with these options:

1. **No remote** - Keep it local only
2. **Public repository (personal)** - Create public repo in personal account
3. **Private repository (personal)** - Create private repo in personal account
4. **Organisation repository** - Show list of orgs from `gh org list` and let user pick, then ask public/private

**If user selects organisation**, present the orgs discovered and ask which one, then ask public or private.

**Creating the repository:**

For personal repos:
```bash
gh repo create <repo-name> --public|--private --source . --push
```

For organisation repos:
```bash
gh repo create <org-name>/<repo-name> --public|--private --source . --push
```

If no remote wanted:
```bash
git init
git add .
git commit -m "Initial commit: scaffold Django project with RAPID architecture"
```

### Step 13: Verify Setup

Start PostgreSQL and run migrations:

```bash
docker compose up -d db
uv run python manage.py migrate
```

Verify the development server starts:

```bash
uv run python manage.py runserver &
sleep 3
curl -s http://localhost:8000/api/health/ | grep -q '"status":"ok"' && echo "Health check passed" || echo "Health check failed"
kill %1 2>/dev/null
```

Run tests:

```bash
uv run pytest
```

## Checklist

- [ ] Confirm Python version (default 3.12)
- [ ] Get optional project description
- [ ] Run `uv init .`
- [ ] Add runtime dependencies (django, djangorestframework, psycopg, dj-database-url, python-dotenv)
- [ ] Add dev dependencies (ipython, jupyterlab, ruff, pytest, pytest-django, pytest-cov)
- [ ] Create RAPID directory structure
- [ ] Create Django configuration (settings.py, urls.py, wsgi.py, asgi.py)
- [ ] Create data layer with models and migrations directories
- [ ] Create readers layer with example docstring
- [ ] Create actions layer with example docstring
- [ ] Create interfaces layer (HTTP API, templates, management commands)
- [ ] Create manage.py
- [ ] Create Dockerfile and docker-compose.yml
- [ ] Create .env.example
- [ ] Create test configuration and placeholder test
- [ ] Create .gitignore
- [ ] Create README.md
- [ ] Create CLAUDE.md
- [ ] Create justfile with dev commands
- [ ] Fetch available GitHub orgs with `gh org list`
- [ ] Ask about git remote setup
- [ ] Initialise git and optionally create remote
- [ ] Start PostgreSQL and run migrations
- [ ] Verify development server starts and health check passes
- [ ] Run tests

## Notes

- Always use `uv init .` in the existing directory
- The project name is derived from the current directory name
- PostgreSQL is required - the skill uses Docker to provide it locally
- RAPID architecture keeps business logic separate from Django's MTV pattern
- Readers are for queries, Actions are for mutations
- Verify uv, docker, and gh are installed before starting
- Use `gh auth status` to check GitHub authentication if needed
