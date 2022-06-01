import urllib.request
import re
from xml.etree import cElementTree as ElementTree  

class TfgmXmlClient:
  API_BUS_DEPARTURES_URL = "https://tfgm.com/public-transport/{}?&c=50"

  def __init__(self):
    print("tfgm_xml_client init")

  def get_departured_panel(self, data):
    try: 
      from_index = data.index(b'<table id="departures-data" class="departures-data">')
      to_index = data.index(b'<div id="departures-later-container">')

      data = data[from_index:to_index]

      from_index = data.index(b'<tbody')
      to_index = data.index(b'</table>')
      
      return data[from_index:to_index]
    except Exception:
      return None

  def __url_get(self, url):
    print(url)
    req = urllib.request.Request(
      url,
      headers={
        'User-Agent': '007',
        'Content-Type': 'text/xml; charset=utf-8',
        'Connection': 'close',
      }
    )

    try:
      result = urllib.request.urlopen(req).read()
    except Exception as err:
      print("ERROR API request failed: %s" % err)
      return False

    try:
      return XmlToDict(ElementTree.XML(self.get_departured_panel(result)))
    except Exception as err:
      print("ERROR XML conversion: ", err)
      return False

  def get_departures(self, station_code):
    request_url = self.API_BUS_DEPARTURES_URL.format(station_code)
    return self.__url_get(request_url)

class XmlToDict(dict):
  def __init__(self, parent_element, level = 0):
    if parent_element.items():
      self.update(dict(parent_element.items()))
    for element in parent_element:
      if element.tag == 'p':
        self['destination_name'] = element.text
      if 'class' in element.attrib:
        if element.attrib['class'] == 'bus':
          if 'departures' not in self:
            self['departures'] = []
          self['departures'].append(XmlToDict(element, level + 1))

        if element.attrib['class'] == 'departure-destination':
          self['destination'] = XmlToDict(element, level + 1)

        if element.attrib['class'] == 'bus-deps-h3':
          self['line_name'] = element.text

        if element.attrib['class'] == 'departure-operator':
          self['operator'] = element.text

        if element.attrib['class'] == 'departure-expected':
          self['expected'] = XmlToDict(element, level + 1)

        if element.attrib['class'] == 'figure':
          self['figure'] = element.text

        if element.attrib['class'] == 'unit':
          self['unit'] = element.text

        if element.attrib['class'] == 'departure-indicator live-indicator':
          self['indicator'] = "Live"

        if element.attrib['class'] == 'departure-indicator':
          self['indicator'] = element.text

        if element.attrib['class'] == 'palm-stand':
          self['stand'] = element.text

        if element.attrib['class'] == 'palm-operator':
          self['operator'] = element.text


