#/bin/sh

#------------Global------------------------------------------
##***Important: use this option carefully. This will delete the target DB. Don't Curse me if you didn't see this****
DELETE_TARGET_DB=1

#DB Dump Location 
DB_DUMP_LOCATION=/tmp

ERROR=/tmp/duplicate_mysql_error.log
#------------------------------------------------------------


#--------Source DB Details-----------------------------------
SOURCE_DB_NAME=drupal
SOURCE_DB_HOST=127.0.0.1
SOURCE_DB_USER=root
SOURCE_DB_PASS=password
#------------------------------------------------------------


#--------Target DB details-----------------------------------
TARGET_DB_NAME=drupal_copy
TARGET_DB_HOST=127.0.0.1
TARGET_DB_USER=root
TARGET_DB_PASS=password
#Target User details for which we need to grant privileges. 
TARGET_DB_GRANT_PRIVILEGE_USER_NAME=subu
TARGET_DB_GRANT_PRIVILEGE_USER_PASS=password
#--------------------------------------------------------------


SOURCE_DBEXISTS=$(mysql -h "$SOURCE_DB_HOST" -u$SOURCE_DB_USER -p"$SOURCE_DB_PASS" --batch --skip-column-names -e "SHOW DATABASES LIKE '"$SOURCE_DB_NAME"';" | grep "$SOURCE_DB_NAME" > /dev/null; echo "$?")

TARGET_DBEXISTS=$(mysql -h "$TARGET_DB_HOST" -u "$TARGET_DB_USER" -p"$TARGET_DB_PASS" --batch --skip-column-names -e "SHOW DATABASES LIKE '"$TARGET_DB_NAME"';" | grep "$TARGET_DB_NAME" > /dev/null; echo "$?")


## Source DB exists or not!!!!!!!!!!!
if [ $SOURCE_DBEXISTS -eq 1 ];then
   echo "A database with the name $SOURCE_DB_NAME does not exist in $SOURCE_DB_HOST. Sorry! Can not proceed!"
   exit 1
else
   echo  "A database with the name $SOURCE_DB_NAME exists in $SOURCE_DB_HOST. Proceeding..."
fi

##Deleting taget database !!!!!!!!!!!!!!
if [ $DELETE_TARGET_DB -eq 1 ]; then
    echo "Target: Deleting Target DB" 
    mysql -h $TARGET_DB_HOST -u$TARGET_DB_USER -p$TARGET_DB_PASS -e "drop database $TARGE_DB_NAME"
fi

##Target DB exists or not !!!!!!!!!!!!!
if [ $TARGET_DBEXISTS -eq 0 ];then
   echo "A database with the name $TARGET_DB_NAME already exists in $TARGET_DB_HOST. Sorry! Can not proceed"
   exit 1
else
   echo  "A database with the name $TARGET_DB_NAME does not exists in $TARGET_DB_HOST. Prceeding to create a new database... "
fi


echo "Target: creating $TARGET_DB_NAME in $TARGET_DB_HOST"
mysql -h $TARGET_DB_HOST -u$TARGET_DB_USER -p$TARGET_DB_PASS -e "create database $TARGET_DB_NAME"

echo "Target: Granting all privileges to $TARGET_DB_GRANT_PRIVILEGE_USER_NAME for database $TARGET_DB_NAME"
mysql -h $TARGET_DB_HOST -u$TARGET_DB_USER -p$TARGET_DB_PASS -e "GRANT ALL PRIVILEGES ON $TARGET_DB_NAME.* TO '$TARGET_DB_GRANT_PRIVILEGE_USER_NAME'@'%' IDENTIFIED BY '$TARGET_DB_GRANT_PRIVILEGE_USER_PASS'"
 
echo "Source: Taking DB dump of $SOURCE_DB_NAME from $SOURCE_DB_HOST"
DB_DUMP_FILE_NAME="$DB_DUMP_LOCATION/$SOURCE_DB_NAME.sql"
mysqldump -v --log-error=$ERROR --single-transaction -h $SOURCE_DB_HOST -u$SOURCE_DB_USER -p$SOURCE_DB_PASS $SOURCE_DB_NAME | pv > $DB_DUMP_FILE_NAME

echo "Target: Imporing DB dump $DB_DUMP_FILE_NAME to database $TARGET_DB_NAME in $TARGET_DB_HOST" 
pv $DB_DUMP_FILE_NAME | mysql -h $TARGET_DB_HOST -u$TARGET_DB_USER -p$TARGET_DB_PASS $TARGET_DB_NAME
