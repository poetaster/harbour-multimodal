import urllib.request
import re
from xml.etree import cElementTree as ElementTree

def list_tag(tag_name):
  list_tags = {
    #'timetable': 'timetable',
    's': 's',
    'm': 'm',
    'ref': 'ref_trips',
  }

  try:
    return list_tags[tag_name]
  except:
    return False

class DbahnClient:
  API_BOARD_PLAN_URL_OLD = "https://api.deutschebahn.com/timetables/v1/plan/{}/{}/{}"
  API_BOARD_CHANGES_URL_OLD = "https://api.deutschebahn.com/timetables/v1/fchg/{}"

  API_BOARD_PLAN_URL = "https://apis.deutschebahn.com/db-api-marketplace/apis/timetables/v1/plan/{}/{}/{}"
  API_BOARD_CHANGES_URL = "https://apis.deutschebahn.com/db-api-marketplace/apis/timetables/v1/fchg/{}"

  def __init__(self):
    print("db_client init")

  def __url_get(self, url):
    print(url)
    req = urllib.request.Request(
      url,
      headers={
        'User-Agent': '007',
        'Content-Type': 'text/xml; charset=utf-8',
        'DB-Client-Id': 'CLIENT-ID',
        'DB-Api-Key': 'API-ID',
        'Connection': 'close',
      }
    )

    try:
      result = urllib.request.urlopen(req).read()
      #with open(url, 'r') as file:
      #  result = file.read()
      #print(result)
    except Exception as err:
      print("ERROR API request failed: %s" % err)
      return False

    values = []
    try:
      return XmlToDict(ElementTree.XML(result))
    except Exception as e:
      print("ERROR XML conversion: ", e)
      return False

  def get_departures_board_static(self, station_code, date_s, hour_s):
    request_url = self.API_BOARD_PLAN_URL.format(station_code, date_s, hour_s)
    #return self.__url_get('timetable.xml')
    return self.__url_get(request_url)

  def get_departures_board_changes(self, station_code):
    request_url = self.API_BOARD_CHANGES_URL.format(station_code)
    #return self.__url_get('timetable_chg.xml')
    return self.__url_get(request_url)

class XmlToDict(dict):
  def __init__(self, parent_element, level = 0):
    if parent_element.items():
      self.update(dict(parent_element.items()))
    for element in parent_element:
      if list_tag(element.tag):
        if list_tag(element.tag) not in self:
          self[list_tag(element.tag)] = []
        self[list_tag(element.tag)].append(XmlToDict(element, level + 1))
      else:
        self[element.tag] = XmlToDict(element, level + 1)

