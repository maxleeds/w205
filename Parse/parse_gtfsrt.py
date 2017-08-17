#!/usr/bin/env python

import gtfs_realtime_pb2
import nyct_subway_pb2
import urllib
import csv
import logging
import logging.handlers
import os

# Get the MTA key from the environment

MTA_KEY = os.environ['MTA_KEY']
MTA_URL = "http://datamine.mta.info/mta_esi.php?key={0}&feed_id=1".format(MTA_KEY)

# CSV output files
trips = open('./trip_update.csv', 'w') 
vehi = open('./vehicle_position.csv', 'w') 
alerts = open('./alerts.csv', 'w')

# CSV writer objects. 
csvwriter1 = csv.writer(trips)
csvwriter2 = csv.writer(vehi)
csvwriter3 = csv.writer(alerts)
Row = [] # Holds row to be written to a CSV. 

# Set up logging. 
LEVEL = logging.DEBUG
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)  
logger.setLevel(LEVEL)
handler = logging.handlers.RotatingFileHandler('parse_gtfsrt.log', maxBytes=2000000, backupCount=1)  
handler.setLevel(LEVEL)  
handler.setFormatter(formatter)
logger.addHandler(handler)

feed = gtfs_realtime_pb2.FeedMessage()

try:
       response = urllib.urlopen(MTA_URL)       
except urllib.error.URLError as e:
       print e.reason

logger.debug("Response Code = {0}".format(str(response.code)))

# Parse NYCT feed. 
feed.ParseFromString(response.read())

# Headers for CSV output. 
header_trip_update = ('trip_id', 'route_id', 'direction_id', 'start_time', 'start_date', \
                      'schedule_relationship', 'train_id', 'is_assigned', 'direction', \
                      'stop_sequence', 'stop_id', 'arrival_delay','arrival_uncertainty',\
                      'departure_delay','departure_uncertainty','schedule_relationship_update',\
                      'scheduled_track','actual_track','timestamp')
header_vehicle_position = ('trip_id','route_id','direction_id','start_time','start_date',\
                           'schedule_relationship','train_id','is_assigned','direction',\
                           'position_latitude','position_longitude',\
                           'position_bearing','position_odometer','position_speed',\
                           'current_stop_sequence','stop_id','stop_status','timestamp',\
                           'congestion_level','occupancy_status')              

# Write headers into CSV file. 
csvwriter1.writerow(header_trip_update)
csvwriter2.writerow(header_vehicle_position)

if feed.header.HasField('timestamp'):
    logger.debug("TripHeader timestamp is {0}\n".format(str(feed.header.timestamp)))

for entity in feed.entity:
       if entity.HasField('trip_update'):
              logger.debug("Trip Descriptor: trip_id={0},route_id={1},direction_id={2},\
                                             start_time={3},start_date={4},schedule_relationship={5},\
                                             train_id={6},is_assigned={7},direction={8}".format(
                                                           str(entity.trip_update.trip.trip_id),
                                                           str(entity.trip_update.trip.route_id),
                                                           str(entity.trip_update.trip.direction_id),
                                                           str(entity.trip_update.trip.start_time),
                                                           str(entity.trip_update.trip.start_date),
                                                           str(entity.trip_update.trip.schedule_relationship),
                                                           str(entity.trip_update.trip.Extensions[nyct_subway_pb2.nyct_trip_descriptor].train_id),
                                                           str(entity.trip_update.trip.Extensions[nyct_subway_pb2.nyct_trip_descriptor].is_assigned),
                                                           str(entity.trip_update.trip.Extensions[nyct_subway_pb2.nyct_trip_descriptor].direction)))
              logger.debug('Timestamp = {0}'.format(str(entity.trip_update.timestamp)))
              for stop_time_update in entity.trip_update.stop_time_update:
                  logger.debug("Stop Time Update: stop_sequence={0}, stop_id={1}, arrival.delay={2},\
                                                  arrival.uncertainty={3},departure.delay={4},\
                                                  departure.uncertainty={5},schedule_relationship_update={6},scheduled_track={7},\
                                                  actual_track={8}".format(
                                                         str(stop_time_update.stop_sequence),
                                                         str(stop_time_update.stop_id),
                                                         str(stop_time_update.arrival.delay),
                                                         str(stop_time_update.arrival.uncertainty),
                                                         str(stop_time_update.departure.delay),
                                                         str(stop_time_update.departure.uncertainty),
                                                         str(stop_time_update.schedule_relationship),
                                                         str(stop_time_update.Extensions[nyct_subway_pb2.nyct_stop_time_update].scheduled_track),
                                                         str(stop_time_update.Extensions[nyct_subway_pb2.nyct_stop_time_update].actual_track)))
                  Row.append(str(entity.trip_update.trip.trip_id))
                  Row.append(str(entity.trip_update.trip.route_id))
                  Row.append(str(entity.trip_update.trip.direction_id))
                  Row.append(str(entity.trip_update.trip.start_time))
                  Row.append(str(entity.trip_update.trip.start_date))
                  Row.append(str(entity.trip_update.trip.schedule_relationship))
                  Row.append(str(entity.trip_update.trip.Extensions[nyct_subway_pb2.nyct_trip_descriptor].train_id))
                  Row.append(str(entity.trip_update.trip.Extensions[nyct_subway_pb2.nyct_trip_descriptor].is_assigned))
                  Row.append(str(entity.trip_update.trip.Extensions[nyct_subway_pb2.nyct_trip_descriptor].direction))
                  Row.append(str(stop_time_update.stop_sequence))
                  Row.append(str(stop_time_update.stop_id))
                  Row.append(str(stop_time_update.arrival.delay))
                  Row.append(str(stop_time_update.arrival.uncertainty))
                  Row.append(str(stop_time_update.departure.delay))
                  Row.append(str(stop_time_update.departure.uncertainty))
                  Row.append(str(stop_time_update.schedule_relationship))
                  Row.append(str(stop_time_update.Extensions[nyct_subway_pb2.nyct_stop_time_update].scheduled_track))
                  Row.append(str(stop_time_update.Extensions[nyct_subway_pb2.nyct_stop_time_update].actual_track))
                  Row.append(str(entity.trip_update.timestamp))
                  csvwriter1.writerow(Row)
                  Row[:]=[]
       if entity.HasField('vehicle'):
              logger.debug("Trip Descriptor: trip_id={0},route_id={1},direction_id={2},start_time={3},\
                                             start_date={4},schedule_relationship={5},train_id={6},\
                                             is_assigned={7},direction={8}".format(
                                                           str(entity.vehicle.trip.trip_id),
                                                           str(entity.vehicle.trip.route_id),
                                                           str(entity.vehicle.trip.direction_id),
                                                           str(entity.vehicle.trip.start_time),
                                                           str(entity.vehicle.trip.start_date),
                                                           str(entity.vehicle.trip.schedule_relationship),
                                                           str(entity.vehicle.trip.Extensions[nyct_subway_pb2.nyct_trip_descriptor].train_id),
                                                           str(entity.vehicle.trip.Extensions[nyct_subway_pb2.nyct_trip_descriptor].is_assigned),
                                                           str(entity.vehicle.trip.Extensions[nyct_subway_pb2.nyct_trip_descriptor].direction)))
              logger.debug("Position: latitude=%d, longitude=%d, bearing=%d, odometer=%d, speed=%d" \
                           % (entity.vehicle.position.latitude, entity.vehicle.position.longitude, \
                              entity.vehicle.position.bearing, entity.vehicle.position.odometer, \
                              entity.vehicle.position.speed))
              logger.debug("Current Stop Sequence: {0}".format(str(entity.vehicle.current_stop_sequence)))
              logger.debug("Current Stop id: {0}".format(str(entity.vehicle.stop_id)))
              logger.debug("Stop Status: {0}".format(str(entity.vehicle.current_status)))
              logger.debug("Timestamp: {0}".format(str(entity.vehicle.timestamp)))
              logger.debug("Congestion Level: {0}".format(str(entity.vehicle.congestion_level)))              
              logger.debug("Occupancy Status: {0}".format(str(entity.vehicle.occupancy_status)))
              Row.append(str(entity.vehicle.trip.trip_id))
              Row.append(str(entity.vehicle.trip.route_id))
              Row.append(str(entity.vehicle.trip.direction_id))
              Row.append(str(entity.vehicle.trip.start_time))
              Row.append(str(entity.vehicle.trip.start_date))
              Row.append(str(entity.vehicle.trip.schedule_relationship))
              Row.append(str(entity.vehicle.trip.Extensions[nyct_subway_pb2.nyct_trip_descriptor].train_id))
              Row.append(str(entity.vehicle.trip.Extensions[nyct_subway_pb2.nyct_trip_descriptor].is_assigned))
              Row.append(str(entity.vehicle.trip.Extensions[nyct_subway_pb2.nyct_trip_descriptor].direction))
              Row.append(str(entity.vehicle.position.latitude))
              Row.append(str(entity.vehicle.position.longitude))
              Row.append(str(entity.vehicle.position.bearing))
              Row.append(str(entity.vehicle.position.odometer))
              Row.append(str(entity.vehicle.position.speed))              
              Row.append(str(entity.vehicle.current_stop_sequence))
              Row.append(str(entity.vehicle.stop_id))
              Row.append(str(entity.vehicle.current_status))
              Row.append(str(entity.vehicle.timestamp))
              Row.append(str(entity.vehicle.congestion_level))              
              Row.append(str(entity.vehicle.occupancy_status))
              csvwriter2.writerow(Row)
              Row[:]=[]

#       if entity.HasField('alert'):
#              for active_period in entity.alert.active_period:
#                     logger.debug("Alert Active Period: start={}, end={}".format(
#                                        str(entity.alert.active_period.start),
#                                        str(entity.alert.active_period.end)))
#              if(entity.alert.HasField('informed_entity')
#                 for informed_entity in entity.alert.informed_entity:
#                     logger.debug("Alert Informed Entity: agency_alert={}, route_id={}, route_type={}, ")
trips.close()
vehi.close()

