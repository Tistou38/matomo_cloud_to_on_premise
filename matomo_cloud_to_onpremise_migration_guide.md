# How-to Guide: Migrating Matomo Cloud Server to On-Premise

## Overview

This guide will walk you through the process of migrating your Matomo Cloud instance to an on-premise server. It is based on the [official guide from Matomo](https://matomo.org/faq/how-to-install/faq_76/) and this [video tutorial](https://www.youtube.com/watch?v=W2Q55L_P51Q).

## Prerequisites 

Before starting, ensure you have the following:

- Root access to your on-premise server.
- A backup/dump of your Matomo Cloud database (in `.sql` format). If you need a dump of your cloud server, you can request it from Matomo Cloud support.

**Note:** This migration will only work if the destination Matomo instance is running the exact same version as the one on Matomo Cloud.

## I. Apache Installation 

Apache is a web server that allows your browser to communicate with Matomo. Without it, you won’t be able to access Matomo. Installing Apache is straightforward; just run the following command in a terminal:

```bash
sudo apt install apache2
```

After installation, open your browser and navigate to `http://localhost`. If you see a page confirming that Apache is correctly installed, you’re all set.

## II. MySQL Installation

With Apache installed, the next step is to install MySQL, which will serve as the database server for your Matomo data. Run the following command in a terminal to install MySQL:

```bash
sudo apt install mysql-server
```

There are additional steps you could take to secure the MySQL server, but for the purposes of this guide, the default configuration is sufficient since it’s being installed on your own machine.

## III. PHP Installation

Matomo requires PHP to communicate with the database server (MySQL). To install PHP and the necessary modules, run:

```bash
sudo apt install php libapache2-mod-php
```

Once PHP is installed, restart Apache to apply the changes:

```bash
sudo systemctl restart apache2
```

**Optional:**  
If you plan to use certain plugins (like Mistral AI), you may need to install PHP Curl, which allows Matomo to send HTTP requests to other web APIs:

```bash
sudo apt install php-curl
```

## IV. Create the Database with the Dump Data

### Connect to your MySQL database

```bash
mysql
```

### Create a database for Matomo

```sql
CREATE DATABASE matomo_db_name_here;
```

### Create a MySQL User

If you are using MySQL 5.7 or MySQL 8 or newer, create a user with:

```sql
CREATE USER 'myusername'@'localhost' IDENTIFIED WITH mysql_native_password BY 'my-strong-password-here';
```

For older versions like MySQL 5.1, 5.5, or 5.6, use:

```sql
CREATE USER 'myusername'@'localhost' IDENTIFIED BY 'my-strong-password-here';
```

### Grant User Access to the Database

Grant the necessary permissions to the user on your Matomo database:

```sql
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, INDEX, DROP, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES ON matomo_db_name_here.* TO 'myusername'@'localhost';
```

### Grant FILE Global Privilege

This step is optional but recommended as it allows reports to be archived faster using the `LOAD DATA INFILE` feature:

```sql
GRANT FILE ON *.* TO 'myusername'@'localhost';
```

### Disconnect from the Database

```bash
exit
```

### Load the Dump File into the MySQL Database Server

```bash
mysql -u myusername -p matomo_db_name_here < my_cloud_dump.sql
```

## V. Matomo Installation on Apache Server

With PHP and MySQL installed, the final step is to install Matomo. First, navigate to the directory where Matomo will be installed:

```bash
cd /var/www/html
```

Download the correct version of Matomo (refer to the Note on version compatibility):

```bash
wget https://builds.matomo.org/matomo-your.version.here.zip
```

You can find the available versions and select the one that matches your Matomo Cloud instance [here](https://builds.matomo.org).

### Extract and Clean Up

Unzip the downloaded file:

```bash
sudo unzip matomo-your.version.here.zip
```

Remove unnecessary files:

```bash
rm -rdf How\ to\ install\ Matomo.html matomo-your.version.here.zip
```

You should now have a folder named `matomo`. Access the Matomo installation process by navigating to `http://localhost/matomo` in your browser.

### Step 1: Installation Process

The first step of the Matomo installation is simple. Just click on the “Next” button to proceed.

### Step 2: System Check

This step checks your server configuration. If there are any warnings, Matomo will not let you proceed. 

If you need to allow write access to some directories, run the command provided by Matomo:

```bash
chown -R www-data:www-data /var/www/html/matomo
```

### Fixing Common Issues

The most common issues you may encounter involve missing PDO/MYSQLI extensions. Install them by running:

```bash
sudo apt install php-mysql
```

After installation, ensure that the following lines are added or uncommented under `[PHP]` in your `php.ini` file, located in `/etc/php/your.php.version/apache2/`:

```ini
extension=mysqli
extension=pdo
extension=pdo_mysql
```

Restart the Apache server:

```bash
sudo systemctl restart apache2
```

If you see an error about `mbstring`, install it with:

```bash
sudo apt install php-your-version-mbstring
```

Uncomment the related line in the `php.ini` file, then restart the server:

```bash
sudo systemctl restart apache2
```

### Step 3: Database Configuration

Fill in the missing information using the user (`myusername`) and password (`my-strong-password`) you created earlier. For the email field, you can use a dummy email.

**Important:**  
To ensure Matomo correctly finds your dump tables, remove the default prefix (matomo_). If it doesn’t work, you can use a tool like DBeaver to check the correct prefix in your MySQL database. If you continue to have issues, verify that the Matomo versions match between your cloud instance and on-premise server.

## Conclusion

Your Matomo Cloud instance should now be successfully migrated to an on-premise server. Verify that everything is functioning correctly, and ensure that the versions match as needed.
