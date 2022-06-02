#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import pyotherside
from datetime import datetime
from tfgm_xml_client.tfgm_xml_client import TfgmXmlClient
import multimodal_structures
import multimodal_functions

class TfgmXml:
  MAX_RESULTS = 100

  def __init__(self):
    print('tfgm_xml init')
    self.client = TfgmXmlClient()
    self.app = None

  def set_app(self, qobject):
    self.app = qobject

  def set_python_handler(self, qobject):
    self.python_handler = qobject

  def to_seconds(self, expected, delta_days = None):
    if not 'figure' in expected:
      return None

    if expected['figure'] == 'Due':
      return -1

    if 'unit' in expected and (expected['unit'] == 'mins' or expected['unit'] == 'min'):
      return int(expected['figure']) * 60

    if ':' not in expected['figure']:
      return None

    return int(multimodal_functions.hm_to_ts(expected['figure'], multimodal_functions.TIMEZONE_UK, delta_days) - datetime.now().timestamp())

  def to_timestamp(self, expected, delta_days = None):
    if not 'figure' in expected:
      return None

    if expected['figure'] == 'Due':
      return None
    
    if 'unit' in expected and (expected['unit'] == 'mins' or expected['unit'] == 'min'):
      return int(datetime.now().timestamp() + (int(expected['figure']) * 60))

    if ':' not in expected['figure']:
      return None

    return int(multimodal_functions.hm_to_ts(expected['figure'], multimodal_functions.TIMEZONE_UK, delta_days))

  def clean_up_stand(self, stand_unclean):
    if not stand_unclean or len(stand_unclean) < 1:
      return None
    
    if stand_unclean.startswith('Stand:'):
      return stand_unclean[6:].strip()

    return name_unclean

  def r_get_predictions(self, stop_code, stop_letter = None):
    if not stop_code or stop_code == '':
      pyotherside.send("a_get_predictions", [])
      pyotherside.send("error", "tfgm_xml", "r_get_predictions", 'No stop point')
      return

    data = self.client.get_departures(stop_code)

    if not data or not 'departures' in data:
      pyotherside.send("a_get_predictions", [])
      pyotherside.send("error", "tfgm_xml", "r_get_predictions", 'No result')
      return

    entries = []
    for de in data['departures']:
      timestamp = self.to_timestamp(de['expected'])
      time_to_station = self.to_seconds(de['expected'])
      if timestamp:
        if (timestamp - datetime.now().timestamp() < -multimodal_functions.HOUR_SECONDS):
          timestamp = self.to_timestamp(de['expected'], 1)
          time_to_station = self.to_seconds(de['expected'], 1)
      
      platform_name = self.clean_up_stand(de['expected']['stand'])
      if stop_letter and platform_name and platform_name != stop_letter:
        continue

      te = {
        'module':             'tfgm_xml',
        'is_departure':       True,
        'transport_mode':     de['class'],
        'title':              de['destination']['line_name'],
        'subtitle':           de['destination']['destination_name'],
        'line_id':            de['destination']['line_name'].lower(),
        'line_name':          de['destination']['line_name'],
        'platform_name':      platform_name,
        'platform_prefix':    de['operator'],
        'time_to_station':    time_to_station,
        'is_realtime_data':   True if de['expected']['indicator'] == 'Live' else False,
        'time_expected':      timestamp if de['expected']['indicator'] == 'Live' else None,
        'time_planned':       timestamp if de['expected']['indicator'] == 'Timetabled' else None,
        'main_color':         '#62b9c3',
        'text_color':         '#f8f8f8',
      }
      entries.append(multimodal_structures.timetable_entry(te))

    pyotherside.send("a_get_predictions", entries)
    
tfgm_xml_object = TfgmXml()
