DROP TABLE stations;

CREATE EXTERNAL TABLE stations
(
	station_id string,
	complex_id string,
	gtfs_stop_id string,
	division string,
	line_numb string,
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
LOCATION '/user/w205/mtastatic/stations'
;

DROP TABLE complexes;

CREATE EXTERNAL TABLE complexes
(
	complex_id string,
	complex_name string
)

ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
 "separatorChar" = ',',
 "quoteChar" = '"',

 "escapeChar" = '\\'
)
STORED AS TEXTFILE
LOCATION '/user/w205/mtastatic/complexes'
;

DROP TABLE historicturnstile;

CREATE EXTERNAL TABLE historicturnstile
(
	c_a string,
	unit string,
	scp string,
	station string,
	linename string,
	divisiom string,
	date_val string,
	time_val string,
	description string,
	entries string,
	exits string
	
)

ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
 "separatorChar" = ',',
 "quoteChar" = '"',

 "escapeChar" = '\\'
)
STORED AS TEXTFILE
LOCATION '/user/w205/mtastatic/turnstilehistoric'
;
