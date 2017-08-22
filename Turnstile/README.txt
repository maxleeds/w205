stations.sh - import schedule and comlex data from mta

hive_schema_on_read.sql - bring static data into hive

get_historic_turnstile - import all weekly turnstile data, from 10/18/2014 to 8/12/2017; merges all into 1.  Set to be last 5 for time                              parsimony

process_turnstile_data.sql - calculate the volume of entries at each subway stop during the previous 5 weeks

turnstileBatchUpdate - add new date to list to get next week or ammend list

permissions.sh - shell script for permissions, only need to change this one

Run permissions after chmod u+x,g+x
Run stations
Run get_historic_turnstile
Run hive_schema_on_read

For update
