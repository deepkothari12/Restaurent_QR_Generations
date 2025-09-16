#!/bin/bash
echo "BUILD START"

# Install dependencies
python3.9 -m pip install -r requirements.txt

# Collect static files into STATIC_ROOT (staticfiles/)
python3.9 manage.py collectstatic --noinput --clear

# Create output folder for Vercel and copy files
mkdir -p staticfiles_build
cp -r staticfiles/* staticfiles_build/ 2>/dev/null || echo "No static files to copy"

# List contents for debugging
echo "Contents of staticfiles_build:"
ls -la staticfiles_build/

echo "BUILD END"