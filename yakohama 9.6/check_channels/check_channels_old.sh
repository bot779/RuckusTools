#!/bin/sh

#cat /etc/airespider-default/country-list.xml | grep id | awk -F"\"" '{print $6","$4","$8"\n" "\t""2.4GHz:"$10"\n" "\t""5GHz:"$12"\n" "\t""5GHz DFS:"$14"\n" "allow-dfs-channels="$18"\n" "allow-11na-40="$24"\n"}'
cat ./country-list.xml | grep id | awk -F"\"" '{print $6","$4","$8"\n" "\t""2.4GHz:"$10"\n" "\t""5GHz:"$12"\n" "\t""5GHz DFS:"$14"\n" "allow-dfs-channels="$18"\n" "allow-11na-40="$24"\n"}' > coutry-list
