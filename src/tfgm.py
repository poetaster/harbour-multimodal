# -*- coding: utf-8 -*-
import pyotherside
from datetime import datetime, timedelta
import re
from tfgm_client.tfgm_client import TfgmClient
import multimodal_structures
import multimodal_functions

class Tfgm:
  MAX_RESULTS = 1000

  LINE_MAP = {'Altrincham – Bury': 
['altrincham',
 'navigationroad',
 'timperley',
 'brooklands',
 'sale',
 'daneroad',
 'stretford',
 'oldtrafford',
 'traffordbar',
 'cornbrook',
 'deansgatecastlefield',
 'stpeterssquare',
 'marketstreet',
 'shudehill',
 'victoria',
 'queensroad',
 'abrahammoss',
 'crumpsall',
 'bowkervale',
 'heatonpark',
 'prestwich',
 'bessesothbarn',
 'whitefield',
 'radcliffe',
 'bury'],
 'Altrincham – Piccadilly': 
['altrincham',
 'navigationroad',
 'timperley',
 'brooklands',
 'sale',
 'daneroad',
 'stretford',
 'oldtrafford',
 'traffordbar',
 'cornbrook',
 'deansgatecastlefield',
 'stpeterssquare',
 'piccadillygardens',
 'piccadilly'],
 'Ashton-under-Lyne – Eccles': 
['ashtonunderlyne','ashton'
 'ashtonwest',
 'ashtonmoss',
 'audenshaw',
 'droylsden',
 'cemeteryroad',
 'edgelane',
 'claytonhall',
 'velopark',
 'etihadcampus',
 'holttown',
 'newislington',
 'piccadilly',
 'piccadillygardens',
 'stpeterssquare',
 'deansgatecastlefield',
 'cornbrook',
 'pomona',
 'exchangequay',
 'salfordquays',
 'anchorage',
 'harbourcity',
 'mediacityuk',
 'broadway',
 'langworthy',
 'weaste',
 'ladywell',
 'eccles'],
 'Etihad Campus – MediaCityUK': 
['etihadcampus',
 'holttown',
 'newislington',
 'piccadilly',
 'piccadillygardens',
 'stpeterssquare',
 'deansgatecastlefield',
 'cornbrook',
 'pomona',
 'exchangequay',
 'salfordquays',
 'anchorage',
 'harbourcity',
 'mediacityuk'],
 'Bury – Piccadilly': 
['bury',
 'radcliffe',
 'whitefield',
 'bessesothbarn',
 'prestwich',
 'heatonpark',
 'bowkervale',
 'crumpsall',
 'abrahammoss',
 'queensroad',
 'victoria',
 'shudehill',
 'marketstreet',
 'piccadillygardens',
 'piccadilly'],
 'East Didsbury – Rochdale Town': 
['eastdidsbury',
 'didsburyvillage',
 'westdidsbury',
 'burtonroad',
 'withington',
 'stwerburghsroad',
 'chorlton',
 'firswood',
 'traffordbar',
 'cornbrook',
 'deansgatecastlefield',
 'stpeterssquare',
 'exchangesquare',
 'victoria',
 'monsall',
 'centralpark',
 'newtonheathandmoston',
 'failsworth',
 'hollinwood',
 'southchadderton',
 'freehold',
 'westwood',
 'oldhamkingstreet',
 'oldhamcentral',
 'oldhammumps',
 'derker',
 'shawandcrompton',
 'newhey',
 'milnrow',
 'kingswaybusinesspark',
 'newbold',
 'rochdalerailwaystation',
 'rochdaletowncentre'],
 'East Didsbury – Shaw and Crompton': 
['eastdidsbury',
 'didsburyvillage',
 'westdidsbury',
 'burtonroad',
 'withington',
 'stwerburghsroad',
 'chorlton',
 'firswood',
 'traffordbar',
 'cornbrook',
 'deansgatecastlefield',
 'stpeterssquare',
 'exchangesquare',
 'victoria',
 'monsall',
 'centralpark',
 'newtonheathandmoston',
 'failsworth',
 'hollinwood',
 'southchadderton',
 'freehold',
 'westwood',
 'oldhamkingstreet',
 'oldhamcentral',
 'oldhammumps',
 'derker',
 'shawandcrompton'],
 'The Trafford Centre – Cornbrook': 
['thetraffordcentre',
 'bartondockroad',
 'parkway',
 'village',
 'imperialwarmuseum',
 'wharfside',
 'pomona',
 'cornbrook'],
 'Manchester Airport – Victoria': 
['manchesterairport',
 'shadowmoss',
 'peelhall',
 'robinswoodroad',
 'wythenshawetowncentre',
 'crossacres',
 'benchill',
 'martinscroft',
 'roundthorn',
 'baguley',
 'moorroad',
 'wythenshawepark',
 'northernmoor',
 'salewaterpark',
 'barlowmoorroad',
 'stwerburghsroad',
 'chorlton',
 'firswood',
 'traffordbar',
 'cornbrook',
 'deansgatecastlefield',
 'stpeterssquare',
 'marketstreet',
 'shudehill',
 'victoria']}

  def __init__(self):
    print('tfgm init')
    self.client = TfgmClient()
    self.app = None

  def set_app(self, qobject):
    self.app = qobject

  def set_python_handler(self, qobject):
    self.python_handler = qobject

  def to_datetime(self, date_s):
    return multimodal_functions.time_to_utc(datetime.strptime(date_s, '%Y-%m-%dT%H:%M:%SZ'), multimodal_functions.TIMEZONE_UK)

  def line_color(self, line_id):
    colors = colors = {
      'altrinchambury': '#318C2C',
      'altrinchampiccadilly': '#7B2082',
      'ashtonunderlyneeccles': '#59C6F2',
      'etihadcampusmediacityuk': '#F18800',
      'burypiccadilly': '#EFBB00',
      'eastdidsburyrochdaletown': '#FE79B0',
      'eastdidsburyshawandcrompton': '#82735E',
      'thetraffordcentrecornbrook': '#E70310',
      'manchesterairportvictoria': '#0069B4',
    }

    if line_id in colors:
      return colors[line_id]

    return "grey"

  def line_text_color(self, line_id):
    colors = colors = {
      'burypiccadilly': '#000000',
    }

    if line_id in colors:
      return colors[line_id]

    return "white"


  def find_line_name(self, station, destination):
    station_c = re.sub(r'\W+', '', station).lower()
    destination_c = re.sub(r'\W+', '', destination.split(' via ', 1)[0]).lower()

    for line_name in Tfgm.LINE_MAP:
      station_p = Tfgm.LINE_MAP[line_name][0] == station_c or Tfgm.LINE_MAP[line_name][-1] == station_c
      destination_p = Tfgm.LINE_MAP[line_name][0] == destination_c or Tfgm.LINE_MAP[line_name][-1] == destination_c
      if station_p and destination_p:
        return line_name

    for line_name in Tfgm.LINE_MAP:
      station_p = False
      destination_p = Tfgm.LINE_MAP[line_name][0] == destination_c or Tfgm.LINE_MAP[line_name][-1] == destination_c
      
      for index, line_station in enumerate(Tfgm.LINE_MAP[line_name]):
        if re.sub(r'\W+', '', line_station).lower() ==  station_c:
          station_p = True
      if station_p and destination_p:
        return line_name

    for line_name in Tfgm.LINE_MAP:
      station_p = False
      destination_p = False
      for index, line_station in enumerate(Tfgm.LINE_MAP[line_name]):
        if re.sub(r'\W+', '', line_station).lower() ==  station_c:
          station_p = True
        if re.sub(r'\W+', '', line_station).lower() ==  destination_c:
          destination_p = True  

      if station_p and destination_p:
        return line_name

    return ''

  def create_service(self, station_id, station_name, station_line_name, destination, carriages, wait_minutes_s, timestamp_s):
    wait_minutes = int(wait_minutes_s)
    timestamp = self.to_datetime(timestamp_s)
    length = 0
    if carriages == "Single":
      length = 1
    elif carriages == "Double":
      length = 2
    elif carriages == "Triple":
      length = 3

    line_name = self.find_line_name(station_name, destination)
    
    te = {
      'module':             'tfgm',
      'is_departure':       True,
      'transport_mode':     'tram',
      'title':              destination,
      'subtitle':           line_name,
      'line_id':            re.sub(r'\W+', '', line_name.strip()).lower(),
      'line_name':          line_name,
      'time_to_station':    wait_minutes * 60,
      'is_realtime_data':   True,
      'time_expected':      timestamp + (wait_minutes * 60),
      'main_color':         self.line_color(re.sub(r'\W+', '', line_name.strip()).lower()),
      'mark_color':         None,
      'text_color':         self.line_text_color(re.sub(r'\W+', '', line_name.strip()).lower()),
      'number_carriages':   length,
    }

    return multimodal_structures.timetable_entry(te)

  def r_get_predictions(self, stop_point_id):
    services = []
    location_codes = {}

    result = self.client.get_departures(stop_point_id)
    if result == False or 'value' not in result:
      pyotherside.send("error", "tfgm", "r_get_predictions", 'No result')
      return

    station_messages = []
    for tr in result['value']:
      if tr['AtcoCode'] in location_codes:
        continue
      location_codes[tr['AtcoCode']] = True

      for index_i in range(3):
        index = str(index_i)
        if len(tr['Dest' + index]) > 0:
          service = self.create_service(tr['AtcoCode'], tr['StationLocation'], tr['Line'], tr['Dest' + index], tr['Carriages' + index], tr['Wait' + index], tr['LastUpdated'])
          services.append(service)
          if len(tr['MessageBoard']) > 0 and tr['MessageBoard'] != '<no message>' and tr['MessageBoard'].startswith("^F0Next Altrincham Departures:") == False:
            station_messages.append(tr['MessageBoard'].replace('^F0', ' ').replace('^J', ' '))

    pyotherside.send("a_get_predictions", services)
    
    if len(station_messages) > 0:
      pyotherside.send("a_get_station_messages", set(station_messages))

tfgm_object = Tfgm()
