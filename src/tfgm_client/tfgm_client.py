import json
import urllib.request

class TfgmClient:
  STOP_POINT_DEPARTURES_URL="https://api.tfgm.com/odata/Metrolinks?%24filter=TLAREF%20eq%20%27{}%27"
  ROUTE_MODES=["tram"]

  def __init__(self):
    print("tfgm_client init")

  def __url_get(self, url):
    req = urllib.request.Request(
      url,
      headers={
        'User-Agent': '007',
        'Content-Type': 'text/plain; charset=UTF-8',
        'Ocp-Apim-Subscription-Key': 'OCP-AP',
      }
    )

    try:
      result = urllib.request.urlopen(req).read()
    except Exception as err:
      print("### ERROR api request failed: %s" % err)
      return False

    try:
      return json.loads(result)

    except Exception as err:
      print("### ERROR converting result: %s" % err)
      return False

    return True

  def get_departures(self, stop_point_code):
    print("get_departures: %s" % stop_point_code)
    return self.__url_get(self.STOP_POINT_DEPARTURES_URL.format(stop_point_code))
