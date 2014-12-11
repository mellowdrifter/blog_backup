#!/bin/sh

# Variables
USER = "username_to_save_files"

# DB login details
USERNAME="mysql_user"
PASSWORD="your_password"

# Backup directory
FILE_BACKUP=/path/to/backup/folder

# DB Backup folder
DB_BACKUP=/path/to/backup/folder/databases

# Blog Folder
BLOG=/usr/share/nginx/html
BLOG2=/etc/nginx

# Firewall (v4 and v6)
FIREWALL=/etc/iptables

# Filename format
NOW=$(date +"%d_%m_%Y")

# Commands
FIND="$(which find)"
TAR="$(which tar)"
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
GZIP="$(which gzip)"

# Backup blog files and compress
FILE=$FILE_BACKUP/blogfiles.$NOW.tar.gz
FILE2=$FILE_BACKUP/firewall_rules.$NOW.tar.gz
FILE3=$FILE_BACKUP/nginx_config.$NOW.tar.gz
echo "Backing up"
$TAR zcvf $FILE $BLOG
$TAR zcvf $FILE2 $FIREWALL
$TAR zcvf $FILE3 $BLOG2
chown $USER $FILE
chown $USER $FILE2
chown $USER $FILE3

# Remove files older than 7 days
$FIND $FILE_BACKUP -type f -mtime +7 | xargs rm -vf

# Find databases to backup
DBS=`$MYSQL -u${USERNAME} -p"$PASSWORD" -e "SHOW DATABASES;" -s --skip-column-names | grep -Ev "(Database|information_schema|performance_schema|mysql)"`

# Backup all databases and compress
for db in $DBS
do
FILE=$DB_BACKUP/mysql_$db.$NOW.gz
echo "Backing up" $db
$MYSQLDUMP -u${USERNAME} -p"$PASSWORD" $db | $GZIP > $FILE
done

# Remove files older than 7 days
$FIND $DB_BACKUP -type f -mtime +7 | xargs rm -vf

# Send to remote location via rsync
rsync -ahP --delete /path/to/backup/folder user@remote_ip:/remote/folder
