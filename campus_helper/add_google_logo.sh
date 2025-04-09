#!/bin/bash

# Create the directory if it doesn't exist
mkdir -p assets/images

# Download the Google logo
curl -s -o assets/images/google_logo.png https://www.google.com/images/branding/googleg/1x/googleg_standard_color_128dp.png

# Verify the download
if [ -f assets/images/google_logo.png ]; then
    echo "Google logo downloaded successfully to assets/images/google_logo.png"
    # Check if pubspec.yaml already has the asset entry
    if ! grep -q "assets/images/google_logo.png" pubspec.yaml; then
        echo "Make sure to add the image to your pubspec.yaml assets section if not already included."
    fi
else
    echo "Failed to download Google logo"
fi 