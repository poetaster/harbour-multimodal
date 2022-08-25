import urllib.request
import re
from xml.etree import cElementTree as ElementTree

def strip_namespace(tag_name):
  _, _, tag_name = tag_name.rpartition('}')
  return tag_name
  return re.sub('^\{.*\}', '', tag_name, count=1)

def is_list(tag_name):
  tag_name = strip_namespace(tag_name)

  list_tags = {
    'trainServices': True,
    'busServices': True,
    'origin': True,
    'destination': True,
    'formation': True,
    'previousCallingPoints': True,
    'subsequentCallingPoints': True,
    'callingPointList': True,
    'departures': True,
    'nrccMessages': True,
  }

  try:
    return list_tags[tag_name]
  except:
    return False

class LdbwsClient:
  API_URL = "https://lite.realtime.nationalrail.co.uk/OpenLDBWS/ldb11.asmx"
  ACTION_GET_DEPARTURE_BOARD = "http://thalesgroup.com/RTTI/2012-01-13/ldb/GetDepartureBoard"
  ACTION_GET_ARRIVAL_BOARD = "http://thalesgroup.com/RTTI/2012-01-13/ldb/GetArrivalBoard"
  ACTION_GET_NEXT_DEPARTURES = "http://thalesgroup.com/RTTI/2015-05-14/ldb/GetNextDepartures"
  ACTION_GET_FASTEST_DEPARTURES = "http://thalesgroup.com/RTTI/2015-05-14/ldb/GetFastestDepartures"
  ACTION_GET_SERVICE_DETAILS = "http://thalesgroup.com/RTTI/2012-01-13/ldb/GetServiceDetails"

  R_ENVELOPE="""<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope
	xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:tns="http://thalesgroup.com/RTTI/2013-11-28/Token/types"
	xmlns:ns0="http://thalesgroup.com/RTTI/2017-10-01/ldb/"
	xmlns:ns1="http://schemas.xmlsoap.org/soap/envelope/">
	<SOAP-ENV:Header>
		<tns:AccessToken>
                       <tns:TokenValue>API-ID</tns:TokenValue>
		</tns:AccessToken>
	</SOAP-ENV:Header>
	<ns1:Body>
		{}
	</ns1:Body>
</SOAP-ENV:Envelope>"""

  R_FILTER_TO="""<ns0:filterCrs>{}</ns0:filterCrs>
<ns0:filterType>to</ns0:filterType>"""

  R_GET_DEPARTURE_BOARD="""<ns0:GetDepartureBoardRequest>
  <ns0:numRows>{}</ns0:numRows>
  <ns0:timeWindow>{}</ns0:timeWindow>
  <ns0:crs>{}</ns0:crs>
  {}
</ns0:GetDepartureBoardRequest>"""

  R_GET_ARRIVAL_BOARD="""<ns0:GetArrivalBoardRequest>
  <ns0:numRows>{}</ns0:numRows>
  <ns0:timeWindow>{}</ns0:timeWindow>
  <ns0:crs>{}</ns0:crs>
  {}
</ns0:GetArrivalBoardRequest>"""

  R_GET_NEXT_DEPARTURES="""<ns0:GetNextDeparturesRequest>
  <ns0:timeWindow>{}</ns0:timeWindow>
  <ns0:crs>{}</ns0:crs>
  <ns0:filterList><ns0:crs>{}</ns0:crs></ns0:filterList>
</ns0:GetNextDeparturesRequest>"""

  R_GET_FASTEST_DEPARTURES="""<ns0:GetFastestDeparturesRequest>
  <ns0:timeWindow>{}</ns0:timeWindow>
  <ns0:crs>{}</ns0:crs>
  <ns0:filterList><ns0:crs>{}</ns0:crs></ns0:filterList>
</ns0:GetFastestDeparturesRequest>"""

  R_GET_SERVICE_DETAILS = """<ns0:GetServiceDetailsRequest>
  <ns0:serviceID>{}</ns0:serviceID>
</ns0:GetServiceDetailsRequest>"""

  def __init__(self):
    print("ldbws_client init")

  def __url_get(self, action, xml_data):
    req = urllib.request.Request(
      self.API_URL,
      data=str.encode(xml_data),
      headers={
        'User-Agent': '007',
        'Content-Type': 'text/xml; charset=utf-8',
        'Soapaction': action,
        'Connection': 'close',
      }
    )

    try:
      result = urllib.request.urlopen(req).read()
    except Exception as err:
      print("ERROR SOAP request failed: %s" % err)
      return False

    try:
      return XmlToDict(ElementTree.XML(result))['Body']
    except Exception as err:
      print("ERROR SOAP conversion failed: %s" % err)
      return False

    return False

  def get_departures_board(self, station_code, rows = 10, time_window = 60, to_station_code=None):
    xml_filter = ''
    if to_station_code:
      xml_filter = self.R_FILTER_TO.format(to_station_code)
    xml_data = self.R_ENVELOPE.format(self.R_GET_DEPARTURE_BOARD.format(rows, time_window, station_code, xml_filter))
    try:
      return self.__url_get(self.ACTION_GET_DEPARTURE_BOARD, xml_data)['GetDepartureBoardResponse']['GetStationBoardResult']
    except Exception as err:
      print("ERROR requesting departures board failed: %s" % err)

    return False

  def get_arrivals_board(self, station_code, rows = 10, time_window = 60, to_station_code=None):
    xml_filter = ''
    if to_station_code:
      xml_filter = self.R_FILTER_TO.format(to_station_code)
    xml_data = self.R_ENVELOPE.format(self.R_GET_ARRIVAL_BOARD.format(rows, time_window, station_code, xml_filter))
    try:
      return self.__url_get(self.ACTION_GET_ARRIVAL_BOARD, xml_data)['GetArrivalBoardResponse']['GetStationBoardResult']
    except Exception as err:
      print("ERROR requesting arrivals board failed: %s" % err)

    return False

  def get_next_departures(self, station_code, destination_code, time_window = 120):
    xml_data = self.R_ENVELOPE.format(self.R_GET_NEXT_DEPARTURES.format(time_window, station_code, destination_code))
    try:
      return self.__url_get(self.ACTION_GET_NEXT_DEPARTURES, xml_data)['GetNextDeparturesResponse']['DeparturesBoard']
    except Exception as err:
      print("ERROR requesting departures board failed: %s" % err)

    return False

  def get_fastest_departures(self, station_code, destination_code, time_window = 120):
    xml_data = self.R_ENVELOPE.format(self.R_GET_FASTEST_DEPARTURES.format(time_window, station_code, destination_code))
    try:
      return self.__url_get(self.ACTION_GET_FASTEST_DEPARTURES, xml_data)['GetFastestDeparturesResponse']['DeparturesBoard']
    except Exception as err:
      print("ERROR requesting departures board failed: %s" % err)

    return False

  def get_service_details(self, service_id):
    xml_data = self.R_ENVELOPE.format(self.R_GET_SERVICE_DETAILS.format(service_id))
    try:
      return self.__url_get(self.ACTION_GET_SERVICE_DETAILS, xml_data)['GetServiceDetailsResponse']['GetServiceDetailsResult']
    except Exception as err:
      print("ERROR requesting arrivals board failed: %s" % err)
    
class XmlToDict(dict):
  def __init__(self, parent_element):
    if parent_element.items():
      self.update(dict(parent_element.items()))
    for element in parent_element:
      if element:
        if is_list(element.tag):
          results = XmlToList(element)
        else:
          results = XmlToDict(element)
        if element.items():
          results.update(dict(element.items()))
        self.update({strip_namespace(element.tag): results})
      elif element.items():
        self.update({strip_namespace(element.tag): dict(element.items())})
      else:
        self.update({strip_namespace(element.tag): element.text})

class XmlToList(list):
  def __init__(self, entries):
    for element in entries:
      if element:
        if is_list(element.tag):
          self.append(XmlToList(element))
        else:
          self.append(XmlToDict(element))
      elif element.text:
        text = element.text.strip()
        if text:
          self.append(text)
