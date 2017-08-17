/* Schedule data readin */

DROP TABLE stopstimesdata;

CREATE EXTERNAL TABLE stopstimesdata
(trip_id string,
arrival_time string,
departure_time string,
stop_id string,
stop_sequence string,
stop_headsign string,
pickup_type string,
drop_off_type string,
shape_dist_traveled string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/w205/final_project_test/stop_times/';

DROP TABLE stopsdata;

CREATE EXTERNAL TABLE stopsdata
(stop_id string,
stop_code string,
stop_name string,
stop_desc string,
stop_lat string,
stop_lon string,
zone_id string,
stop_url string,
location_type string,
parent_station string)
ROW FORMAT delimited fields terminated by ','
STORED AS TEXTFILE
LOCATION '/user/w205/final_project_test/stops/';
