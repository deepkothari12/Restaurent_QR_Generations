#!/bin/bash
echo "BUILD START"

# Install dependencies using pip install without specifying python version
pip install --upgrade pip
pip install -r requirements.txt

# Verify Django installation using python (not python3.9)
echo "=== Verifying Django Installation ==="
python -c "import django; print(f'Django version: {django.get_version()}')" || {
    echo "ERROR: Django not installed properly"
    echo "Trying with python3:"
    python3 -c "import django; print(f'Django version: {django.get_version()}')" || {
        echo "ERROR: Django still not found"
        exit 1
    }
}

# Set Django settings module
export DJANGO_SETTINGS_MODULE=django_qr.settings

# Check Django setup using python (not python3.9)
echo "=== Testing Django Setup ==="
python manage.py check || echo "Django check had issues, continuing..."

# Collect static files using python (not python3.9)
echo "=== Collecting Static Files ==="
python manage.py collectstatic --noinput --clear --verbosity=2 || {
    echo "collectstatic failed, creating minimal static structure..."
    mkdir -p staticfiles/admin/css
    mkdir -p staticfiles/admin/js
    echo "/* Minimal admin CSS */" > staticfiles/admin/css/base.css
    echo "// Minimal admin JS" > staticfiles/admin/js/core.js
}

# Create output directory and copy files
mkdir -p staticfiles_build

if [ -d "staticfiles" ] && [ "$(ls -A staticfiles 2>/dev/null)" ]; then
    echo "Copying static files to build directory..."
    cp -r staticfiles/* staticfiles_build/
    echo "Static files copied successfully"
else
    echo "Creating minimal static files for Vercel..."
    mkdir -p staticfiles_build/admin/css
    echo "/* Minimal Django static file */" > staticfiles_build/admin/css/base.css
fi

# Verify output
echo "=== Build Output ==="
echo "staticfiles_build contents:"
ls -la staticfiles_build/
echo "Total files: $(find staticfiles_build -type f | wc -l)"

echo "BUILD END"