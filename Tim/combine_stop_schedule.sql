/* Combine the stop times data and the stops lookup data */

DROP TABLE combinedstopsdata;

CREATE TABLE combinedstopsdata AS
SELECT stopstimesdata.stop_id,
trip_id,
cast(concat("2016-01-01 ",arrival_time) as timestamp) as arrival_time,
cast(concat("2016-01-01 ",departure_time) as timestamp) as departure_time,
stop_sequence,
stop_name,
cast(stop_lat as decimal(8,6)) as stop_latitude,
cast(stop_lon as decimal(9,6)) as stop_longitude,
location_type
FROM stopstimesdata
LEFT JOIN stopsdata ON stopstimesdata.stop_id = stopsdata.stop_id;
