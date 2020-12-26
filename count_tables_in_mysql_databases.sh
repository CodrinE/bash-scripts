
#!/bin/sh
set -x
#This script counts all table rows in all databases

#set output file
FILE=database_table_count_results.txt
#set database user
DBUSER=root

#set date string for file name
DATESTR=`date +%A_%d-%m-%Y_%H-%M-%S`

if [[ ! -e "$FILE" ]]; then
    touch $FILE
else
   echo "" > $FILE
fi

#Get datanase list from MySQL server
echo "Geting list of databases from MySQL server" > $FILE
databases=(  `echo "SHOW DATABASES;" | mysql -u root` )


#set databses to be excluded
excludedDatabases=( Database performance_schema information_schema mysql sys)

#set start date
STARTDATE=$(date)

echo $STARTDATE": Starting database table rows count" > $FILE

#checks if the database is in excluded list. database name is passed as first param
#EXAMPL
#  isExCludedDb=$(isExDb <database_name>)
function isExDb()
{
    local isXdb="false"
    for exdb in "${excludedDatabases[@]}"
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
        echo $(date)': Excluded database: '$db > $FILE

    else
#loop trough all tables
#count all table rows
        dbTables=(  `echo "SHOW TABLES FROM $db;" | mysql -u root` )
        
        for dbTable in  "${dbTables[@]}"
        do
            #count all table rows
            nrOfTableRows=(  `echo "SELECT COUNT(*) FROM $db.$dbTables;" | mysql -u root` )
            echo "Table $dbTable in database $db has $nrOfTableRow rows" > $FILE
       done
 
    fi
done

echo $(date)": Database finished finished, started at: "$STARTDATE
