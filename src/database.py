#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import pyotherside
from datetime import datetime, timedelta
from db_client.db_client import DbClient

class Database:
  MAX_RESULTS = 1000
  def __init__(self):
    print('init')
    self.db = DbClient()
    self.app = None
    self.numbering_area = 1

  def set_app(self, qobject):
    self.app = qobject

  def set_python_handler(self, qobject):
    self.python_handler = qobject

  def set_numbering_area(self, numbering_area):
    self.numbering_area = numbering_area
    self.db.numbering_area = numbering_area

  def get_stop_by_id(self, stop_point_id):
    return self.db.stop_by_id(stop_point_id)

  def get_stop_code(self, stop_point_id):
    result = self.db.stops_by_ids([stop_point_id])
    if result and len(result) > 0:
      return result[0]['stop_code']
    return None

  def get_stop_by_code_name_letter(self, stop_point_id, stop_name, stop_letter):
    return self.db.stop_by_code_name_letter(stop_point_id, stop_name, stop_letter)

  def get_location_by_bssids(self, bssids):
    return self.db.location_by_bssids(bssids)

  def r_stops_by_ids(self, stop_point_ids):
    result = self.db.stops_by_ids(stop_point_ids)
    pyotherside.send("a_stops_by_ids", result)
    if result == False:
      pyotherside.send("error", "database", "r_stops_by_ids", 'No result')

  def r_search_stop(self, search_str):
    result = self.db.search_stops(search_str, self.MAX_RESULTS)
    pyotherside.send("a_search_stop", result)
    if result == False:
      pyotherside.send("error", "database", "r_search_stop", 'No result')
  
  def r_geo_stop(self, lat1, lon1, lat2, lon2):
    result = self.db.stop_in_geobox(lat1, lon1, lat2, lon2)
    pyotherside.send("a_geo_stop", result)
    if result == False:
      pyotherside.send("error", "database", "r_geo_stop", 'No result')

  def r_geo_stops(self, lat1, lon1, lat2, lon2):
    result = self.db.stops_in_geobox(lat1, lon1, lat2, lon2, self.MAX_RESULTS)
    pyotherside.send("a_geo_stops", result)
    if result == False:
      pyotherside.send("error", "database", "r_geo_stops", 'No result')

  def r_geo_stop_modes(self, lat1, lon1, lat2, lon2, modes):
    result = self.db.stop_in_geobox_modes(lat1, lon1, lat2, lon2, modes)
    pyotherside.send("a_geo_stop", result)
    if result == False:
      pyotherside.send("error", "database", "r_geo_stop_modes", 'No result')

  def r_geo_stops_modes(self, lat1, lon1, lat2, lon2, modes):
    result = self.db.stops_in_geobox_modes(lat1, lon1, lat2, lon2, modes, self.MAX_RESULTS)
    pyotherside.send("a_geo_stops", result)
    if result == False:
      pyotherside.send("error", "database", "r_geo_stops_modes", 'No result')

  def r_geo_stop_types(self, lat1, lon1, lat2, lon2, stop_types):
    result = self.db.stop_in_geobox_types(lat1, lon1, lat2, lon2, stop_types)
    pyotherside.send("a_geo_stop", result)
    if result == False:
      pyotherside.send("error", "database", "r_geo_stop_types", 'No result')

  def r_geo_stops_types(self, lat1, lon1, lat2, lon2, stop_types):
    result = self.db.stops_in_geobox_types(lat1, lon1, lat2, lon2, stop_types, self.MAX_RESULTS)
    pyotherside.send("a_geo_stops", result)
    if result == False:
      pyotherside.send("error", "database", "r_geo_stops_types", 'No result')

  def get_lines(self, modes):
    return self.db.get_lines(modes)

  def get_route_sections(self, line_id, mode_id):
    return self.db.get_route_sections(line_id, mode_id)

  def get_route_sequences(self, line_id, mode_id):
    return self.db.get_route_sequences(line_id, mode_id)

  def get_route_sequence_details(self, line_id, mode_id, branch_id, direction):
    return self.db.get_route_sequence_details(line_id, mode_id, branch_id, direction)

  def get_route_sequences_by_stops(self, from_stop_id, to_stop_id, modes):
    return self.db.get_route_sequences_by_stops(from_stop_id, to_stop_id, modes)


database_object = Database()
