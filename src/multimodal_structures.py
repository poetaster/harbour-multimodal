#!/usr/bin/env python3
# -*- coding: utf-8 -*-

def timetable_entry(*value_ds):
  entry = {
    'module': '',
    'entry_id': None,
    'service_id': None,
    'vehicle_id': None,
    'vehicle_id_display': False,
    'is_departure': True,
    'title': '',
    'subtitle': '',
    'via': None,
    'line_id': None,
    'line_name': None,
    'destination_id': None,
    'origin_id': None,
    'towards': None,
    'transport_mode': None,
    'time_to_station': None,
    'time_delay': 0,
    'time_planned': None,
    'time_expected': None,
    'is_realtime_data': False,
    'is_delayed': False,
    'delay_reason': None,
    'is_cancelled': False,
    'cancel_reason': None,
    'platform_name': None,
    'platform_prefix': None,
    'platform_changed': False,
    'stop_letter': False,
    'number_carriages': 0,
    'is_fastest_service': False,
    'origin_codes': [],
    'destination_codes': [],
    'calling_points': [],
    'messages': [],
    'main_color': None,
    'mark_color': None,
    'text_color': None,
    'icon_name': None,
  }

  for value_d in value_ds:
    entry = {**entry, **value_d}

  return entry

def calling_point_entry(*value_ds):
  entry = {
    'module': '',
    'trip_id': None,
    'calling_point_id': None,
    'calling_point_name': None,
    'title': None,
    'time_to_station': None,
    'time_expected': None,
    'set_index': None,
    'stop_code': None,
    'stop_letter': False,
    'is_cancelled': False,
    'is_delayed': False,
    'is_requesting_station': False,
    'is_origin': False,
    'is_destination': False,
  }

  for value_d in value_ds:
    entry = {**entry, **value_d}

  return entry

def journey_entry(*value_ds):
  entry = {
    'module': '',
    'start_time': None,
    'arrival_time': None,
    'duration': None,
    'legs': [],
  }

  for value_d in value_ds:
    entry = {**entry, **value_d}

  return entry

def journey_leg_entry(*value_ds):
  entry = {
    'module': '',
    'departure_time': None,
    'arrival_time': None,
    'duration': None,
    'mode': None,
    'id_disrupted': None,
    'summary': None,
    'detailed_instruction': None,
    'departure_point_name': None,
    'departure_point_id': None,
    'departure_point_platform': None,
    'departure_point_lat': None,
    'departure_point_lon': None,
    'departure_point_stop_letter': None,
    'arrival_point_name': None,
    'arrival_point_id': None,
    'arrival_point_platform': None,
    'arrival_point_lat': None,
    'arrival_point_lon': None,
    'arrival_point_stop_letter': None,
    'icon_name': None,
    'stops': [],
    'options': [],
    'disruptions': [],
  }

  for value_d in value_ds:
    entry = {**entry, **value_d}

  return entry

def route_options_entry(*value_ds):
  entry = {
    'module': '',
    'name': None, 
    'directions': None, 
    'line_id': None,
    'main_color': None,
    'mark_color': None,
    'text_color': None,
  }

  for value_d in value_ds:
    entry = {**entry, **value_d}

  return entry

def route_disruptions_entry(*value_ds):
  entry = {
    'module': '',
    'category': None, 
    'description': None, 
    'updated': None,
  }

  for value_d in value_ds:
    entry = {**entry, **value_d}

  return entry