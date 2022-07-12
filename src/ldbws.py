# -*- coding: utf-8 -*-
import pyotherside
from datetime import datetime, timedelta
from ldbws_client.ldbws_client import LdbwsClient
import multimodal_structures

class Ldbws:
  MAX_RESULTS = 200
  TIME_WINDOW = 60

  def __init__(self):
    print('ldbws init')

  def format_error(self, err):
    return '%s' % err
    
  def ak(self, data, *keys):
    for key in keys:
      try:
        return data[key]
      except KeyError:
        pass
      except Exception as err:
        print("ERROR : %s" % err)

    return None

  def get_location_names(self, location_objects):
    location_names = []
    for location in location_objects:
      location_names.append(location['locationName'])
    return location_names

  def get_location_codes(self, location_objects):
    location_codes = []
    for location in location_objects:
      location_codes.append(location['crs'])
    return location_codes

  def join_location_names(self, location_objects):
    return '·'.join(self.get_location_names(location_objects))

  def join_vias(self, location_objects):
    try:
      vias = []
      for location in location_objects:
        if location['via'] not in vias:
          vias.append(location['via'])
      return '·'.join(vias)
    except:
      return ''

  def mark_color(self, line_id):
    print('mark_color - line_id: ', line_id)

    colors = colors = {
      'avanti-west-coast': '#004354',
      'c2c': '#b7007c',
      'chiltern-railways': '#00bfff',
      'cross-country': '#660f21',
      'east-midlands-railway': '#703e69',
      'east-midlands': '#703e69',
      'first-hull-trains': '#de005c',
      'first-transpennine-express': '#06a6e4 ',
      'grand-central': '#1d1d1b',
      'greater-anglia': '#d70428',
      'great-northern': '#43165c',
      'great-western-railway': '#0a493e',
      'great-western': '#0a493e',
      'heathrow-express': '#532e63',
      'island-line': '#1e90ff',
      'london-north-eastern-railway': '#bf0000',
      'merseyrail': '#fff200',
      'northern-rail': '#262262',
      'northern': '#262262',
      'scotrail': '#1c4074',
      'southeastern': '#00afe8',
      'southern': '#8cc63e',
      'south-western-railway': '#24398c',
      'south-western': '#24398c',
      'thameslink': '#e9438d',
      'transport-for-wales': '#ff4500',
      'west-midlands-trains': '#ff8200',
      'stansted-express': '#6b717a',
    }

    if line_id in colors:
      return colors[line_id]

    return None

  def main_color(self, line_id):
    colors = colors = {
      'london-overground': '#ff6600',
      'tfl-rail': '#330065',
      'elizabeth': '#6950a1',
    }

    if line_id in colors:
      return colors[line_id]

    return "grey"

  def line_text_color(self, line_id):
    colors = colors = {

    }

    if line_id in colors:
      return colors[line_id]

    return "white"

  def r_get_departures(self, stop_code, to_stop_code=None):
    print('r_get_departures - requesting station board for code:', stop_code)

    try:
      client = LdbwsClient()
      board = client.get_departures_board(stop_code, self.MAX_RESULTS, self.TIME_WINDOW, to_stop_code)
      if not board:
        pyotherside.send("error", "ldbws", "r_get_departures", "No results")
        return

      services = []
      if 'trainServices' in board:
        for ts in board['trainServices']:
          te = {
            'module':             'ldbws',
            'is_departure':       True,
            'transport_mode':     self.service_type_to_mode(ts['serviceType'], ts['operatorCode']),
            'title':              self.join_location_names(ts['destination']),
            'subtitle':           self.operator_name_cleanup(ts['operator']),
            'via':                self.join_vias(ts['destination']),
            'service_id':         ts['serviceID'],
            'line_id':            self.operator_to_line(ts['operatorCode']),
            'line_name':          self.operator_name_cleanup(ts['operator']),
            'time_to_station':    self.time_to_station(ts['std'], ts['etd']),
            'is_realtime_data':   True,
            'time_expected':      self.time_to_datetime(ts['std'], ts['etd']).timestamp(),
            'time_planned':       self.time_to_datetime(ts['std']).timestamp(),
            'platform_name':      None if 'platform' not in ts or not ts['platform'] or (ts['platform'] == 'undefined' or ts['platform'] == 'BUS') else ts['platform'],
            'is_delayed':         ts['etd'] == 'Delayed',
            'delay_reason':       ts['delayReason'] if 'delayReason' in ts else '',
            'is_cancelled':       True if 'isCancelled' in ts and ts['isCancelled'] == 'true' else False,
            'cancel_reason':      ts['cancelReason'] if 'cancelReason' in ts else '',
            'number_carriages':   int(ts['length']) if 'length' in ts else None,
            'origin_codes':       self.get_location_codes(ts['origin']),
            'destination_codes':  self.get_location_codes(ts['destination']),
            'main_color':         self.main_color(self.operator_to_line(ts['operatorCode'])),
            'mark_color':         self.mark_color(self.operator_to_line(ts['operatorCode'])),
            'text_color':         self.line_text_color(self.operator_to_line(ts['operatorCode'])),
            'icon_name':               self.operator_to_icon(ts['operatorCode']),
          }

          services.append(multimodal_structures.timetable_entry(te))

      if 'busServices' in board:
        for ts in board['busServices']:
          te = {
            'module':             'ldbws',
            'is_departure':       True,
            'transport_mode':     'bus',
            'title':              self.join_location_names(ts['destination']),
            'subtitle':           self.operator_name_cleanup(ts['operator']),
            'via':                self.join_vias(ts['destination']),
            'service_id':         ts['serviceID'],
            'line_id':            self.operator_to_line(ts['operatorCode']),
            'line_name':          self.operator_name_cleanup(ts['operator']),
            'time_to_station':    self.time_to_station(ts['std'], ts['etd']),
            'is_realtime_data':   True,
            'time_expected':      self.time_to_datetime(ts['std'], ts['etd']).timestamp(),
            'time_planned':       self.time_to_datetime(ts['std']).timestamp(),
            'platform_name':      None if 'platform' not in ts or not ts['platform'] or ts['platform'] == 'undefined' or ts['platform'] == 'BUS' else ts['platform'],
            'is_delayed':         ts['etd'] == 'Delayed',
            'delay_reason':       ts['delayReason'] if 'delayReason' in ts else '',
            'is_cancelled':       True if 'isCancelled' in ts and ts['isCancelled'] == 'true' else False,
            'cancel_reason':      ts['cancelReason'] if 'cancelReason' in ts else '',
            'number_carriages':   int(ts['length']) if 'length' in ts else None,
            'origin_codes':       self.get_location_codes(ts['origin']),
            'destination_codes':  self.get_location_codes(ts['destination']),
            'main_color':         self.main_color(self.operator_to_line(ts['operatorCode'])),
            'mark_color':         self.mark_color(self.operator_to_line(ts['operatorCode'])),
            'text_color':         self.line_text_color(self.operator_to_line(ts['operatorCode'])),
            'icon_name':               'bus',
          }

          services.append(multimodal_structures.timetable_entry(te))

      pyotherside.send("a_get_predictions", services)
      if 'nrccMessages' in board:
        pyotherside.send("a_get_station_messages", board['nrccMessages'])
    except Exception as err:
      pyotherside.send("error", "ldbws", "r_get_departures", self.format_error(err))

  def r_get_arrivals(self, stop_code, to_stop_code=None):
    print('r_get_arrivals - requesting station board for code:', stop_code)
    try:
      client = LdbwsClient()
      board = client.get_arrivals_board(stop_code, self.MAX_RESULTS, self.TIME_WINDOW, to_stop_code)
      if not board:
        pyotherside.send("error", "ldbws", "r_get_arrivals", "No results")
        return

      services = []
      if 'trainServices' in board:
        for ts in board['trainServices']:          
          te = {
            'module':             'ldbws',
            'is_departure':       False,
            'transport_mode':     self.service_type_to_mode(ts['serviceType'], ts['operatorCode']),
            'title':              self.join_location_names(ts['origin']),
            'subtitle':           self.operator_name_cleanup(ts['operator']),
            'via':                self.join_vias(ts['destination']),
            'service_id':         ts['serviceID'],
            'line_id':            self.operator_to_line(ts['operatorCode']),
            'line_name':          self.operator_name_cleanup(ts['operator']),
            'time_to_station':    self.time_to_station(ts['sta'], ts['eta']),
            'is_realtime_data':   True,
            'time_expected':      self.time_to_datetime(ts['sta'], ts['eta']).timestamp(),
            'time_planned':       self.time_to_datetime(ts['sta']).timestamp(),
            'platform_name':      None if 'platform' not in ts or not ts['platform'] or ts['platform'] == 'undefined' or ts['platform'] == 'BUS' else ts['platform'],
            'is_delayed':         ts['eta'] == 'Delayed',
            'delay_reason':       ts['delayReason'] if 'delayReason' in ts else '',
            'is_cancelled':       True if 'isCancelled' in ts and ts['isCancelled'] == 'true' else False,
            'cancel_reason':      ts['cancelReason'] if 'cancelReason' in ts else '',
            'number_carriages':   int(ts['length']) if 'length' in ts else None,
            'origin_codes':       self.get_location_codes(ts['origin']),
            'destination_codes':  self.get_location_codes(ts['destination']),
            'main_color':         self.main_color(self.operator_to_line(ts['operatorCode'])),
            'mark_color':         self.mark_color(self.operator_to_line(ts['operatorCode'])),
            'text_color':         self.line_text_color(self.operator_to_line(ts['operatorCode'])),
            'icon_name':               self.operator_to_icon(ts['operatorCode']),
          }

          services.append(multimodal_structures.timetable_entry(te))

      if 'busServices' in board:
        for ts in board['busServices']:          
          te = {
            'module':             'ldbws',
            'is_departure':       False,
            'transport_mode':     'bus',
            'title':              self.join_location_names(ts['origin']),
            'subtitle':           self.operator_name_cleanup(ts['operator']),
            'via':                self.join_vias(ts['destination']),
            'service_id':         ts['serviceID'],
            'line_id':            self.operator_to_line(ts['operatorCode']),
            'line_name':          self.operator_name_cleanup(ts['operator']),
            'time_to_station':    self.time_to_station(ts['sta'], ts['eta']),
            'is_realtime_data':   True,
            'time_expected':      self.time_to_datetime(ts['sta'], ts['eta']).timestamp(),
            'time_planned':       self.time_to_datetime(ts['sta']).timestamp(),
            'platform_name':      None if 'platform' not in ts or not ts['platform'] or ts['platform'] == 'undefined' or ts['platform'] == 'BUS' else ts['platform'],
            'is_delayed':         ts['eta'] == 'Delayed',
            'delay_reason':       ts['delayReason'] if 'delayReason' in ts else '',
            'is_cancelled':       True if 'isCancelled' in ts and ts['isCancelled'] == 'true' else False,
            'cancel_reason':      ts['cancelReason'] if 'cancelReason' in ts else '',
            'number_carriages':   int(ts['length']) if 'length' in ts else None,
            'origin_codes':       self.get_location_codes(ts['origin']),
            'destination_codes':  self.get_location_codes(ts['destination']),
            'main_color':         self.main_color(self.operator_to_line(ts['operatorCode'])),
            'mark_color':         self.mark_color(self.operator_to_line(ts['operatorCode'])),
            'text_color':         self.line_text_color(self.operator_to_line(ts['operatorCode'])),
            'icon_name':               'bus',
          }

          services.append(multimodal_structures.timetable_entry(te))


      pyotherside.send("a_get_predictions", services)
      if 'nrccMessages' in board:
        pyotherside.send("a_get_station_messages", board['nrccMessages'])

    except Exception as err:
      pyotherside.send("error", "ldbws", "r_get_arrivals", self.format_error(err))


  def r_get_next_departures(self, stop_code, destination_code):
    print('r_get_next_departures - requesting station board for code:', stop_code, 'to', destination_code)

    client = LdbwsClient()
    #board = client.get_next_departures(stop_code, destination_code)
    pyotherside.send("a_get_predictions", [])
    pyotherside.send("error", "ldbws", "r_get_next_departures", self.format_error(err))


  def r_get_fastest_departures(self, stop_code, destination_code):
    print('r_get_fastest_departures - requesting station board for code:', stop_code, 'to', destination_code)

    client = LdbwsClient()
    board = client.get_fastest_departures(stop_code, destination_code)
    if not board:
      pyotherside.send("error", "ldbws", "r_get_fastest_departures", "No results")
      return

    services = []
    try:
      if 'departures' in board:
        for departures in board['departures']:
          if not departures:
            continue
          for ts in departures:            
            te = {
            'module':             'ldbws',
            'is_departure':       True,
            'is_fastest_service': True,
            'transport_mode':     self.service_type_to_mode(ts['serviceType'], ts['operatorCode']),
            'title':              self.join_location_names(ts['destination']),
            'subtitle':           self.operator_name_cleanup(ts['operator']),
            'via':                self.join_vias(ts['destination']),
            'service_id':         ts['serviceID'],
            'line_id':            self.operator_to_line(ts['operatorCode']),
            'line_name':          self.operator_name_cleanup(ts['operator']),
            'time_to_station':    self.time_to_station(ts['std'], ts['etd']),
            'is_realtime_data':   True,
            'time_expected':      self.time_to_datetime(ts['std'], ts['etd']).timestamp(),
            'time_planned':       self.time_to_datetime(ts['std']).timestamp(),
            'platform_name':      None if 'platform' not in ts or not ts['platform'] or ts['platform'] == 'undefined' else ts['platform'],
            'is_delayed':         ts['etd'] == 'Delayed',
            'delay_reason':       ts['delayReason'] if 'delayReason' in ts else '',
            'is_cancelled':       True if 'isCancelled' in ts and ts['isCancelled'] == 'true' else False,
            'cancel_reason':      ts['cancelReason'] if 'cancelReason' in ts else '',
            'number_carriages':   int(ts['length']) if 'length' in ts else None,
            'origin_codes':       self.get_location_codes(ts['origin']),
            'destination_codes':  self.get_location_codes(ts['destination']),
            'main_color':         self.main_color(self.operator_to_line(ts['operatorCode'])),
            'mark_color':         self.mark_color(self.operator_to_line(ts['operatorCode'])),
            'text_color':         self.line_text_color(self.operator_to_line(ts['operatorCode'])),
            'icon_name':          self.operator_to_icon(ts['operatorCode']),
          }

          services.append(multimodal_structures.timetable_entry(te))

      pyotherside.send("a_get_predictions_fastest", services)
    except Exception as err:
      pyotherside.send("error", "ldbws", "r_get_fastest_departures", self.format_error(err))

  def r_get_service_details(self, service_id, origin_codes = [], destination_codes = []):
    print('r_get_service_details - requesting service:', service_id, ', origin: ', origin_codes, ', destination: ', destination_codes)
    try:
      client = LdbwsClient()
      service_details = client.get_service_details(service_id)     
      if not service_details:
        pyotherside.send("error", "ldbws", "r_get_service_details", "No results")
        return

      calling_point_sets = []
      if 'previousCallingPoints' in service_details:
        for cps_i in range(len(service_details['previousCallingPoints'])):
          calling_points = []
          for cp in service_details['previousCallingPoints'][cps_i]:
            expected_time = self.ak(cp, 'at', 'et')
            calling_points.append(multimodal_structures.calling_point_entry({
              'module': 'ldbws',
              'calling_point_id': None,
              'calling_point_name': cp['locationName'],
              'title': cp['locationName'],
              'time_to_station': self.time_to_station(cp['st'], expected_time),
              'time_expected': self.time_to_datetime(cp['st'], expected_time).timestamp(),
              'set_index': cps_i,
              'stop_code': cp['crs'],
              'is_cancelled': True if expected_time == 'Cancelled' else False,
              'is_delayed': True if expected_time == 'Delayed' else False,
              'is_origin': True if cp['crs'] in origin_codes else False,
              'is_destination': True if cp['crs'] in destination_codes else False,
            }))
          if len(calling_point_sets) <= cps_i:
            calling_point_sets.append(calling_points)
          else:
            calling_point_sets[cps_i] += calling_points
      
      if len(calling_point_sets) == 0:
        calling_point_sets.append([])
      expected_time = self.ak(service_details, 'etd', 'eta')
      calling_point_sets[0].append(multimodal_structures.calling_point_entry({
        'module': 'ldbws',
        'is_requesting_station': True,
        'calling_point_id': None,
        'calling_point_name': service_details['locationName'],
        'title': service_details['locationName'],
        'time_to_station': self.time_to_station(self.ak(service_details, 'std', 'sta'), expected_time),
        'time_expected': self.time_to_datetime(self.ak(service_details, 'std', 'sta'), expected_time).timestamp(),
        'set_index': 0,
        'stop_code': service_details['crs'],
        'is_cancelled': True if expected_time == 'Cancelled' else False,
        'is_delayed': True if expected_time == 'Delayed' else False,
        'is_origin': True if service_details['crs'] in origin_codes else False,
        'is_destination': True if service_details['crs'] in destination_codes else False,
      }))

      if 'subsequentCallingPoints' in service_details:
        for cps_i in range(len(service_details['subsequentCallingPoints'])):
          calling_points = []
          for cp in service_details['subsequentCallingPoints'][cps_i]:
            expected_time = self.ak(cp, 'at', 'et')
            calling_points.append(multimodal_structures.calling_point_entry({
              'module': 'ldbws',
              'calling_point_id': None,
              'calling_point_name': cp['locationName'],
              'title': cp['locationName'],
              'time_to_station': self.time_to_station(cp['st'], expected_time),
              'time_expected': self.time_to_datetime(cp['st'], expected_time).timestamp(),
              'set_index': cps_i,
              'stop_code': cp['crs'],
              'is_cancelled': True if expected_time == 'Cancelled' else False,
              'is_delayed': True if expected_time == 'Delayed' else False,
              'is_origin': True if cp['crs'] in origin_codes else False,
              'is_destination': True if cp['crs'] in destination_codes else False,
            }))

          if len(calling_point_sets) <= cps_i:
            calling_point_sets.append(calling_points)
          else:
            calling_point_sets[cps_i] += calling_points

      pyotherside.send("a_get_vehicle_predictions", calling_point_sets)

    except Exception as err:
      pyotherside.send("error", "ldbws", "r_get_service_details", self.format_error(err))

  def operator_to_line(self, operator_code):
    lines = {
      'XR': 'elizabeth',
      'LO': 'london-overground',
      'LE': 'greater-anglia',
      'GW': 'great-western-railway',
      'CC': 'c2c',
      'HX': 'heathrow-express',
      'GN': 'great-northern',
      'TL': 'thameslink',
      'CH': 'chiltern-railways',
      'EM': 'east-midlands',
      'SE': 'southeastern',
      'LM': 'west-midlands',
      'VT': 'avanti-west-coast',
      'SN': 'southern',
      'SW': 'south-western-railway',
      'NT': 'northern',
      'XC': 'cross-country',
      'HT': 'first-hull-trains',
      'TP': 'first-transpennine-express',
      'GC': 'grand-central',
      'IL': 'island-line',
      'GR': 'london-north-eastern-railway',
      'ME': 'merseyrail',
      'SR': 'scotrail',
      'AW': 'transport-for-wales',
    }

    try:
      return lines[operator_code]
    except:
      return operator_code

  def service_type_to_mode(self, service_type, operator_code):
    if service_type == 'train':
      return self.operator_to_mode(operator_code)

    return service_type

  def operator_to_icon(self, operator_code):
    if operator_code == 'XR':
      return 'elizabethline'
    if operator_code == 'LO':
      return 'overground'

    return 'nationalrail'

  def operator_to_mode(self, operator_code):
    if operator_code == 'XR':
      return 'elizabeth-line'
    if operator_code == 'LO':
      return 'overground'

    return 'national-rail'

  def operator_name_cleanup(self, operator_name):
    if operator_name == 'TFL Rail':
      return 'Elizabeth line'
   
    return operator_name

  def time_to_datetime(self, sta, eta = None):
    try:
      hour_s, minute_s = sta.split(':')
      hour = int(hour_s)
      minute = int(minute_s)
      try:
        if eta != "On Time":
          hour_s, minute_s = eta.split(':')
          hour = int(hour_s)
          minute = int(minute_s)
      except:
        pass

      current_time = datetime.now()
      expected_time = current_time.replace(hour=hour,minute=minute,second=0)
      if hour < current_time.hour and current_time.hour - hour > 12:
        expected_time += timedelta(days=1)
      elif hour > current_time.hour and hour - current_time.hour > 12:
        expected_time -= timedelta(days=1)

      return expected_time

    except:
      return sta

  def time_to_station(self, sta, eta):
    try:
      current_time = datetime.now()
      expected_time = self.time_to_datetime(sta, eta)

      time_to_station = (expected_time - current_time).seconds
      if (expected_time < current_time):
        time_to_station = (current_time - expected_time).seconds * -1

      return time_to_station

    except:
      return sta

  def extract_calling_point_sets():
    pass

ldbws_object = Ldbws()
