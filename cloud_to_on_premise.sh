#!/bin/bash

# Checks if the program is run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Check if file provided
if [ $# -eq 0 &&  ]; then
    echo "Usage: $0 <fichier.sql>"
    exit 1
fi

# Check if the file provided is a sql file
if [[ "$#" != *.sql ]]; then
    echo "Error: $0 is not a sql file"
    exit 1
fi

apt update
#######################################################     INSTALLATION OF DEPENDENCIES     #######################################################
# Test if mysql is installed and install it if not
if ! [ -x "$(command -v mysql)" ]; then
  apt install mysql-server
fi

# Test if apache2 is installed and install it if not
if ! [ -x "$(command -v apache2)" ]; then
  apt install apache2
fi

# Test if php is installed and install it if not
if ! [ -x "$(command -v php)" ]; then
  apt install php libapache2-mod-php
fi

# Test if unzip is installed and install it if not
if ! [ -x "$(command -v unzip)" ]; then
  apt install unzip
fi

systemctl restart mysql
systemctl restart apache2

#######################################################     DOWNLOAD MATOMO BUILD     #######################################################

cd /var/www/html
wget https://builds.matomo.org/matomo.zip

unzip matomo.zip
rm matomo.zip "*.html"

chown -R www-data:www-data /var/www/html/matomo

#######################################################     DATABASE CONFIGURATION     #######################################################
#!/bin/bash

# Function to validate the database name
function is_valid_db_name {
    local db_name=$1
    # Check if the name contains only letters, numbers, and underscores
    if [[ "$db_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
        return 0  # Valid name
    else
        return 1  # Invalid name
    fi
}

# Prompt the user to enter the database host
read -p "Please enter the database host (default: localhost): " DB_HOST
DB_HOST=${DB_HOST:-localhost}  # Use "localhost" if the user leaves it blank

# Prompt the user to enter the database username
read -p "Please enter the database username: " DB_USER

# Prompt the user to enter the database password
read -s -p "Please enter the database password: " DB_PASS
echo  # Adds a newline after the password input

# Prompt the user to enter a valid database name
while true; do
    read -p "Please enter a database name: " DB_NAME

    # Validate the database name
    if is_valid_db_name "$DB_NAME"; then
        echo "The database name '$DB_NAME' is valid."
        break
    else
        echo "Invalid database name. Please use only letters, numbers, and underscores."
    fi
done

# Create the user
mysql -e "CREATE USER '$DB_USER'@'$DB_HOST' IDENTIFIED WITH mysql_native_password BY '$DB_PASS';"


# Create the database
mysql -e "CREATE DATABASE $DB_NAME;"

# Check if the creation was successful
if [ $? -eq 0 ]; then
    echo "The database '$DB_NAME' was created successfully."
else
    echo "Failed to create the database '$DB_NAME'."
fi

# Grant all privileges on the database to the user
mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, INDEX, DROP, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES ON $DB_NAME.* TO '$DB_USER'@'$DB_HOST';"
mysql -e "GRANT FILE ON *.* TO '$DB_USER'@'$DB_PASS';"







