#!/usr/bin/env bash

# Exit script on first error
set -e

# Function to check dependencies
check_dependencies() {
    command -v git >/dev/null 2>&1 || { echo >&2 "I require git but it's not installed.  Aborting."; exit 1; }
    command -v cp >/dev/null 2>&1 || { echo >&2 "I require cp but it's not installed.  Aborting."; exit 1; }
    command -v find >/dev/null 2>&1 || { echo >&2 "I require find but it's not installed.  Aborting."; exit 1; }
    command -v sed >/dev/null 2>&1 || { echo >&2 "I require sed but it's not installed.  Aborting."; exit 1; }
}

# Main script function
main() {
    # Get start time
    local start_time=$(date +%s)
    # Clone the Moodle repository
    echo "Cloning the Moodle repository..."
    git clone --depth 1 -b MOODLE_403_STABLE https://github.com/moodle/moodle.git www

    # Create the php_config directory
    echo "Creating the php_config directory..."
    mkdir -p php_config

    # Find and copy the php.ini file
    echo "Finding and copying the php.ini file..."
    cp "$(find /nix/store -name 'php.ini' -path '*php-8.1.27/etc*' -print -quit)" php_config/php.ini

    # Find and copy the extensions.ini file
    echo "Finding and copying the extensions.ini file..."
    cp "$(find /nix/store -name 'php.ini' -path '*php-with-extensions-8.1.27/lib*' -print -quit)" php_config/extensions.ini

    # Increase max_input_vars value for Moodle
    echo "Increasing max_input_vars value for Moodle..."
    sed -i 's/;max_input_vars = 1000/max_input_vars = 6000/' php_config/php.ini

     # Get end time and calculate duration
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo "Script completed in $duration seconds."
}

# Check dependencies before running script
check_dependencies

# Run main script function
main