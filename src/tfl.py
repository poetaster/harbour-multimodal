#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import pyotherside
from datetime import datetime, timedelta
from tfl_client.tfl_client import TflClient
import multimodal_structures

class Tfl:
  MAX_RESULTS = 1000
  def __init__(self):
    print('init')
    self.client = TflClient()
    self.app = None

  def set_app(self, qobject):
    self.app = qobject

  def set_python_handler(self, qobject):
    self.python_handler = qobject

  def cleanup_platform(self, platform_s):
    if not platform_s or len(platform_s) < 1:
      return platform_s

    platform_a = platform_s.split('Platform')
    if len(platform_a) > 1:
      platform_s = platform_a[len(platform_a)-1].strip()

    if platform_s == 'Unknown' or platform_s == 'none' or platform_s == 'null':
      return None

    return platform_s

  def platform_prefix(self, platform_s):
    if not platform_s or len(platform_s) < 1:
      return None

    platform_a = platform_s.split('Platform')
    if len(platform_a) > 1:
      return platform_a[0].rstrip('- ')
    
    return None
    
  def r_get_predictions(self, stop_point_id):
    result = self.client.get_arrivals(stop_point_id)

    if result == False:
      pyotherside.send("error", "tfl", "r_get_predictions", 'No result')
    elif result == None:
      pass
    else:
      entries = []
      for et in result:
        te = {
          'module':             'tfl',
          'is_departure':       False,
          'transport_mode':     et['modeName'],
          'title':              self.client.cleanup_destination(et['destinationName'] if 'destinationName' in et else None),
          'destination_id':     et['destinationNaptanId'] if 'destinationNaptanId' in et else None,
          'subtitle':           et['lineName'],
          'line_id':            et['lineId'],
          'line_name':          et['lineName'],
          'time_to_station':    et['timeToStation'],
          'towards':            et['towards'],
          'is_realtime_data':   True if (datetime.fromisoformat(et['timeToLive'][:-1] + '+00:00').timestamp() - datetime.now().timestamp()) > 0 else False,
          'vehicle_id':         et['vehicleId'],
          'vehicle_id_display': et['vehicleId'] if et['modeName'] == 'bus' and len(et['modeName']) > 0 else None,
          'platform_name':      self.cleanup_platform(et['platformName']),
          'platform_prefix':    self.platform_prefix(et['platformName']),
          'time_expected':      datetime.fromisoformat(et['expectedArrival'][:-1] + '+00:00').timestamp(),
          'main_color':         self.client.line_color('bus') if et['modeName'] == 'bus' else self.client.line_color(et['lineId']),
          'mark_color':         self.client.mainline_color('bus') if et['modeName'] == 'bus' else self.client.mainline_color(et['lineId']),
          'text_color':         self.client.line_text_color('bus') if et['modeName'] == 'bus' else self.client.line_text_color(et['lineId']),
          'icon_name':          self.client.mode_icon(et['modeName']),
        }

        if et['modeName'] == 'bus':
          te['title'] = et['lineName']
          te['subtitle'] = self.client.cleanup_destination(et['destinationName'] if 'destinationName' in et else None)
          if et['platformName'] and len(et['platformName']) < 4:
            te['stop_letter'] = et['platformName']
            te['platform_name'] = None

        if et['modeName'] == 'river-bus':
          if et['platformName'] == 'inbound' or et['platformName'] == 'outbound':
            te['platform_name'] = None

        entries.append(multimodal_structures.timetable_entry(te))

    pyotherside.send("a_get_predictions", entries)


  def r_get_vehicle_predictions(self, vehicle_id, line_id):
    result = self.client.get_vehicle_arrivals(vehicle_id)
    if result == False:
      pyotherside.send("error", "tfl", "r_get_vehicle_predictions", 'No result')
    elif result == None:
      pass
    else:
      entries = []

      for et in result:
        if et['vehicleId'] != vehicle_id or et['lineId'] != line_id:
          continue

        if len(entries) > 0 and entries[-1]['calling_point_id'] == et['naptanId']:
          continue

        entries.append(multimodal_structures.calling_point_entry({
          'module': 'tfl',
          'calling_point_id': et['naptanId'],
          'calling_point_name': et['stationName'],
          'title': self.client.cleanup_destination(et['stationName']),
          'is_requesting_station': False,
          'time_to_station': et['timeToStation'],
          'time_expected': datetime.fromisoformat(et['expectedArrival'][:-1] + '+00:00').timestamp(),
          'stop_letter': None,
        }))

    pyotherside.send("a_get_vehicle_predictions", [entries])

  def r_get_journey(self, from_stop_point, to_stop_point, start_time, preference, modes):
    from_stop = None 
    to_stop = None

    if "id" in from_stop_point and from_stop_point["id"] and from_stop_point['dataset_id'] <= 2:
      from_stop = from_stop_point["id"]
    elif "lat" in from_stop_point and from_stop_point["lat"] and "lon" in from_stop_point and from_stop_point["lon"]:
      from_stop = "%f,%f" % (from_stop_point["lat"], from_stop_point["lon"])

    if "id" in to_stop_point and to_stop_point["id"] and to_stop_point['dataset_id'] <= 2:
      to_stop = to_stop_point["id"]
    elif "lat" in to_stop_point and to_stop_point["lat"] and "lon" in to_stop_point and to_stop_point["lon"]:
      to_stop = "%f,%f" % (to_stop_point["lat"], to_stop_point["lon"])

    if not from_stop:
      pyotherside.send("error", "tfl", "r_get_journey", 'No starting point')
      return

    if not to_stop:
      pyotherside.send("error", "tfl", "r_get_journey", 'No destination point')
      return

    result = self.client.get_journey_results(from_stop, to_stop, start_time, preference, modes)
    pyotherside.send("a_get_journey", result)
    if result == False:
      pyotherside.send("error", "tfl", "r_get_journey", 'No result')

  def r_get_fares(self, from_stop_point_id, to_stop_point_id):
    result = self.client.get_fares(from_stop_point_id, to_stop_point_id)
    pyotherside.send("a_get_fares", result)
    if result == False:
      pyotherside.send("error", "tfl", "r_get_fares", 'No result')

  def r_get_disruptions(self, modes):
    result = self.client.get_mode_disruptions(modes)
    pyotherside.send("a_get_disruptions", result)
    if result == False:
      pyotherside.send("error", "tfl", "r_get_disruptions", 'No result')

  def r_get_line_disruptions(self, lines):
    result = self.client.get_mode_disruptions(lines)
    pyotherside.send("a_get_disruptions", result)
    if result == False:
      pyotherside.send("error", "tfl", "r_get_disruptions", 'No result')
  
  def r_get_mode_status(self, modes):
    result = self.client.get_mode_status(modes)
    pyotherside.send("a_get_mode_status", result)

    if result == False:
      pyotherside.send("error", "tfl", "r_get_mode_status", 'No result')

  def get_colors(self, operator_id, mode_id, type_id, line_id):
    return self.client.line_color('bus') if mode_id == 'bus' else self.client.line_color(line_id), self.client.mainline_color('bus') if mode_id == 'bus' else self.client.mainline_color(line_id), self.client.line_text_color('bus') if mode_id == 'bus' else self.client.line_text_color(line_id)

tfl_object = Tfl()
