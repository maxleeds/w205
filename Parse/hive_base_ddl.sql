DROP TABLE trip_update_serde;
CREATE EXTERNAL TABLE trip_update_serde
(trip_id string,
 route_id string,
 direction_id string,
 start_time string,
 start_date string,
 schedule_relationship string,
 train_id string,
 is_assigned string,
 direction string,
 stop_sequence string,
 stop_id string,
 arrival_delay string,
 arrival_time string,
 arrival_uncertainty string,
 departure_delay string,
 departure_time string,
 departure_uncertainty string,
 schedule_relationship_update string,
 scheduled_track string,
 actual_track string,
 timestamp string)
 ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
 WITH SERDEPROPERTIES (
 "separatorChar" = ",",
 "quoteChar" = '\"',
 "escapeChar" = '\\'
 )
 STORED AS TEXTFILE
 LOCATION '/user/w205/mta/trip_update';

DROP TABLE vehicle_position_serde;
CREATE EXTERNAL TABLE vehicle_position_serde
(
trip_id string,
route_id string,
direction_id string,
start_time string,
start_date string,
schedule_relationship string,
train_id string,
is_assigned string,
direction string,
position_latitude string,
position_longitude string,
position_bearing string,
position_odometer string,
position_speed string,
current_stop_sequence string,
stop_id string,
stop_status string,
timestamp string,
congestion_level string,
occupancy_status string
)
 ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
 WITH SERDEPROPERTIES (
 "separatorChar" = ",",
 "quoteChar" = '\"',
 "escapeChar" = '\\'
 )
 STORED AS TEXTFILE
 LOCATION '/user/w205/mta/vehicle_position';
