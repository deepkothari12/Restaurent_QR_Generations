echo "BUILD START"

# Install dependencies
python3.9 -m pip install -r requirements.txt

# Collect static files
python3.9 manage.py collectstatic --noinput --clear

# Create output folder for Vercel
mkdir -p staticfiles_build
cp -r staticfiles/* staticfiles_build/

echo "BUILD END"
