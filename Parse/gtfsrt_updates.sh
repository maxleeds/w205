#!/bin/bash

count=1
echo "[CTRL-C] to stop"
while :
do
  ./parse_gtfsrt.py
  echo "update number: $count"
  hdfs dfs -mkdir /user/w205/mta 2> /dev/null
  hdfs dfs -mkdir /user/w205/mta/trip_update 2> /dev/null
  hdfs dfs -mkdir /user/w205/mta/vehicle_position 2> /dev/null
  hdfs dfs -rm /user/w205/mta/trip_update/trip_update.csv &> /dev/null
  hdfs dfs -rm /user/w205/mta/vehicle_position/vehicle_position.csv &> /dev/null
  hdfs dfs -put ./trip_update.csv /user/w205/mta/trip_update
  hdfs dfs -put ./vehicle_position.csv /user/w205/mta/vehicle_position
  echo "sleeping for 30s"
  sleep 30s
  let "count=count+1"
done 

