#!/bin/bash

# =============================================================================
# This script will install Apache 2 and PHP 7.4
# It will also add MySQL, the Microsoft SQL Server Driver for PHP, and Memecached
# This script is built for Ubuntu 18.04, but should work on any recent Debian installation
# =============================================================================

if ! [ $(id -u) = 0 ]; then
   echo "You must run this script as root!"
   exit;
fi

# start by adding Microsoft repo and getting msodbc stuff installed
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
apt-get update -y
ACCEPT_EULA=Y apt-get install msodbcsql17 -y 
ACCEPT_EULA=Y apt-get install mssql-tools -y 
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
apt-get install unixodbc-dev  -y

# now we install PHP, PDO, and ultimately, Apache
add-apt-repository ppa:ondrej/php -y
apt-get update -y
apt-get install php7.4 php7.4-dev php7.4-xml -y --allow-unauthenticated
pecl install sqlsrv
pecl install pdo_sqlsrv
printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.4/mods-available/sqlsrv.ini
printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.4/mods-available/pdo_sqlsrv.ini
apt-get install libonig4 libzip4 php7.4-bz2 php7.4-curl php7.4-gd php7.4-mbstring php7.4-zip libonig4 php7.4-bz2 php7.4-curl php7.4-gd php7.4-mbstring php7.4-zip libzip4 php-bz2 php-curl php-gd php-mbstring php-zip -y --allow-unauthenticated
phpenmod -v 7.4 sqlsrv pdo_sqlsrv
apt-get install libapache2-mod-php7.4 apache2

# MySQL, here we come
apt-get install mysql-client php-mysql -y

# configure Apache modules
a2dismod mpm_event
a2enmod mpm_prefork
a2enmod php7.4
a2enmod rewrite

# memcache, memcached
apt-get install memcached php-memcache php-memcached -y --allow-unauthenticated
service memcached start
