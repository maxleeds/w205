DROP TABLE turnstilestation;

CREATE TABLE turnstilestation AS
SELECT stations.stop_name,
stations.gtfs_stop_id as stop_id,
cast(allturnstile.entries as int) as entries,
cast(CONCAT(SUBSTR(date_val, 7, 4), "-", SUBSTR(date_val, 1, 2), "-", SUBSTR(date_val, 4, 2), " ", time_val) as timestamp) as time
FROM allturnstile
INNER JOIN stations ON allturnstile.station = UPPER(stations.stop_name);

DROP TABLE mintimetable;

CREATE TABLE mintimetable AS
SELECT MIN(time) as mintime
FROM turnstilestation;

DROP TABLE turnstilefirst;

CREATE TABLE turnstilefirst AS
SELECT stop_id,
stop_name,
entries,
time
FROM turnstilestation
INNER JOIN mintimetable ON mintimetable.mintime = time;

DROP TABLE turnstilefirstotal;

CREATE TABLE turnstilefirsttotal AS
SELECT stop_id,
SUM(entries) as totalentries
FROM turnstilefirst
GROUP BY stop_id;

DROP TABLE maxtimetable;

CREATE TABLE maxtimetable AS
SELECT MAX(time) as maxtime
FROM turnstilestation;

DROP TABLE turnstilelast;

CREATE TABLE turnstilelast AS
SELECT stop_id,
entries,
time
FROM turnstilestation
INNER JOIN maxtimetable ON maxtimetable.maxtime = time;

DROP TABLE turnstilelastotal;

CREATE TABLE turnstilelasttotal AS
SELECT stop_id,
SUM(entries) as totalentries
FROM turnstilelast
GROUP BY stop_id;

DROP TABLE turnstilevolume;

CREATE TABLE turnstilevolume AS
SELECT turnstilefirsttotal.stop_id,
turnstilelasttotal.totalentries - turnstilefirsttotal.totalentries as volume
FROM turnstilefirsttotal
INNER JOIN turnstilelasttotal ON turnstilefirsttotal.stop_id = turnstilelasttotal.stop_id;
