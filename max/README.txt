staticimport.sh - import schedule and comlex data from mta

hive_schema_on_read.sql - bring static data into hive

get_historic_turnstile - import all weekly turnstile data, from 10/18/2014 to 8/12/2017; merges all into 1, add new date to list to get
                         next week or ammend list

permissions.sh - shell script for permissions, only need to change this one
