#!/bin/bash

count=1
echo "[CTRL-C] to stop"
while :
do
  ./parse_gtfsrt.py
  echo "update number: $count"
  sudo -u hdfs hdfs dfs -mkdir /user/w205/mta 2> /dev/null
  sudo -u hdfs hdfs dfs -mkdir /user/w205/mta/trip_update 2> /dev/null
  sudo -u hdfs hdfs dfs -mkdir /user/w205/mta/vehicle_position 2> /dev/null
  sudo -u hdfs hdfs dfs -rm /user/w205/mta/trip_update/trip_update.csv &> /dev/null
  sudo -u hdfs hdfs dfs -rm /user/w205/mta/vehicle_position/vehicle_position.csv &> /dev/null
  sudo -u hdfs hdfs dfs -put ./trip_update.csv /user/w205/mta/trip_update
  sudo -u hdfs hdfs dfs -put ./vehicle_position.csv /user/w205/mta/vehicle_position
  hive -f ./combine_real_time_data.sql
  # Update the paths here to the folder where you are storing your intermediate data
  mv /data/tim/w205/Parse/Output/000000_0 /data/tim/w205/Parse/Output/update.csv
  echo "sleeping for 30s"
  sleep 30s
  let "count=count+1"
done 

