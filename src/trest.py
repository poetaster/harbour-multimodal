# -*- coding: utf-8 -*-
import pyotherside
from datetime import datetime, timedelta
from trest_client.trest_client import TrestClient

class Trest:
  def __init__(self):
    print('trest init')
    self.client = TrestClient()

  def r_get_journey(self, from_stop_point, to_stop_point, start_time, preference, modes):
    result = self.client.get_journey_results(from_stop_point, to_stop_point, round(start_time/1000), preference, modes)
    pyotherside.send("a_get_journey", result)
    if result == False:
      pyotherside.send("error", "trest", "r_get_journey", 'No result')

  def r_get_fares(self, from_stop_point_id, to_stop_point_id):
    return None

  def r_get_departures(self, stop_point_id, dataset_id):
    print('r_get_departures - requesting station board for stop:', stop_point_id, ', dataset:', dataset_id)
    services = self.client.get_arrivals_departures_board(stop_point_id, dataset_id)
    
    if services == False:
      pyotherside.send("error", "trest", "r_get_departures", 'No result')
      return

    pyotherside.send("a_get_predictions", services)


  def r_get_arrivals(self, stop_point_id, dataset_id):
    print('r_get_arrivals - requesting station board for stop:', stop_point_id, ', dataset:', dataset_id)
    services = self.client.get_arrivals_departures_board(stop_point_id, dataset_id, True)
    
    if services == False:
      pyotherside.send("error", "trest", "r_get_arrivals", 'No result')
      return

    pyotherside.send("a_get_predictions", services)
  
  def r_search_stop(self, search_str):
    print('r_search_stop - search:', search_str)
    result = self.client.search_stops(search_str)
    pyotherside.send("a_search_stop", result)

  def r_get_trip(self, trip_id, line_id, from_stop_point_id, to_stop_point_id):
    result = self.client.get_calling_points(trip_id, line_id, from_stop_point_id, to_stop_point_id)

    if result == False:
      pyotherside.send("error", "trest", "r_get_trip", 'No result')
      pyotherside.send("a_get_trip", {})
      return

    trip = {'trip_id': trip_id, 'line_id': line_id, 'stops': result, 'remarks': []}
    pyotherside.send("a_get_trip", trip)

  def r_get_service_details(self, trip_id, line_id):
    result = self.client.get_calling_points(trip_id, line_id)
    
    if result == False:
      pyotherside.send("error", "trest", "r_get_service_details", 'No result')
      pyotherside.send("a_get_vehicle_predictions", [])
      return

    pyotherside.send("a_get_vehicle_predictions", [result])


    

trest_object = Trest()
