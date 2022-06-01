import json
import urllib.request
import multimodal_structures

class TflClient:
  STOP_POINT_ARRIVALS_URL="https://api.tfl.gov.uk/StopPoint/{}/Arrivals"
  VEHICLE_ARRIVALS_URL="https://api.tfl.gov.uk/Vehicle/{}/Arrivals"
  JOURNEY_RESULTS_URL="https://api.tfl.gov.uk/Journey/JourneyResults/{}/to/{}?date={}&time={}&journeyPreference={}&timeIs=departing&useRealTimeLiveArrivals=true&useMultiModalCall=false&nationalSearch=true&mode={}"
  FARE_FINDER_URL="https://api.tfl.gov.uk/StopPoint/{}/FareTo/{}"
  MODE_DISRUPTIONS_URL="https://api.tfl.gov.uk/Line/Mode/{}/Disruption"
  LINE_DISRUPTIONS_URL="https://api.tfl.gov.uk/Line/{}/Disruption"
  MODE_STATUS_URL="https://api.tfl.gov.uk/Line/Mode/{}/Status"
  ROUTE_MODES=["black-cab-as-customer","bus","cable-car","coach","cycle","cycle-hire","dlr","electric-car","international-rail","national-rail","overground","plane","private-car","private-coach-as-customer","private-hire-as-customer","replacement-bus","river-bus","taxi","tflrail","elizabeth-line","tram","tube","walking"]

  def __init__(self):
    print("tfl_client init")

  def __url_get(self, url):
    req = urllib.request.Request(
      url,
      headers={
        'User-Agent': '007',
        'Content-Type': 'text/plain; charset=UTF-8'
      }
    )

    try:
      result = urllib.request.urlopen(req).read()
    except Exception as err:
      print("ERROR egt request failed: %s" % err)
      return False

    try:
      return json.loads(result)

    except Exception as err:
      print("### ERROR converting result: %s" % err)
      return False

    return True

  def line_color(self, line_id):
    colors = colors = {
      'london-overground': '#ff6600',
      'tfl-rail': '#330065',
      'elizabeth': '#6950a1',
      'dlr': '#009999',
      'emiratesairline': '#e21836',
      'tram': '#66cc00',
      'waterloo-city': '#66cccc',
      'victoria': '#0099cc',
      'piccadilly': '#000099',
      'northern': '#000000',
      'metropolitan': '#660066',
      'jubilee': '#868f98',
      'hammersmith-city': '#cc9999',
      'district': '#006633',
      'circle': '#ffcc00',
      'central': '#cc3333',
      'bakerloo': '#996633',
      'rb1': '#4d58a7',
      'rb2': '#008a6d',
      'rb4': '#9f614a',
      'rb6': '#fdca58',
      'river-bus': '#0099cc',
      'bus': '#62b9c3',
    }

    if line_id in colors:
      return colors[line_id]

    return "grey"

  def mainline_color(self, line_id):
    colors = {
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
      'heathrow-express': '#532e63',
      'island-line': '#1e90ff',
      'london-north-eastern-railway': '#bf0000',
      'merseyrail': '#fff200',
      'northern-rail': '#262262',
      'scotrail': '#1c4074',
      'southeastern': '#00afe8',
      'southern': '#8cc63e',
      'south-western-railway': '#24398c',
      'thameslink': '#e9438d',
      'transport-for-wales': '#ff4500',
      'west-midlands-trains': '#ff8200',
      'stansted-express': '#6b717a',
    }

    if line_id in colors:
      return colors[line_id]

    return None

  def line_text_color(self, line_id):
    colors = colors = {
      'circle': '#000000',
      'waterloo-city': '#000000',
      'bus': '#f8f8f8',
    }

    if line_id in colors:
      return colors[line_id]

    return "white"

  def mode_icon(self, mode_id):
    icons = {
      'london-overground': 'overground',
      'overground': 'overground',
      'national-rail': 'nationalrail',
      'nationalrail': 'nationalrail',
      'tfl-rail': 'tflrail',
      'tflrail': 'tflrail',
      'elizabeth-line': 'elizabethline',
      'elizabethline': 'elizabethline',
      'dlr': 'dlr',
      'emiratesairline': '',
      'tram': 'tram',
      'river-bus': 'river',
      'tube': 'tube',
      'bus': 'bus',
      'walking': 'walking',
    }

    if mode_id in icons:
      return icons[mode_id]

    return None

  def cleanup_destination(self, destination_name):
    if not destination_name or len(destination_name) < 1:
      return ""

    for station_type in ['DLR Station', 'Underground Station', 'Rail Station', '(H&C Line)', '(Circle Line)', '(Bakerloo Line)', '(Central Line)', '(District Line)', '(Jubilee Line)', '(Metropolitan Line)', '(Northern Line)', '(Piccadilly Line)', '(Victoria Line)', ', ']:
      if destination_name.endswith(station_type):
        destination_name = destination_name[:-len(station_type)].strip()

    return destination_name

  def get_arrivals(self, stop_point_id):
    print("get_arrivals: %s" % stop_point_id)
    return self.__url_get(self.STOP_POINT_ARRIVALS_URL.format(stop_point_id))

  def get_vehicle_arrivals(self, vehicle_id):
    print("get_vehicle_arrivals: %s" % vehicle_id)
    return self.__url_get(self.VEHICLE_ARRIVALS_URL.format(vehicle_id))

  def get_mode_disruptions(self, modes):
    print("get_mode_disruptions - modes: %s" % (','.join(modes)))
    return self.__url_get(self.MODE_DISRUPTIONS_URL.format(','.join(modes)))

  def get_line_disruptions(self, lines):
    print("get_line_disruptions - lines: %s" % (','.join(lines)))
    return self.__url_get(self.LINE_DISRUPTIONS_URL.format(','.join(lines)))

  def get_mode_status(self, modes):
    print("get_mode_status - modes: %s" % (','.join(modes)))
    return self.__url_get(self.MODE_STATUS_URL.format(','.join(modes)))

  def get_journey_results(self, from_stop_point_id, to_stop_point_id, start_time, preference, modes_requested):
    print("get_journey_results: %s -> %s" % (from_stop_point_id, to_stop_point_id))
    modes = [mode for mode in modes_requested if mode in self.ROUTE_MODES]

    journeys = []
    data = None
    print(self.JOURNEY_RESULTS_URL.format(from_stop_point_id, to_stop_point_id, start_time.strftime("%Y%m%d"), start_time.strftime("%H%M"), preference, ','.join(modes)))
    if len(from_stop_point_id) and len(to_stop_point_id):
      data = self.__url_get(self.JOURNEY_RESULTS_URL.format(from_stop_point_id, to_stop_point_id, start_time.strftime("%Y%m%d"), start_time.strftime("%H%M"), preference, ','.join(modes)))
    #else:
    #  with open('/tmp/route.json') as json_file:
    #    data = json.load(json_file)

    if not data:
      return None
      
    for journey in data["journeys"]:
      yourney_entry = {
        'module': 'tfl',
        'start_time': journey["startDateTime"],
        'arrival_time': journey["arrivalDateTime"],
        'duration': journey["duration"],
        'legs': [],
      }

      for leg in journey["legs"]:
        journey_leg = {
          'module': 'tfl',
          'departure_time': leg["departureTime"],
          'arrival_time': leg["arrivalTime"],
          'duration': leg["duration"],
          'mode': leg["mode"]["id"],
          'id_disrupted': leg["isDisrupted"],
          'summary': leg["instruction"]["summary"],
          'detailed_instruction': leg["instruction"]["detailed"],
          'departure_point_name': self.cleanup_destination(leg["departurePoint"]["commonName"]),
          'departure_point_id': "",
          'departure_point_platform': leg["departurePoint"]["platformName"],
          'departure_point_lat': leg["departurePoint"]["lat"],
          'departure_point_lon': leg["departurePoint"]["lon"],
          'departure_point_stop_letter': "",
          'arrival_point_name': self.cleanup_destination(leg["arrivalPoint"]["commonName"]),
          'arrival_point_id': "",
          'arrival_point_platform': leg["arrivalPoint"]["platformName"] if "platformName" in leg["arrivalPoint"] else None,
          'arrival_point_lat': leg["arrivalPoint"]["lat"],
          'arrival_point_lon': leg["arrivalPoint"]["lon"],
          'arrival_point_stop_letter': "",
          'icon_name': self.mode_icon(leg["mode"]["id"]),
          'stops': [],
          'options': [],
          'disruptions': [],
        }

        try:
          journey_leg['departure_point_id'] = leg["departurePoint"]["naptanId"]
        except:
          journey_leg['departure_point_id'] = ""
        try:
          journey_leg['departure_point_stop_letter'] = leg["departurePoint"]["stopLetter"]
        except:
          journey_leg['departure_point_stop_letter'] = ""
        try:
          journey_leg['arrival_point_id'] = leg["arrivalPoint"]["naptanId"]
        except:
          journey_leg['arrival_point_id'] = ""
        try:
          journey_leg['arrival_point_stop_letter'] = leg["arrivalPoint"]["stopLetter"]
        except:
          journey_leg['arrival_point_stop_letter'] = ""
        try:
          journey_leg['distance'] = leg["distance"]
        except:
          journey_leg['distance'] = -1

        for stop_point in leg["path"]["stopPoints"]:
          stop_entry = {'module': 'tfl'}
          try:
            stop_entry['calling_point_id'] = stop_point["id"]
          except:
            pass

          try:
            stop_entry['calling_point_name'] = stop_point["name"]
            stop_entry['title'] = self.cleanup_destination(stop_point["name"])
          except:
            pass

          journey_leg['stops'].append(multimodal_structures.calling_point_entry(stop_entry))

        if journey_leg['stops']:
          journey_leg['stops'].pop()

        for option in leg["routeOptions"]:
          journey_option = {'module': 'tfl', 'name': option["name"], 'directions': option["directions"], 'line_id': None}

          try:
            journey_option['line_id'] = option["lineIdentifier"]["id"]
          except:
            pass

          journey_option['main_color'] = self.line_color('bus') if journey_leg['mode'] == 'bus' else self.line_color(journey_option['line_id'])
          journey_option['mark_color'] = self.mainline_color('bus') if journey_leg['mode'] == 'bus' else self.mainline_color(journey_option['line_id'])
          journey_option['text_color'] = self.line_text_color('bus') if journey_leg['mode'] == 'bus' else self.line_text_color(journey_option['line_id'])

          journey_leg['options'].append(multimodal_structures.route_options_entry(journey_option))

        for disruption in leg["disruptions"]:
          leg_disruption = {'module': 'tfl'}
          try:
            leg_disruption['category'] = option["category"]
          except:
            pass
          try:
            leg_disruption['description'] = option["description"]
          except:
            pass
          try:
            leg_disruption['updated'] = option["lastUpdate"]
          except:
            pass

          journey_leg['disruptions'].append(multimodal_structures.route_disruptions_entry(leg_disruption))


        yourney_entry['legs'].append(multimodal_structures.journey_leg_entry(journey_leg))

      journeys.append(multimodal_structures.journey_entry(yourney_entry))

    return journeys
  
  def get_fares(self, from_stop_point_id, to_stop_point_id):
    print("get_fares: %s -> %s" % (from_stop_point_id, to_stop_point_id))

    fares = []
    data = None

    if len(from_stop_point_id) and len(to_stop_point_id):
      data = self.__url_get(self.FARE_FINDER_URL.format(from_stop_point_id, to_stop_point_id))
    #else:
    #  with open('/tmp/fare.json') as json_file:
    #    data = json.load(json_file)

    if not data:
      return None

    fare_details = []
    for section in data:
      for row in section['rows']:
        fare = {
          'start_time': row['startDate'],
          'end_time': row['endDate'],
          'departure_point_name': row['from'],
          'departure_point_id': row['fromStation'],
          'arrival_point_name': row['to'],
          'arrival_point_id': row['toStation'],
          'route_description': row['routeDescription'],
          'passenger_type': row['passengerType'],
          'contactelss_only': row['contactlessPAYGOnlyFare'],
          'tickets': [],
        }

        for ta in row['ticketsAvailable']:
          fare['tickets'].append({
            'passenger_type': ta['passengerType'],
            'ticket_type': ta['ticketType']['type'],
            'ticket_type_description': ta['ticketType']['description'],
            'ticket_time': ta['ticketTime']['type'],
            'ticket_time_description': ta['ticketTime']['description'],
            'cost': ta['cost'],
            'description': ta['description'],
            'mode': ta['mode'],
            'currency': '£',
          })

        fare_details.append(fare)

    return fare_details

