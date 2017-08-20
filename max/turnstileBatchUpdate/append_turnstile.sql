DROP TABLE newturnstile;

CREATE EXTERNAL TABLE newturnstile
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
LOCATION '/user/w205/mtastatic/newturnstile'

AlTER TABLE allturnstile RENAME TO oldturnstile;

CREATE TABLE allturnstile AS
Select * FROM newturnstile
UNION ALL
SELECT * FROM oldturnstile;
