#!/bin/bash

PASSWORD = my_password
USER = username
PORT = specific_ssh_port
#the server_list file contains all dns names separated by \n 
for i in `cat server_list` 
do
	echo Working on $i
	sshpass -p $PASSWORD  ssh-copy-id $USER@$i -p $PORT
        if [ $? -ne 0 ]; then
	  sshpass -p $PASSWORD ssh-copy-id $USER@$i -p 22
        fi	  
done
