# How to guide - Migration Matomo cloud server to on-premise

## Overview

This guide will walk you through the process of migrating your Matomo Cloud instance to an on-premise server. He is based on an official guide from Matomo (link : https://matomo.org/faq/how-to-install/faq_76/) and this video (https://www.youtube.com/watch?v=W2Q55L_P51Q)

## Prerequisites 

Before starting, ensure you have the following:

    - Root access to your on-premise server.
    - A backup/dump of your Matomo Cloud database (in `.sql` format). Ask the matomo cloud support team if you  want a dump of your cloud server

Note that to do this migration only work if the destination matomo you want to migrate data to as the exact same version as the one from. 

## 1: Apache installation 
Apache is a web server, without it, your browser won't be able to make calls to Matomo so no possibility to connect. Installing Apache is really straightforward, all you need to do is to run the following command in a shell:
https://www.youtube.com/watch?v=W2Q55L_P51Q

```bash
sudo apt install apache2
```

Once done, open your browser and enter localhost within your address bar and validate. If you can see a page telling you that Apache is correctly installed, you won. 


## 2: MySQL installation

Once Apache is installed you need to install MySQL in order to have a Database Server that will contains the data of your dump file (.sql). This DB server will communicate these dato to your Matomo server. In order to insall MySQL, you need to run this command in a terminal:

```bash
sudo apt install mysql-server
```
Normally, there are extra steps you sould go for as the default configuration of the MySQL server is not secured, but as we are installing it on you own machine, it should be all right for the scope of this guide. 


## 3: PHP installation

Matomo runs with PHP, a programming language in order to comunicate with the DB server (here MySQL), so without it, no request could be executed properly. To install it, simply run: 

```bash
sudo apt install php libapache2-mod-php
```
Contragulation, PHP is now normally installed on your web server. To ensure taht please restart your Apache Server by executing the following command : 

```bash
sudo systemctl restart apache2
```

Optionnal: 
To have some plug-ins (like Mistral AI) that work fine with your matomo server, you need to install php curl. It will allows sending HTTP requests from Matomo to other web APIs 

```bash
sudo apt install php-curl
```
## 4 Create the Database with the dump data

### Connect to your MySQL database

```bash
mysql
```

### Create a database for Matomo

```sql
CREATE DATABASE matomo_db_name_here;
```
### Create a user
Create a user name `myusername`, if you are using MySQL 5.7 or MySQL 8 or newer : 

```sql
CREATE USER 'myusername'@'localhost' IDENTIFIED WITH mysql_native_password BY 'my-strong-password-here';
```

Or, if your are using an older version such as MySQL 5.1, MySQL 5.5, MySQL 5.6 :

```sql
CREATE USER 'myusername'@'localhost' IDENTIFIED BY 'my-strong-password-here';
```

### Grant this user access to database
Grant this user `myusername` the permission to access your `matomo_db_name_here` database : 
```sql
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, INDEX, DROP, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES ON matomo_db_name_here.* TO 'myusername'@'localhost';
```

### Grant this user acces to FILE global privilege

If enabled, reports will be archived faster thanks to the LOAD DATA INFILE feature of Matomo. 

```sql
GRANT FILE ON *.* TO 'myusername'@'localhost';
```
### Disconnect Database :
```bash
exit
```

### Load the dump file into the MySQL database server
```bash
mysql -u myusername -p matomo_db_name_here < my_cloud_dump.sql
```

## 4: Matomo installation on Apache server

Now we have a server that supports PHP ans has also a database management system software. We need to install Matomo on it. 
To do this, go into the folder where Matomo will be installed : 

```bash
cd /var/www/html
```

Once you are there, you can download the right version of Matomo (cf Note) within it, technically you could do it without the terminal and use the graphic interface of your operating system, but always better to use the terminal. 

```bash
wget https://builds.matomo.org/matomo-your.version.here.zip
```

To see all versions that are available and to find the one that fit to the version of you cloud server, click on this link : https://builds.matomo.org

Unzip it : 
```bash
sudo unzip matomo.zip
```
Remove useless files : 
```bash
rm -rdf How\ to\ install\ Matomo.html matomo-you.version.here.zip
```

As you can see Matomo has been extracted and you now have a folder named matomo. You can enter within you browser localhost/matomo to see the installation process.

### Step 1 
Step 1 of the matomo installation process is very easy, simply click on the Next button.

### Step 2 : System Check
Depending of your server configuration, this step can be a mess. When you see a warning message, it means that Matomo won't let you move forward. 

If you have to allow write access on some directories (related to the message matomo is showing to you), execute the command matomo proposes

```bash
chown -R www-data:www-data /var/www/html/matomo
```


The most common mistakes you are going to see is that the PDO/MYSQLI extensions are missing. To fix that, execute this command in the terminal : 

```bash
sudo apt install php-mysql
```
Once done, add these lines or uncommenting them below [PHP] in  php.ini file that you will find in `/etc/php/your.php.version/apache2/.`:

```
extension=mysqli
extension=pdo
extension=pdo_mysql
```

Once the lines added, restart the server: 

```bash
sudo systemctl restart apache2
```
Once done those error messages will disappear but you may face another one about `mbstring`. In order to install this extension run : 

```bash
sudo apt install php-your-version-mbstring
```

Once done then activate this feature by uncommenting it within your `php.ini` file and restart the server 
```bash
sudo systemctl restart apache2
```
### Step 3

Filed the information missing by using the information of the user you created (`myusername` and `my-strong-password`). 
Concerning the mail field, you can fill it with a dumb mail. 

**Important**\
To assure matomo will correctly find your dump tables, you need to remove the default prefix (matomo_). If it doesn't work after, you can open the MySQL database with dbeaver for example, and see what is the correct prefix. 
If it always doesn't work, it might because you have a different version between you matomo cloud instance and your on-premise one. 

## Conclusion

