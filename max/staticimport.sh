# import static list of stations
if [ ! -d "$staging1" ]; then
  mkdir staging1
fi

cd staging1
url="http://web.mta.info/developers/data/nyct/subway/Stations.csv"
wget $url -O stations.csv
tail -n +2 stations.csv > stationsfinal.csv

hdfs dfs -mkdir /user/w205/mtastatic
hdfs dfs -put stationsfinal.csv /user/w205/mtastatic
