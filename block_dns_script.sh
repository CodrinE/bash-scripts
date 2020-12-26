#! /bin/bash
set -x
#get dns addreses
targets=( $(cat config.yml | grep url | awk -F/ '{print $3}' | grep -v my.domain..com) )

# get random dns address from array
target=${targets[ $(( RANDOM % ${#targets[@]} )) ]}

#resolve hostname to ips
target_ips=( $(dig +short $target  | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}") )

#echo "${targets[*]}"

#echo "${target_ips[*]}"


#drop dns incoming packets
for ip in "${target_ips[@]}"
do
  iptables -A INPUT -s $ip -j DROP
done

sleep 2s

#allow dns incomming packets
for ip in "${target_ips[@]}"
do
  iptables -D INPUT -s $ip -j DROP
done


