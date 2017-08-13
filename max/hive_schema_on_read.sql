DROP TABLE schedules;

CREATE EXTERNAL TABLE schedules
(
	station_id string,
	complex_id string,
	gtfs_stop_id string,
	division string,
	line string,
	stop_name string,
	borough string,
	daytime_routes string,
	structure string,
	gtfs_lat string,
	gtfs_lon string
)

ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
 "separatorChar" = ',',
 "quoteChar" = '"',

 "escapeChar" = '\\'
)
STORED AS TEXTFILE
LOCATION '/user/w205/mtastatic/stationsfinal.csv'
;
