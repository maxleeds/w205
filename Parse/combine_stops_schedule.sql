DROP TABLE combinedstopsdata;

CREATE TABLE combinedstopsdata AS
SELECT stopstimesdata.stop_id,
SUBSTR(trip_id, 1, INSTR(trip_id,"_")-4) schedule_day,
SUBSTR(trip_id, INSTR(trip_id,"_")-3, 3) week_day,
SUBSTR(trip_id, INSTR(trip_id,"_")+1, LENGTH(trip_id)) trip_id,
cast(concat(cast(CURRENT_date as string)," ",arrival_time) as timestamp) as arrival_time,
cast(concat(cast(CURRENT_date as string)," ",departure_time) as timestamp) as departure_time,
unix_timestamp(concat(cast(CURRENT_date as string)," ",arrival_time)) as arrival_time_unix,
unix_timestamp(concat(cast(CURRENT_date as string)," ",departure_time)) as departure_time_unix,
CASE WHEN SUBSTR(trip_id, INSTR(trip_id,"_")-3, 3) = "SUN" THEN 7
WHEN SUBSTR(trip_id, INSTR(trip_id,"_")-3, 3) = "WKD" THEN 1
WHEN SUBSTR(trip_id, INSTR(trip_id,"_")-3, 3) = "SAT" THEN 6 END as week_day_num,
stop_sequence,
stop_name,
cast(stop_lat as decimal(8,6)) as stop_latitude,
cast(stop_lon as decimal(9,6)) as stop_longitude,
location_type
FROM stopstimesdata
LEFT JOIN stopsdata ON stopstimesdata.stop_id = stopsdata.stop_id;
