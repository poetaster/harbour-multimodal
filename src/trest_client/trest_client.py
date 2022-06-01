import urllib.request
import json
import re
from datetime import datetime
from datetime import timezone
import multimodal_structures

class TrestClient:
  API_JOURNEYS_URL_OLD = "https://v5.db.transport.rest/journeys?from={}&to={}&departure={}&results=3{}"
  API_JOURNEYS_URL = "https://v5.db.transport.rest/journeys?results=3&{}"
  API_TRIPS_URL = "https://v5.db.transport.rest/trips/{}?lineName={}"
  API_LOCATIONS_URL = "https://v5.db.transport.rest/locations?query={}&results=10&stops=true&addresses=false&poi=false&linesOfStops=true&fuzzy=false"

  API_DEPARTURES_DB = "https://v5.db.transport.rest/stops/{}/departures?taxi=false&duration=60"
  API_ARRIVALS_DB = "https://v5.db.transport.rest/stops/{}/arrivals?taxi=false&duration=60"
  API_DEPARTURES_VBB = "https://v5.vbb.transport.rest/stops/{}/departures"
  API_ARRIVALS_VBB = "https://v5.vbb.transport.rest/stops/{}/arrivals"

  ROUTE_MODES = ["national-express-rail", "national-rail", "regional-rail", "regional-express-rail", "overground", "tube", "tram", "bus", "walking"]

  def __init__(self):
    print("trest_client init")

    self.operator_colors = {
      "db-fernverkehr-ag": ['grey', '#ff0000'],
      "db-regio-ag": ['grey', '#ff0000'],
      "db-regionetz-verkehrs-gmbh-westfrankenbahn": ['grey', '#ff0000'],
      "db-regio-ag-baden-wurttemberg": ['grey', '#ff0000'],
      "abellio-rail-nrw-gmbh": ['grey', '#d5012e'],
      "abellio-rail-mitteldeutschland-gmbh": ['grey', '#d5012e'],
      "go-ahead-baden-wurttemberg-gmbh": ['grey', '#ffd400'],
      "go-ahead-deutschland-gmbh": ['grey', '#ffd400'],
      "go-ahead-bayern-gmbh": ['grey', '#0087cc'],
      "osterreichische-bundesbahnen": ['grey', '#e2002a'],
      "PKP": ['grey', '#002664'],
      "DB ZugBus Regionalverkehr Alb-Bodensee": ['grey', '#f01414'],
      "schweizerische-bundesbahnen": ['grey', '#ec0000'],
      "erfurter-bahn-gmbh": ['grey', '#4bae52'],
      "evb-elbe-weser-gmbh": ['grey', '#0057a3'],
      "ostdeutsche-eisenbahn-gmbh": ['grey', '#faa61a'],
    }

    self.line_main_colors = {
      's-bahn-berlin': {
        'S1': '#db639a',
        'S2': '#016d2f',
        'S25': '#016d2f',
        'S26': '#016d2f',
        'S3': '#0160a5',
        'S41': '#ab4e31',
        'S42': '#cc591d',
        'S45': '#cd934e',
        'S46': '#cd934e',
        'S47': '#cd934e',
        'S5': '#ef6919',
        'S7': '#77659e',
        'S75': '#77659e',
        'S8': '#5ba125',
        'S85': '#5ba125',
        'S9': '#95203e',
      },
      'vbb': {
        'U1': '#73a547',
        'U2': '#dd381f',
        'U3': '#017153',
        'U4': '#f5d22e',
        'U5': '#78492b',
        'U6': '#8466a3',
        'U7': '#3f86b2',
        'U8': '#4e789e',
        'U9': '#f86d22',
      },
      'db-regio-ag-s-bahn-stuttgart': {
        'S1': '#5c8e3c',
        'S2': '#dc022c',
        'S3': '#f4aa04',
        'S4': '#0c66b3',
        'S5': '#04a9e3',
        'S6': '#8b6204',
        'S60': '#748d20',
      },
      's-bahn-hamburg': { 
        'S1': '#018d2a',
        'S11': '#018d2a',
        'S2': '#b30b33',
        'S21': '#b30b33',
        'S3': '#4c1f64',
        'S31': '#4c1f64',
      },
      'db-regio-ag-nord': { #Hannover
        'S1': '#836caa',
        'S2': '#007a3c',
        'S21': '#007a3c',
        'S3': '#cb68a6',
        'S4': '#9a2a47',
        'S5': '#f18700',
        'S51': '#f18700',
        'S6': '#004f9e',
        'S7': '#afca26',
        'S8': '#009ad9',
      },
      'db-regio-ag-bayern': { #Munich
        'S1': '#1ab3e2',
        'S2': '#71bf44',
        'S20': '#f05a73',
        'S3': '#7b107d',
        'S4': '#ee1c25',
        'S6': '#008a51',
        'S7': '#963833',
        'S8': '#000000',
      },
      'db-regio-ag-s-bahn-rhein-main': { #Frankfurt
        'S1': '#0480b7',
        'S2': '#ff0000',
        'S3': '#019377',
        'S4': '#ffcc00',
        'S5': '#7f3107',
        'S6': '#f47922',
        'S7': '#01220e',
        'S8': '#7fc31c',
        'S9': '#81017e',
      },
      'db-regio-ag-mitte': { #Kaiserslautern Rhein-Neckar 
        'S1': '#ec192e',
        'S2': '#2960b5',
        'S3': '#fcd804',
        'S33': '#f3c3c4',
        'S39': '#eaeaea',
        'S4': '#1a9d47',
        'S5': '#f47a14',
        'S51': '#f8a20d',
        'S6': '#27c9f5',
        'S9': '#7ac547',
      },
      'db-regio-ag-nrw': { #Cologne Rhein-Ruhr
        'S1': '#0b9a33',
        'S2': '#006db6',
        'S28': '#717676',
        'S3': '#ffff00',
        'S4': '#ef7c00',
        'S5': '#fbef6d',
        'S6': '#dc052d',
        'S68': '#14bae6',
        'S7': '#14bae6',
        'S8': '#b03303',
        'S9': '#c7007f',
        'S11': '#ffed8d',
        'S12': '#61af20',
        'S19': '#2d6c7e',
        'S23': '#8b3c59',
      }
    }

    self.type_main_colors = {
      'STR': '#6a6a6a',
      'Bus': '#62b9c3',
    }

    self.type_mark_colors = {
      'U': '#014983',
      'S': '#018448',
    }

    self.type_text_colors = {
      'STR': '#f8f8f8',
      'Bus': '#f8f8f8',
    }

  def __url_get(self, url):
    req = urllib.request.Request(
      url,
      headers={
        'User-Agent': '007',
        'Content-Type': 'text/xml; charset=utf-8',
        'Connection': 'close',
      }
    )

    print(url)
    try:
      result = urllib.request.urlopen(req).read()
    except Exception as err:
      print("ERROR API request failed: %s" % err)
      return False

    values = []
    try:
      return json.loads(result)
    except Exception as e:
      print("ERROR JSON conversion: ", e)
      return False

  def time_diff(self, start_time_s, end_time_s):
    if (not start_time_s or not end_time_s):
      return 0

    start_time = datetime.fromisoformat(start_time_s)
    end_time = datetime.fromisoformat(end_time_s)
    return (end_time-start_time).total_seconds() / 60

  def time_to_station(self, expected_time_s):
    if not expected_time_s:
      return None

    return (datetime.fromisoformat(expected_time_s).timestamp()-datetime.now().timestamp())

  def to_timestamp(self, time_s):
    try:
      return datetime.fromisoformat(time_s).timestamp()
    except Exception:
      return None

  def to_icon(self, service_type):
    icons = {
      'bus': 'de_bus',
      'ec': 'de_ec',
      'est': 'de_est',
      'ic': 'de_ic',
      'ice': 'de_ice',
      'rb': 'de_rb',
      're': 'de_re',
      's': 'de_s',
      'str': 'de_str',
      'tgv': 'de_tgv',
      'u': 'de_u',
    }

    if service_type in icons:
      return icons[service_type]

    return None

  def remove_prefix(self, text, prefix):
    return text[len(prefix):].strip() if text.startswith(prefix) else text.strip()

  def modes_to_urlparams(self, modes):
    params = []

    if 'national-express-rail' in modes:
      params.append('nationalExpress=true')
    else:
      params.append('nationalExpress=false')

    if 'national-rail' in modes:
      params.append('national=true')
    else:
      params.append('national=false')

    if 'regional-express-rail' in modes:
      params.append('regionalExp=true')
    else:
      params.append('regionalExp=false')

    if 'regional-rail' in modes:
      params.append('regional=true')
    else:
      params.append('regional=false')

    if 'overground' in modes:
      params.append('suburban=true')
    else:
      params.append('suburban=false')

    if 'tube' in modes :
      params.append('subway=true')
    else:
      params.append('subway=false')

    if 'tram' in modes :
      params.append('tram=true')
    else:
      params.append('tram=false')

    if 'bus' in modes :
      params.append('bus=true')
    else:
      params.append('bus=false')

    if 'walking' in modes :
      params.append('startWithWalking=true')
    else:
      params.append('startWithWalking=false')

    return params


  def get_colors(self, agency, line_id, service_type, service_mode):
    main_color = None
    mark_color = None
    text_color = None

    #normalize agency
    if agency.startswith('08_'):
      agency = 's-bahn-berlin'
    elif agency.startswith('vbb'):
      agency = 'vbb'
    elif agency.startswith('_vrr'):
      agency = 'vrr'

    #normalize line id
    if line_id.startswith('U ') or line_id.startswith('S '):
      line_id = line_id.replace(' ', '')
    
    try:
      main_color = self.line_main_colors[agency][line_id]
    except:
      pass

    if not main_color and service_type in self.type_main_colors:
      main_color = self.type_main_colors[service_type]

    if service_type in self.type_mark_colors:
      mark_color = self.type_mark_colors[service_type]

    if service_type in self.type_text_colors:
      text_color = self.type_text_colors[service_type]

    if not main_color:
      main_color = 'grey'

    if not text_color:
      text_color = 'white'

    print('get_colors - agency: %s, line_id: %s, service_type: %s, service_mode: %s - main_color: %s, mark_color: %s, text_color: %s' % (agency, line_id, service_type, service_mode, main_color, mark_color, text_color))

    return main_color, mark_color, text_color

  def cleanup_destination(self, destination_name):
    if not destination_name or len(destination_name) < 1:
      return ""

    for station_type in ['(U), Berlin', '(S), Berlin', '(S+U), Berlin', '(S)', '(S-Bahn)', '(U)', '(S+U)', ', Berlin']:
      if destination_name.endswith(station_type):
        destination_name = destination_name[:-len(station_type)]

    return destination_name.strip()

  def cleanup_line_name(self, line_name):
    if not line_name or len(line_name) < 1:
      return ""

    for service_type in ['Bus', 'STR']:
      if line_name.startswith(service_type):
        line_name = line_name[len(service_type):]

    return line_name.strip()

  def get_journey_results(self, from_stop_point, to_stop_point, start_timestamp, preference, modes):
    params = []

    if from_stop_point['id'] and (from_stop_point['dataset_id'] == 3 or from_stop_point['dataset_id'] == 4):
      params.append("from=%s" % from_stop_point['id'])
    elif from_stop_point['lat'] and from_stop_point['lon']:
      params.append("from.latitude=%f" % from_stop_point['lat'])
      params.append("from.longitude=%f" % from_stop_point['lon'])
      params.append("from.address=%s" % re.sub('[^a-zA-Z0-9,\+]', '', from_stop_point['name'].replace(' ', '+')))
    else:
      return None

    if to_stop_point['id'] and (to_stop_point['dataset_id'] == 3 or to_stop_point['dataset_id'] == 4):
      params.append("to=%s" % to_stop_point['id'])
    elif to_stop_point['lat'] and to_stop_point['lon']:
      params.append("to.latitude=%f" % to_stop_point['lat'])
      params.append("to.longitude=%f" % to_stop_point['lon'])
      params.append("to.address=%s" % re.sub('[^a-zA-Z0-9,\+]', '', to_stop_point['name'].replace(' ', '+')))
    else:
      return None

    params.append("departure=%d" % start_timestamp)
    params += self.modes_to_urlparams(modes)

    request_url = self.API_JOURNEYS_URL.format("&".join(params))
    data = self.__url_get(request_url)

    if not data:
      return None

    journeys = []
    for journey in data["journeys"]:
      from_stop_point_name = None
      from_stop_point_id = None
      to_stop_point_name = None
      to_stop_point_id = None

      product_names = []

      yourney_entry = {
        'module': 'trest',
        'start_time': None,
        'arrival_time': None,
        'duration': 0,
        'legs': [],
      }

      for leg in journey["legs"]:
        if not leg["departure"]:
          leg["departure"] = leg["plannedDeparture"]
        
        if not leg["arrival"]:
          leg["arrival"] = leg["plannedArrival"]

        if (not yourney_entry['start_time']):
          yourney_entry['start_time'] = leg["departure"]
        yourney_entry['arrival_time'] = leg["arrival"]

        if "name" not in leg["origin"]:
          leg["origin"]["name"] = from_stop_point['name']

        if "name" not in leg["destination"]:
          leg["destination"]["name"] = to_stop_point['name']

        if (not from_stop_point_name):
          from_stop_point_name = leg["origin"]["name"]
          from_stop_point_id = leg["origin"]["id"]
          
        to_stop_point_name = leg["destination"]["name"]
        to_stop_point_id = leg["destination"]["id"]

        journey_leg = {
          'module': 'trest',
          'departure_time': leg["departure"],
          'arrival_time': leg["arrival"],
          'duration': self.time_diff(leg["departure"], leg["arrival"]),
          'departure_point_name': leg["origin"]["name"],
          'departure_point_id': leg["origin"]["id"],
          'arrival_point_name': self.cleanup_destination(leg["destination"]["name"]),
          'arrival_point_id': leg["destination"]["id"],
          'stops': [],
          'options': [],
          'disruptions': [],
          'trip_id': '',
        }
        
        journey_option = {'module': 'trest', 'name': '', 'directions': [], 'line_id': '', 'main_color': None, 'mark_color': None, 'text_color': None}

        if leg["origin"]["type"] == "location":
          journey_leg['departure_point_lat'] = leg["origin"]["latitude"]
          journey_leg['departure_point_lon'] = leg["origin"]["longitude"]
        else:
          journey_leg['departure_point_lat'] = leg["origin"]["location"]["latitude"]
          journey_leg['departure_point_lon'] = leg["origin"]["location"]["longitude"]

        if leg["destination"]["type"] == "location":
          journey_leg['departure_point_lat'] = leg["destination"]["latitude"]
          journey_leg['departure_point_lon'] = leg["destination"]["longitude"]
        else:
          journey_leg['arrival_point_lat'] = leg["destination"]["location"]["latitude"]
          journey_leg['arrival_point_lon'] = leg["destination"]["location"]["longitude"]
        
        if "departurePlatform" in leg and leg["departurePlatform"]:
          journey_leg['departure_point_platform'] = leg["departurePlatform"]

        if "arrivalPlatform" in leg and leg["arrivalPlatform"]:
          journey_leg['arrival_point_platform'] = leg["arrivalPlatform"]

        if "tripId" in leg:
          journey_leg['trip_id'] = leg["tripId"]
        
        if "walking" in leg:
          journey_leg['mode'] = 'walking'
          journey_leg['icon_name'] = 'walking'
          journey_option['name'] = 'Walk to ' + journey_leg['arrival_point_name']
          journey_option['main_color'], journey_option['mark_color'], journey_option['text_color'] = self.get_colors('', '', 'walking', 'walking')
          
        if "line" in leg:
          try:
            journey_leg['mode'] = leg["line"]["productName"].lower()
          except:
            journey_leg['mode'] = "train"

          try:
            journey_leg['icon_name'] = self.to_icon(leg['line']['productName'].lower())
          except:
            pass

          try:
            journey_option['main_color'], journey_option['mark_color'], journey_option['text_color'] = self.get_colors(leg["line"]["adminCode"], leg["line"]["name"].replace(' ', ''), leg["line"]["productName"], leg["line"]["mode"])
          except:
            pass
          
          if "operator" in leg["line"]:
            if not leg["line"]["name"]:
              leg["line"]["name"] = ""

            try:
              journey_option['main_color'], journey_option['mark_color'], journey_option['text_color'] = self.get_colors(leg["line"]["operator"]["id"], leg["line"]["name"].replace(' ', ''), leg["line"]["productName"], leg["line"]["mode"])
            except:
              print(leg["line"])
          
          try:
            journey_option['line_id'] = leg["line"]["id"]
          except:
            pass

          try:
            journey_option['name'] = self.cleanup_line_name(leg["line"]["name"])
            product_names.append(leg["line"]["name"])
          except:
            pass

        if "direction" in leg:
          journey_option['directions'] = [leg["direction"]]

        journey_leg['options'].append(multimodal_structures.route_options_entry(journey_option))
        yourney_entry['legs'].append(multimodal_structures.journey_leg_entry(journey_leg))

      yourney_entry["duration"] = self.time_diff(yourney_entry["start_time"], yourney_entry["arrival_time"])

      if "price" in journey and journey['price']:
        fare = {
          'start_time': yourney_entry["start_time"],
          'end_time': yourney_entry["arrival_time"],
          'departure_point_name': from_stop_point_name,
          'departure_point_id': from_stop_point_id,
          'arrival_point_name': to_stop_point_name,
          'arrival_point_id': to_stop_point_id,
          'route_description': ', '.join(product_names),
          'passenger_type': '',
          'contactelss_only': False,
          'tickets': [
            {
              'passenger_type': '',
              'ticket_type': '',
              'ticket_type_description': '',
              'ticket_time': '',
              'ticket_time_description': '',
              'cost': journey['price']['amount'],
              'description': journey['price']['hint'],
              'mode': '',
              'currency': '€' if journey['price']['currency'] == 'EUR' else journey['price']['currency'],
            }
          ],
        }
        yourney_entry['fare'] = fare

      journeys.append(multimodal_structures.journey_entry(yourney_entry))

    return journeys

  def get_calling_points(self, trip_id, line_id, from_stop_point_id = None, to_stop_point_id = None):
    request_url = self.API_TRIPS_URL.format(trip_id, line_id)
    data = self.__url_get(request_url)
    
    origin_id = None
    destination_id = None

    try:
      origin_id = data["origin"]["id"]
    except:
      pass
    
    try:
      destination_id = data["destination"]["id"]
    except:
      pass

    from_reached = False
    stops = []
    for sp in data["stopovers"]:
      cp = {
        'module': 'trest',
        'trip_id': trip_id,
        'time_to_station': self.time_to_station(sp['arrival'] or sp["departure"]),
        'time_expected': self.to_timestamp(sp['arrival'] or sp["departure"]),
        'set_index': 0,
      }

      try:
        cp['calling_point_id'] = sp["stop"]["id"]
      except:
        pass

      try:
        cp['calling_point_name'] = sp["stop"]["name"]
        cp['title'] = self.cleanup_destination(sp["stop"]["name"])
      except:
        pass

      if origin_id and origin_id == cp['calling_point_id']:
        cp['is_origin'] = True
      
      if destination_id and destination_id == cp['calling_point_id']:
        cp['is_destination'] = True

      if from_stop_point_id and not from_reached:
        if cp['calling_point_id'] == from_stop_point_id:
          from_reached = True
        continue

      if to_stop_point_id and cp['calling_point_id'] == to_stop_point_id:
        break

      stops.append(multimodal_structures.calling_point_entry(cp))

    return stops

  def get_trips_results(self, trip_id, line_id, from_stop_point_id = None, to_stop_point_id = None):
    request_url = self.API_TRIPS_URL.format(trip_id, line_id)
    data = self.__url_get(request_url)
    
    from_reached = False
    stops = []
    remarks = []

    for stop_point in data["stopovers"]:
      stop_entry = {'id': '0', 'name': 'unknown'}
      try:
        stop_entry['id'] = stop_point["stop"]["id"]
      except:
        stop_entry['id'] = '0'
      try:
        stop_entry['name'] = stop_point["stop"]["name"]
      except:
        stop_entry['name'] = 'unknown'

      if from_stop_point_id and not from_reached:
        if stop_entry['id'] == from_stop_point_id:
          from_reached = True
        continue

      if to_stop_point_id and stop_entry['id'] == to_stop_point_id:
        break

      stop_entry['naptanId'] = stop_entry['id']
      stop_entry['stop_code'] = ''
      stop_entry['stationName'] = stop_entry['name']
      stop_entry['timeToStation'] = self.time_to_station(stop_point['arrival'] or stop_point["departure"])
      stop_entry['expectedArrival'] = stop_point["arrival"]
      stop_entry['plannedArrival'] = stop_point["plannedArrival"]
      stop_entry['expectedDeparture'] = stop_point["departure"]
      stop_entry['plannedDeparture'] = stop_point["plannedDeparture"]

      stops.append(stop_entry)

    if "remarks" in data:
      for remark_data in data["remarks"]:
        remark = {'type': 'unknown', 'text': '', 'code': '', 'summary': ''}
        if 'type' in remark_data:
          remark['type'] = remark_data['type']
        if 'text' in remark_data:
          remark['text'] = remark_data['text']
        if 'code' in remark_data:
          remark['code'] = remark_data['code']
        if 'summary' in remark_data:
          remark['summary'] = remark_data['summary']

        remarks.append(remark)

    origin_id = None
    destination_id = None

    try:
      origin_id = data["origin"]["id"]
    except:
      pass
    
    try:
      destination_id = data["destination"]["id"]
    except:
      pass

    return {'trip_id': trip_id, 'line_id': line_id, 'origin_id': origin_id, 'destination_id': destination_id, 'stops': stops, 'remarks': remarks}


  def get_arrivals_departures_board(self, stop_point_id, dataset_id, arrivals = False):
    if dataset_id == 5:
      if arrivals:
        request_url = self.API_ARRIVALS_VBB.format(stop_point_id)
      else:
        request_url = self.API_DEPARTURES_VBB.format(stop_point_id)
    else:
      if arrivals:
        request_url = self.API_ARRIVALS_DB.format(stop_point_id)
      else:
        request_url = self.API_DEPARTURES_DB.format(stop_point_id)

    data = self.__url_get(request_url)
    
    if not data:
      return []

    services = []
    for tr in data:
      main_color, mark_color, text_color = self.get_colors(tr['line']['adminCode'], tr['line']['name'], tr['line']['productName'], tr['line']['product'])

      te = {
        'module':             'trest',
        'is_departure':       not arrivals,
        'title':              self.cleanup_destination(tr['destination']['name'] if tr['destination'] else ''),
        'subtitle':           self.cleanup_line_name(tr['line']['name']),
        'service_id':         tr['tripId'],
        'line_id':            tr['line']['id'],
        'line_name':          tr['line']['name'],
        'transport_mode':     tr['line']['product'],
        'towards':            tr['direction'],
        'time_planned':       self.to_timestamp(tr['plannedWhen']),
        'time_expected':      self.to_timestamp(tr['when']),
        'is_realtime_data':   True,
        'platform_name':      tr['platform'],
        'time_to_station':    self.time_to_station(tr['when']),
        'main_color':         main_color,
        'mark_color':         mark_color,
        'text_color':         text_color,
        'icon_name':          self.to_icon(tr['line']['productName'].lower()),
      }

      if tr['line']['product'] == 'bus' or tr['line']['product'] == 'tram':
        te['title'] = self.cleanup_line_name(tr['line']['name'])
        te['subtitle'] = self.cleanup_destination(tr['destination']['name'] if tr['destination'] else '')
        if arrivals and tr['provenance']:
          te['subtitle'] = self.cleanup_destination(tr['provenance'])
      elif arrivals and tr['provenance']:
        te['title'] = self.cleanup_destination(tr['provenance'])

      services.append(multimodal_structures.timetable_entry(te))

    return services



  def search_stops(self, search_str):
    request_url = self.API_LOCATIONS_URL.format(re.sub('[^a-zA-Z0-9,\+]', '', search_str.replace(' ', '+')))
    data = self.__url_get(request_url)

    stop_points = []
    if not data:
      return []

    for stop in data:
      stop_point = {
        'id': stop['id'],
        'name': stop['name'],
        'lat': 0,
        'lon': 0,
        'modes': '',
        'lines': '',
        'stop_letter': '',
        'towards': '',
        'stop_type': 0,
        'fare_zone': '',
        'dataset_id': 4,
        'numbering_area': 2,
      }

      if 'location' in stop:
        stop_point['lat'] = stop['location']['latitude']
        stop_point['lon'] = stop['location']['longitude']

      lines = {}
      if 'lines' in stop:
        for line in stop['lines']:
          if line['name']:
            lines[line['name']] = True

        stop_point['lines'] = ','.join(lines.keys())

      products = {}
      if 'products' in stop:
        if stop['products']['nationalExpress']:
          products['national-rail'] = True
        if stop['products']['national']:
          products['national-rail'] = True
        if stop['products']['regionalExp']:
          products['national-rail'] = True
        if stop['products']['regional']:
          products['national-rail'] = True
        if stop['products']['suburban']:
          products['overground'] = True
        if stop['products']['bus']:
          products['bus'] = True
        if stop['products']['ferry']:
          products['ferry'] = True
        if stop['products']['subway']:
          products['tube'] = True
        if stop['products']['tram']:
          products['tram'] = True
        if stop['products']['taxi']:
          products['taxi'] = True

        stop_point['modes'] = ','.join(products.keys())
      stop_points.append(stop_point)

    return stop_points