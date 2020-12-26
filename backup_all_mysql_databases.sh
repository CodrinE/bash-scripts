
#!/bin/sh

#This script backs up all the databases separatelly 


#set database user
DBUSER=root

#set date string for file name
DATESTR=`date +%A_%d-%m-%Y_%H-%M-%S`


#Get datanase list from MySQL server
echo "Geting list of databases from MySQL server"
databases=(  `echo "SHOW DATABASES;" | mysql -u root` )


#set databses to be excluded
excludedDatabases=( Database performance_schema information_schema )

#set start date
STARTDATE=$(date)

echo $STARTDATE": Starting database table rows count"

#checks if the database is in excluded list. database name is passed as first param
#EXAMPL
#  isExCludedDb=$(isExDb <database_name>)
function isExDb()
{
    local isXdb="false"
    for ein "${excludedDatabases[@]}"
    do
        if [ "$1" == "${exdb}" ]; then
            isXdb="true"
            break
        fi
    done

    echo "$isXdb"
}


#Loop through all databases
for db in "${databases[@]}"
do
    #check if the database in excluded database list
    if [ $(isExDb "$db") == "true" ]; then

        #do not backup if the database is in excluded list
        echo $(date)': Excluded database: '$db

    else
        #back up database
        echo $(date)': Backing up database: '$db

        #generate backup file path
        newbackuppath=$BACKUPPATH$db"_"$DATESTR$EXT

        #backup database
        mysqldump -u root --opt --routines --triggers --quick  $db | gzip > $newbackuppath

        #check if database backup succeeded or failed
        if [ "${PIPESTATUS[0]}" -ne "0" ];  then

            #if database backup failed, delete the file created during backup attempt
            echo 'Failed to backup, database: '$db
            #check and delete file if exist
            if [ -f $newbackuppath ]; then
                rm -f $newbackuppath
                echo $(date)': Removed failed backup file'$newbackuppath

                #create simple errorlog file to indicate database backup failed
                errLogPath=$newbackuppath".error.log"
                echo $(date)': Failed to create database backup, something went wrong in mysqldump' > $errLogPath
            fi

        else

            #show success message, if backup succeeded.
            echo $(date)': Backup successfull, database: '$db' path: '$newbackuppath

        fi
    fi
done

echo $(date)": Database backup finished, started at: "$STARTDATE
