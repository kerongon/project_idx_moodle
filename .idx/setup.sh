#!/usr/bin/env bash

# Exit script on first error
set -e

# Function to check dependencies
check_dependencies() {
    command -v git >/dev/null 2>&1 || { echo >&2 "I require git but it's not installed.  Aborting."; exit 1; }
    command -v cp >/dev/null 2>&1 || { echo >&2 "I require cp but it's not installed.  Aborting."; exit 1; }
    command -v find >/dev/null 2>&1 || { echo >&2 "I require find but it's not installed.  Aborting."; exit 1; }
    command -v sed >/dev/null 2>&1 || { echo >&2 "I require sed but it's not installed.  Aborting."; exit 1; }
    command -v docker >/dev/null 2>&1 || { echo >&2 "I require docker but it's not installed.  Aborting."; exit 1; }
    command -v docker-compose >/dev/null 2>&1 || { echo >&2 "I require docker-compose but it's not installed.  Aborting."; exit 1; }
}

# Function to check if a file exists and create it if it doesn't
check_file() {
    # $1 is the first argument passed to the function, which should be the file path

    # Check if the file does not exist
    if [ ! -f "$1" ]; then
        # If the file does not exist, print a message
        echo "File $1 does not exist. Creating now..."

        # Create the file
        touch "$1"
    fi
}
# Function to check if directory exists
check_directory() {
    if [ ! -d "$1" ]; then
        echo "Directory $1 does not exist. Creating now..."
        mkdir -p "$1"
    fi
}

# Function to cleanup on error
cleanup() {
    echo "An error occurred. Cleaning up and removing www..."
    rm -rf "$HOME/project_idx_moodle/www"
    echo "Removing php_config..."
    rm -rf "$HOME/project_idx_moodle/php_config"
    echo "Stopping and removing Docker containers, networks, images, and volumes..."
    cd "$HOME/project_idx_moodle/.idx" && docker-compose down --rmi all --volumes
    echo "Removing moodledata folder..."
    rm -rf "$HOME/moodledata"
}
# Main script function
main() {
    # Set a trap to cleanup on error
    trap cleanup ERR
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
    cp "$(find /nix/store -name 'php.ini' -path '*php-8.1.*/etc*' -print -quit)" php_config/php.ini

    # Find and copy the extensions.ini file
    echo "Finding and copying the extensions.ini file..."
    cp "$(find /nix/store -name 'php.ini' -path '*php-with-extensions-8.1.*/lib*' -print -quit)" php_config/extensions.ini

    # Increase max_input_vars value for Moodle
    echo "Increasing max_input_vars value for Moodle..."
    sed -i 's/;max_input_vars = 1000/max_input_vars = 6000/' php_config/php.ini

     # Change to Docker Compose directory
    echo "Changing to Docker Compose directory..."
    cd "$HOME/project_idx_moodle/.idx"

    # Start Docker Compose
    echo "Starting Docker Compose..."
    docker-compose up -d
    # docker-compose up --force-recreate --build -d # for testing
    
    # Copy the config-dist.php file to config.php
    echo "updating config file"
    cp $HOME/project_idx_moodle/www/config-dist.php $HOME/project_idx_moodle/www/config.php
    check_directory /home/user/moodledata


    # Use sed to find and replace the variables in config.php
    sed -i 's/\$CFG->dbtype    = '\''pgsql'\'';/\$CFG->dbtype    = '\''mariadb'\'';/' $HOME/project_idx_moodle/www/config.php
    sed -i 's/\$CFG->dbhost    = '\''localhost'\'';/\$CFG->dbhost    = '\''127.0.0.1'\'';/' $HOME/project_idx_moodle/www/config.php
    sed -i 's/\$CFG->dbuser    = '\''username'\'';/\$CFG->dbuser    = '\''root'\'';/' $HOME/project_idx_moodle/www/config.php
    sed -i 's/\$CFG->dbpass    = '\''password'\'';/\$CFG->dbpass    = '\''root'\'';/' $HOME/project_idx_moodle/www/config.php
    sed -i 's#\$CFG->wwwroot   = '\''http://example.com/moodle'\'';#\$CFG->wwwroot   = '\''http://127.0.0.1:9002'\'';#' $HOME/project_idx_moodle/www/config.php
    sed -i 's#\$CFG->dataroot  = '\''/home/example/moodledata'\'';#\$CFG->dataroot  = '\''/home/user/moodledata'\'';#' $HOME/project_idx_moodle/www/config.php
    sed -i 's/\$CFG->directorypermissions = 02777;/\$CFG->directorypermissions = 0777;/' $HOME/project_idx_moodle/www/config.php

     # Get end time and calculate duration
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    #Display DB information
    echo "Database Information:"
    echo "DB_USER: root"
    echo "DB_PASSWORD: root"
    echo "DB_HOST: 127.0.0.1"
    echo "DB_NAME: moodle"

    echo "SMTP HOST: 127.0.0.1:1025";
    echo 'Mailpit URL: ' https://8025-$WEB_HOST
    echo 'PHPMYADMIN URL: ' https://8020-${WEB_HOST}
    echo 'Web URL: ' https://9002-$WEB_HOST

    echo "Script completed in $duration seconds."
}

# Check dependencies before running script
check_dependencies

# Run main script function
main