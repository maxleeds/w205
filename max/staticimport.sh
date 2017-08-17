
if [ ! -d "$staging1" ]; then
  mkdir staging1
fi
hdfs dfs -mkdir /user/w205/mtastatic
# import static list of stations

cd staging1
url="http://web.mta.info/developers/data/nyct/subway/Stations.csv"
wget $url -O stations.csv
tail -n +2 stations.csv > stationsfinal.csv

hdfs dfs -mkdir /user/w205/mtastatic/stations
hdfs dfs -put stationsfinal.csv /user/w205/mtastatic/stations

# import static list of complexes
url1="http://web.mta.info/developers/data/nyct/subway/StationComplexes.csv"
wget $url1 -O complexes.csv
tail -n +2 complexes.csv > complexesfinal.csv
hdfs dfs -mkdir /user/w205/mtastatic/complexes
hdfs dfs -put complexesfinal.csv /user/w205/mtastatic/complexes
