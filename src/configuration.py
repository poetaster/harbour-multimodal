# -*- coding: utf-8 -*-
import pyotherside
import os
#from os.path import exists
import time
import sqlite3
import json
import shutil

class MultiModalConfiguration:
  def __init__(self):
    try:
      self.configuration_directory = os.environ['XDG_CONFIG_HOME'] + "/app.qml/multimodal/"
      self.configuration_directory_old = os.environ['HOME'] + "/.config/harbour-multimodal/"
    except KeyError:
      self.configuration_directory = os.environ['HOME'] + "/.config/app.qml/multimodal/"
      self.configuration_directory_old = os.environ['HOME'] + "/.config/harbour-multimodal/"

    try:
      self.data_directory = os.environ['XDG_DATA_HOME'] + "/app.qml/multimodal/"
      self.data_directory_old = os.environ['XDG_DATA_HOME'] + "/harbour-multimodal/"
    except KeyError:
      self.data_directory = os.environ['HOME'] + "/.local/share/app.qml/multimodal/"
      self.data_directory_old = os.environ['HOME'] + "/.local/share/harbour-multimodal/"

    self.configuration_database = self.configuration_directory + "settings.db"
    self.map_cache_database = self.data_directory + "mbgl-cache.db"
    self.program_version = "0.0"

  def __dict_factory(self, cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
      d[col[0]] = row[idx]
    return d

  def __first_factory(self, cursor, row):
    return row[0]

  def create_configuration(self):
    try:
      os.makedirs(self.configuration_directory)
    except FileExistsError:
      pass
    try:
      os.makedirs(self.data_directory)
    except FileExistsError:
      pass

    if not os.path.exists(self.configuration_database):
      try:
        print("create_configuration - migrating to new configuration path: ", self.configuration_database)
        shutil.copyfile(self.configuration_directory_old + "settings.db", self.configuration_database)
        os.remove(self.data_directory_old + "mbgl-cache.db")
      except IOError:
        pass

    con = sqlite3.connect(self.configuration_database)
    con.row_factory = self.__dict_factory
    cur = con.cursor()

    create_database_chema = False

    migration = 0

    try:
      result = cur.execute("SELECT * FROM schema_migrations ORDER BY version DESC LIMIT 1", []).fetchone()
      if (result):
        print("MultiModalConfiguration - installed migration: ", result['version'])
        migration = result['version']

    except sqlite3.OperationalError:
      print("MultiModalConfiguration - Creating new database")
      create_database_chema = True
      
    if create_database_chema:
      cur.execute("CREATE TABLE schema_migrations (version INTEGER NOT NULL PRIMARY KEY, program_version TEXT)", [])

    if migration < 2:
      cur.execute("INSERT INTO schema_migrations (version, program_version) VALUES (?, ?)", [2, self.program_version])
      cur.execute("CREATE TABLE saved_stop_points (id TEXT NOT NULL PRIMARY KEY, selection_type INTEGER, created_at INTEGER, updated_at INTEGER)", [])
      con.commit()

    if migration < 3:
      cur.execute("INSERT INTO schema_migrations (version, program_version) VALUES (?, ?)", [3, self.program_version])
      cur.execute("DROP TABLE IF EXISTS settings", [])
      cur.execute("CREATE TABLE settings (section TEXT NOT NULL DEFAULT 'general', name TEXT NOT NULL, value TEXT, data_type TEXT, PRIMARY KEY (section, name))", [])
      self.save_setting(cur, "location", "use_location", True)
      self.save_setting(cur, "location", "search_radius", 500)
      self.save_setting(cur, "general", "program_version", 0.0)
      con.commit()

    if migration < 4:
      cur.execute("INSERT INTO schema_migrations (version, program_version) VALUES (?, ?)", [4, self.program_version])
      self.save_setting(cur, "routing", "preference", "leastinterchange")
      self.save_setting(cur, "routing", "start_time_offset", 10)
      self.save_setting(cur, "routing", "modes", ["national-rail","tflrail","overground","tube","dlr","tram","bus","replacement-bus","walking"])
      con.commit()

    if migration < 5:
      cur.execute("INSERT INTO schema_migrations (version, program_version) VALUES (?, ?)", [5, self.program_version])
      self.save_setting(cur, "routing", "request_fares", False)
      self.save_setting(cur, "sorting", "order_train_stations", 1)
      self.save_setting(cur, "sorting", "order_metro_stations", 1)
      self.save_setting(cur, "sorting", "order_bus_stops", 1)
      con.commit()

    if migration < 6:
      cur.execute("INSERT INTO schema_migrations (version, program_version) VALUES (?, ?)", [6, self.program_version])
      self.save_setting(cur, "location", "use_wifi_location", False)
      con.commit()
      
    if migration < 7:
      cur.execute("INSERT INTO schema_migrations (version, program_version) VALUES (?, ?)", [7, self.program_version])
      self.save_setting(cur, "history", "from_stop_point_id", '')
      self.save_setting(cur, "history", "from_stop_point_name", '')
      self.save_setting(cur, "history", "from_stop_point_code", '')
      self.save_setting(cur, "history", "to_stop_point_id", '')
      self.save_setting(cur, "history", "to_stop_point_name", '')
      self.save_setting(cur, "history", "to_stop_point_code", '')
      self.save_setting(cur, "history", "stop_point_id", '')
      self.save_setting(cur, "history", "stop_point_name", '')
      self.save_setting(cur, "history", "stop_point_code", '')
      self.save_setting(cur, "history", "active_page", '')
      self.save_setting(cur, "history", "map_zoom", 14.0)
      con.commit()

    if migration < 8:
      cur.execute("INSERT INTO schema_migrations (version, program_version) VALUES (?, ?)", [8, self.program_version])
      self.save_setting(cur, "data_source", "numbering_area", 1)
      con.commit()

    if migration < 9:
      cur.execute("INSERT INTO schema_migrations (version, program_version) VALUES (?, ?)", [9, self.program_version])
      self.save_setting(cur, "smartwatch", "fastest_train_alert", True)
      self.save_setting(cur, "smartwatch", "reload_button", 2)
      con.commit()

    if migration < 10:
      cur.execute("INSERT INTO schema_migrations (version, program_version) VALUES (?, ?)", [10, self.program_version])
      self.save_setting(cur, "predictions", "reload_timer", 62)
      con.commit()

    if migration < 11:
      cur.execute("INSERT INTO schema_migrations (version, program_version) VALUES (?, ?)", [11, self.program_version])
      self.save_setting(cur, "history", "show_in_menu", True)
      con.commit()

    if migration < 12:
      cur.execute("INSERT INTO schema_migrations (version, program_version) VALUES (?, ?)", [12, self.program_version])
      cur.execute("DROP TABLE saved_stop_points")
      cur.execute("CREATE TABLE saved_stop_points (id TEXT NOT NULL, stop_code TEXT DEFAULT '', name TEXT NOT NULL, lat REAL, lon REAL, indicator TEXT DEFAULT '', stop_letter TEXT DEFAULT '', fare_zone TEXT DEFAULT '', towards TEXT DEFAULT '', heading TEXT DEFAULT '', stop_type INTEGER DEFAULT 0, traffic_type INTEGER DEFAULT 0, dataset_id INTEGER DEFAULT 0, numbering_area INTEGER DEFAULT 0, modes TEXT DEFAULT '', lines TEXT DEFAULT '', created_at INTEGER DEFAULT 0, updated_at INTEGER DEFAULT 0, UNIQUE(id, numbering_area))")
      con.commit()

    if migration < 13:
      cur.execute("INSERT INTO schema_migrations (version, program_version) VALUES (?, ?)", [13, self.program_version])
      cur.execute("UPDATE settings SET value = REPLACE(value, ?, ?) WHERE section = ? AND name= ?", ['"tflrail"', '"elizabeth-line"', 'routing', 'modes'])
      con.commit()

    if migration < 14:
      cur.execute("INSERT INTO schema_migrations (version, program_version) VALUES (?, ?)", [14, self.program_version])
      self.save_setting(cur, "routing", "show_calling_points", True)
      con.commit()
      
    con.close()

  def cast_setting(self, setting_entry):
    if setting_entry['data_type'] == 'bool':
      return setting_entry['value'] == "1"
    elif setting_entry['data_type'] == 'float':
      return float(setting_entry['value'])
    elif setting_entry['data_type'] == 'int':
      return int(setting_entry['value'])
    elif setting_entry['data_type'] == 'list':
      return json.loads(setting_entry['value'])
    else:
      return setting_entry['value']

  def save_setting(self, cur, section, name, value):
    data_type = type(value).__name__
    value_s = value
    print("save_setting - section:", section," setting name:", name, ", value:", value, ", data type: ", data_type)
    if data_type == 'list':
      value_s = json.dumps(value)
    return cur.execute("INSERT INTO settings (section, name, value, data_type) VALUES (:section, :name, :value, :data_type) ON CONFLICT (section, name) DO UPDATE SET value = :value, data_type = :data_type", {'section': section, 'name': name, 'value': value_s, 'data_type': data_type })

  def load(self, program_version):
    self.program_version = program_version
    self.create_configuration()

    con = sqlite3.connect(self.configuration_database)
    con.row_factory = self.__dict_factory
    cur = con.cursor()
    
    result = cur.execute("SELECT * FROM settings", []).fetchall()
    con.close()

    settings = {
      '_paths': {
        'configuration_directory': self.configuration_directory,
        'data_directory': self.data_directory,
        'configuration_database':self.configuration_database,
        'map_cache_database':self.map_cache_database,
      },
      '_default_keys': {
        'mapbox_key': 'pk.eyJ1IjoiYW5hcmNoeS1pbi10aGUtdWsiLCJhIjoiY2twbnRxdGVpMGYxZDJwcDRseHoyMTd5bCJ9.df75IhuH1tbEVAWOOJfCrA',
      },
    }
    if (result):
      for entry in result:
        if entry['section'] not in settings:
          settings[entry['section']] = {}
        settings[entry['section']][entry['name']] = self.cast_setting(entry)

    return settings

  def save(self, settings):
    con = sqlite3.connect(self.configuration_database)
    cur = con.cursor()
    
    for section_name in settings:
      if section_name.startswith('_'):
        continue
      if type(settings[section_name]).__name__ != 'dict':
        print("save - ERROR - section:", section_name, '/', settings[section_name], '/', type(settings[section_name]).__name__)
        continue
      for entry_name in settings[section_name]:
        self.save_setting(cur, section_name, entry_name, settings[section_name][entry_name])
        
      
    con.commit()
    con.close()

  def saved_stop_points_get_area(self, numbering_area):
    con = sqlite3.connect(self.configuration_database)
    con.row_factory = self.__dict_factory
    cur = con.cursor()
    
    result = cur.execute("SELECT * FROM saved_stop_points WHERE numbering_area = ?", [numbering_area]).fetchall()
    for stop_point in result:
      stop_point['saved'] = True

    con.close()
    return result

  def saved_stop_points_delete(self, stop_point_id, numbering_area):
    con = sqlite3.connect(self.configuration_database)
    con.row_factory = self.__first_factory
    cur = con.cursor()
    
    cur.execute("DELETE FROM saved_stop_points WHERE id = ? AND numbering_area = ?", [stop_point_id, numbering_area])
    con.commit()
    con.close()
    return cur.rowcount

  def saved_stop_points_save(self, stop_point):
    con = sqlite3.connect(self.configuration_database)
    con.row_factory = self.__first_factory
    cur = con.cursor()
    timestamp = int(time.time())

    cur.execute("INSERT INTO saved_stop_points (%s) VALUES (:%s) " % (','.join(stop_point.keys()), ',:'.join(stop_point.keys())), stop_point)
    con.commit()
    con.close()
    return cur.rowcount

multimodal_configuration = MultiModalConfiguration()
