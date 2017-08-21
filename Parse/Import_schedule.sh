mkdir /data/tim/w205/Parse/Output

wget "http://web.mta.info/developers/data/nyct/subway/google_transit.zip"
unzip google_transit.zip

cat stop_times.txt > stop_times.csv
cat stops.txt > stops.csv

tail -n +2 "stop_times.csv" > "stop_times1.csv"
tail -n +2 "stops.csv" > "stops1.csv"

hdfs dfs -mkdir /user/w205/staging
hdfs dfs -mkdir /user/w205/staging/stop_times
hdfs dfs -mkdir /user/w205/staging/stops

hdfs dfs -put stop_times1.csv /user/w205/staging/stop_times
hdfs dfs -put stops1.csv /user/w205/staging/stops
