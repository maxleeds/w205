DROP TABLE vehicle_position_day;

CREATE TABLE vehicle_position_day as
SELECT trip_id,
route_id,
current_stop_sequence as stop_sequence,
stop_id,
cast(timestamp as int)-4*60*60 as timestamp,
CASE WHEN from_unixtime(cast(timestamp as int)-4*60*60,'u') = 1 THEN 1
WHEN from_unixtime(cast(timestamp as int)-4*60*60,'u') = 2 THEN 1
WHEN from_unixtime(cast(timestamp as int)-4*60*60,'u') = 3 THEN 1
WHEN from_unixtime(cast(timestamp as int)-4*60*60,'u') = 4 THEN 1
WHEN from_unixtime(cast(timestamp as int)-4*60*60,'u') = 5 THEN 1
WHEN from_unixtime(cast(timestamp as int)-4*60*60,'u') = 6 THEN 6
WHEN from_unixtime(cast(timestamp as int)-4*60*60,'u') = 7 THEN 7 END as week_day_num
FROM vehicle_position_serde; 

DROP TABLE trip_update_day;

CREATE TABLE trip_update_day as
SELECT trip_id,
route_id,
stop_sequence,
stop_id,
arrival_delay,
cast(arrival_time as int)-4*60*60 as arrival_time_update,
departure_delay,
cast(departure_time as int)-4*60*60 as departure_time_update,
CASE WHEN from_unixtime(cast(arrival_time as int)-4*60*60,'u') = 1 THEN 1
WHEN from_unixtime(cast(arrival_time as int)-4*60*60,'u') = 2 THEN 1
WHEN from_unixtime(cast(arrival_time as int)-4*60*60,'u') = 3 THEN 1
WHEN from_unixtime(cast(arrival_time as int)-4*60*60,'u') = 4 THEN 1
WHEN from_unixtime(cast(arrival_time as int)-4*60*60,'u') = 5 THEN 1
WHEN from_unixtime(cast(arrival_time as int)-4*60*60,'u') = 6 THEN 6
WHEN from_unixtime(cast(arrival_time as int)-4*60*60,'u') = 7 THEN 7 END as week_day_num
FROM trip_update_serde;

DROP TABLE real_time_trip_schedule;

CREATE TABLE real_time_trip_schedule AS
SELECT trip_update_day.trip_id,
trip_update_day.route_id,
trip_update_day.stop_id,
trip_update_day.arrival_delay,
trip_update_day.arrival_time_update,
trip_update_day.departure_delay,
trip_update_day.departure_time_update,
trip_update_day.week_day_num,
combinedstopsdata.arrival_time,
combinedstopsdata.departure_time,
combinedstopsdata.arrival_time_unix,
combinedstopsdata.departure_time_unix,
combinedstopsdata.stop_name,
combinedstopsdata.stop_latitude,
combinedstopsdata.stop_longitude,
combinedstopsdata.stop_sequence,
trip_update_day.departure_time_update - combinedstopsdata.departure_time_unix as departure_schedule_delay,
trip_update_day.arrival_time_update - combinedstopsdata.arrival_time_unix as arrival_schedule_delay
FROM trip_update_day
INNER JOIN combinedstopsdata ON trip_update_day.trip_id = combinedstopsdata.trip_id
AND trip_update_day.week_day_num = combinedstopsdata.week_day_num
AND trip_update_day.stop_id = combinedstopsdata.stop_id;

DROP TABLE real_time_trip_update;

CREATE TABLE real_time_trip_update AS
SELECT real_time_trip_schedule.trip_id,
real_time_trip_schedule.stop_id,
real_time_trip_schedule.stop_name,
real_time_trip_schedule.stop_latitude,
real_time_trip_schedule.stop_longitude,
real_time_trip_schedule.departure_schedule_delay,
real_time_trip_schedule.arrival_schedule_delay,
vehicle_position_day.timestamp - real_time_trip_schedule.arrival_time_update as position_delay
FROM real_time_trip_schedule
LEFT JOIN vehicle_position_day ON vehicle_position_day.trip_id = real_time_trip_schedule.trip_id
AND vehicle_position_day.week_day_num = real_time_trip_schedule.week_day_num
AND vehicle_position_day.stop_id = real_time_trip_schedule.stop_id;

DROP TABLE trip_update_final;

CREATE TABLE trip_update_final AS
SELECT real_time_trip_update.stop_id,
stop_name,
stop_latitude,
stop_longitude,
CASE WHEN departure_schedule_delay < -80000 THEN departure_schedule_delay + 86400 
ELSE departure_schedule_delay END as departure_schedule_delay,
CASE WHEN arrival_schedule_delay < -80000 THEN arrival_schedule_delay + 86400 
ELSE arrival_schedule_delay END as arrival_schedule_delay,
position_delay,
turnstilevolume.volume
FROM real_time_trip_update
LEFT JOIN turnstilevolume ON SUBSTR(real_time_trip_update.stop_id,1,3) = turnstilevolume.stop_id
WHERE departure_schedule_delay > -100000 AND departure_schedule_delay < 100000
AND arrival_schedule_delay > -100000 AND arrival_schedule_delay < 100000;

INSERT OVERWRITE LOCAL DIRECTORY '/data/tim/w205/Parse/Output' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ',' 
select * from trip_update_final;
