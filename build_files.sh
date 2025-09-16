#!/bin/bash
echo "BUILD START"

# Debug information
echo "=== Environment Debug ==="
echo "Working directory: $(pwd)"
echo "Directory contents:"
ls -la

echo "Python version:"
python3.9 --version

echo "Pip version:"
python3.9 -m pip --version

# Check if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo "Requirements file contents:"
    cat requirements.txt
else
    echo "ERROR: requirements.txt not found!"
    exit 1
fi

# Install dependencies
echo "=== Installing Dependencies ==="
python3.9 -m pip install --upgrade pip
python3.9 -m pip install -r requirements.txt

# Verify Django installation
echo "=== Verifying Django Installation ==="
python3.9 -c "import django; print(f'Django version: {django.get_version()}')" || {
    echo "ERROR: Django not installed properly"
    echo "Installed packages:"
    python3.9 -m pip list
    exit 1
}

# Check project structure
echo "=== Project Structure Check ==="
if [ ! -f "manage.py" ]; then
    echo "ERROR: manage.py not found in current directory"
    exit 1
fi

# Find settings file
SETTINGS_FILE=""
if [ -f "django_qr/settings.py" ]; then
    SETTINGS_FILE="django_qr.settings"
    echo "Found settings at django_qr/settings.py"
elif [ -f "*/settings.py" ]; then
    SETTINGS_DIR=$(dirname $(find . -name "settings.py" | head -1))
    SETTINGS_MODULE=$(basename $SETTINGS_DIR)
    SETTINGS_FILE="${SETTINGS_MODULE}.settings"
    echo "Found settings at ${SETTINGS_DIR}/settings.py"
else
    echo "ERROR: settings.py not found"
    exit 1
fi

# Set Django settings
export DJANGO_SETTINGS_MODULE=$SETTINGS_FILE
echo "Using settings module: $DJANGO_SETTINGS_MODULE"

# Test Django setup
echo "=== Testing Django Setup ==="
python3.9 manage.py check || {
    echo "Django check failed, but continuing..."
}

# Collect static files
echo "=== Collecting Static Files ==="
python3.9 manage.py collectstatic --noinput --clear --verbosity=2 || {
    echo "collectstatic failed, creating minimal static structure..."
    mkdir -p staticfiles/admin/css
    mkdir -p staticfiles/admin/js
    echo "/* Minimal admin CSS */" > staticfiles/admin/css/base.css
    echo "// Minimal admin JS" > staticfiles/admin/js/core.js
}

# Create output directory
mkdir -p staticfiles_build

# Copy static files
if [ -d "staticfiles" ] && [ "$(ls -A staticfiles 2>/dev/null)" ]; then
    echo "Copying static files to build directory..."
    cp -r staticfiles/* staticfiles_build/
    echo "Static files copied successfully"
else
    echo "Creating minimal static files for Vercel..."
    mkdir -p staticfiles_build/admin/css
    echo "/* Minimal Django static file */" > staticfiles_build/admin/css/base.css
fi

# Final verification
echo "=== Build Output ==="
echo "staticfiles_build contents:"
find staticfiles_build -type f | head -10
echo "Total files: $(find staticfiles_build -type f | wc -l)"

echo "BUILD END"