import sqlite3

class DbClient:
  ROUTE_FILE = '/usr/share/harbour-multimodal/route.db'
  def __init__(self):
    print("init")
    self.numbering_area = 1

    self.stop_points_query = """
SELECT 
a.id,
a.name,
a.stop_letter,
a.lat,
a.lon,
a.fare_zone,
a.towards,
a.heading,
a.stop_code,
a.stop_type,
a.dataset_id,
a.numbering_area,
GROUP_CONCAT(DISTINCT b.line_name) AS lines,
GROUP_CONCAT(DISTINCT b.line_id) AS line_ids,
GROUP_CONCAT(DISTINCT b.mode_id) AS modes
FROM stop_points a
LEFT OUTER JOIN stop_point_lines b ON a.id = b.stop_point_id
WHERE (a.stop_type = 10 OR b.mode_id IN ("bus", "tram", "tube", "tflrail", "elizabeth-line", "overground", "dlr", "national-rail", "river-bus"))
AND {}
AND a.numbering_area = :numbering_area
GROUP BY a.id ORDER BY a.name LIMIT :limit
    """

  def __dict_factory(self, cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
      d[col[0]] = row[idx]
    return d

  def __open_route_db(self):
    con = sqlite3.connect(self.ROUTE_FILE)
    con.row_factory = self.__dict_factory
    cur = con.cursor()
    
    return con, cur  

  def set_numbering_area(self, numbering_area):
    self.numbering_area = numbering_area

  def search_stops(self, search_str, max_results = 65534):
    con, cur = self.__open_route_db()

    stops = []
    sql_query = self.stop_points_query.format('(a.name LIKE :search_str OR a.stop_code LIKE :search_str)')
    result = cur.execute(sql_query, {'search_str': search_str, 'limit': max_results, 'numbering_area': self.numbering_area}).fetchall()
    con.close()

    return result

  def stop_in_geobox(self, lat1, lon1, lat2, lon2):
    con, cur = self.__open_route_db()

    params = {'lat_min': lat1, 'lat_max': lat2, 'lon_min': lon1, 'lon_max': lon2, 'limit': 1, 'numbering_area': self.numbering_area}
    if (lat2 < lat1):
      params['lat_min'] = lat2
      params['lat_max'] = lat1
    
    if (lon2 < lon1):
      params['lon_min'] = lon2
      params['lon_max'] = lon2

    sql_query = self.stop_points_query.format('(a.lat BETWEEN :lat_min AND :lat_max AND a.lon BETWEEN :lon_min AND :lon_max)')
    result = cur.execute(sql_query, params).fetchone()
    con.close()

    return result

  def stops_in_geobox(self, lat1, lon1, lat2, lon2, max_results = 65534):
    con, cur = self.__open_route_db()

    params = {'lat_min': lat1, 'lat_max': lat2, 'lon_min': lon1, 'lon_max': lon2, 'limit': max_results, 'numbering_area': self.numbering_area}
    if (lat2 < lat1):
      params['lat_min'] = lat2
      params['lat_max'] = lat1
    
    if (lon2 < lon1):
      params['lon_min'] = lon2
      params['lon_max'] = lon2

    stops = []
    sql_query = self.stop_points_query.format('(a.lat BETWEEN :lat_min AND :lat_max AND a.lon BETWEEN :lon_min AND :lon_max)')
    result = cur.execute(sql_query, params).fetchall()
    con.close()

    return result

  def stop_in_geobox_modes(self, lat1, lon1, lat2, lon2, modes):
    con, cur = self.__open_route_db()

    params = {'lat_min': lat1, 'lat_max': lat2, 'lon_min': lon1, 'lon_max': lon2, 'limit': 1, 'numbering_area': self.numbering_area}
    if (lat2 < lat1):
      params['lat_min'] = lat2
      params['lat_max'] = lat1
    
    if (lon2 < lon1):
      params['lon_min'] = lon2
      params['lon_max'] = lon2

    stops = []
    sql_query = self.stop_points_query.format('(a.lat BETWEEN :lat_min AND :lat_max AND a.lon BETWEEN :lon_min AND :lon_max) AND b.mode_id IN ("%s")' % '","'.join(modes))
    result = cur.execute(sql_query, params).fetchone()
    con.close()

    return result

  def stops_in_geobox_modes(self, lat1, lon1, lat2, lon2, modes, max_results = 65534):
    con, cur = self.__open_route_db()

    params = {'lat_min': lat1, 'lat_max': lat2, 'lon_min': lon1, 'lon_max': lon2, 'limit': max_results, 'numbering_area': self.numbering_area}
    if (lat2 < lat1):
      params['lat_min'] = lat2
      params['lat_max'] = lat1
    
    if (lon2 < lon1):
      params['lon_min'] = lon2
      params['lon_max'] = lon2

    stops = []    
    sql_query = self.stop_points_query.format('(a.lat BETWEEN :lat_min AND :lat_max AND a.lon BETWEEN :lon_min AND :lon_max) AND b.mode_id IN ("%s")' % '","'.join(modes))
    result = cur.execute(sql_query, params).fetchall()
    con.close()

    return result

  def stop_in_geobox_types(self, lat1, lon1, lat2, lon2, stop_types):
    con, cur = self.__open_route_db()

    params = {'lat_min': lat1, 'lat_max': lat2, 'lon_min': lon1, 'lon_max': lon2, 'limit': 1, 'numbering_area': self.numbering_area}
    if (lat2 < lat1):
      params['lat_min'] = lat2
      params['lat_max'] = lat1
    
    if (lon2 < lon1):
      params['lon_min'] = lon2
      params['lon_max'] = lon2

    stops = []
    sql_query = self.stop_points_query.format('(a.lat BETWEEN :lat_min AND :lat_max AND a.lon BETWEEN :lon_min AND :lon_max) AND a.stop_type IN ("%s")' % '","'.join(str(stop_type) for stop_type in stop_types))
    result = cur.execute(sql_query, params).fetchone()
    con.close()

    return result

  def stops_in_geobox_types(self, lat1, lon1, lat2, lon2, stop_types, max_results = 65534):
    con, cur = self.__open_route_db()

    params = {'lat_min': lat1, 'lat_max': lat2, 'lon_min': lon1, 'lon_max': lon2, 'limit': max_results, 'numbering_area': self.numbering_area}
    if (lat2 < lat1):
      params['lat_min'] = lat2
      params['lat_max'] = lat1
    
    if (lon2 < lon1):
      params['lon_min'] = lon2
      params['lon_max'] = lon2

    stops = []    
    sql_query = self.stop_points_query.format('(a.lat BETWEEN :lat_min AND :lat_max AND a.lon BETWEEN :lon_min AND :lon_max) AND a.stop_type IN ("%s")' % '","'.join(str(stop_type) for stop_type in stop_types))
    result = cur.execute(sql_query, params).fetchall()
    con.close()

    return result


  def stop_by_id(self, stop_point_id):
    con, cur = self.__open_route_db()
    sql_query = self.stop_points_query.format('id = :id')
    result = cur.execute(sql_query, {'id': stop_point_id, 'limit': 1, 'numbering_area': self.numbering_area}).fetchone()
    con.close()

    return result

  def stops_by_ids(self, parameters):
    con, cur = self.__open_route_db()
    stops = []
    sql_query = """
    SELECT 
    a.id,
    a.name,
    a.stop_letter,
    a.lat,
    a.lon,
    a.fare_zone,
    a.towards,
    a.heading,
    a.stop_code,
    a.stop_type,
    a.dataset_id,
    a.numbering_area,
    GROUP_CONCAT(DISTINCT b.line_name) AS lines,
    GROUP_CONCAT(DISTINCT b.line_id) AS line_ids,
    GROUP_CONCAT(DISTINCT b.mode_id) AS modes 
    FROM stop_points a 
    LEFT OUTER JOIN stop_point_lines b ON a.id = b.stop_point_id
    WHERE a.id IN (%s)
    AND a.numbering_area = ?
    GROUP BY a.id ORDER BY a.name""" % ','.join('?'*len(parameters))
    parameters.append(self.numbering_area)
    result = cur.execute(sql_query, parameters).fetchall()
    con.close()

    return result


  def stop_by_code_name_letter(self, stop_point_id, stop_name, stop_letter):
    con, cur = self.__open_route_db()    
    sql_query = self.stop_points_query.format('(a.id = :stop_point_id) OR (a.name = :name AND a.stop_letter = :stop_letter)')
    result = cur.execute(sql_query, {'stop_point_id': stop_point_id, 'name': stop_name, 'stop_letter': stop_letter, 'limit': 1, 'numbering_area': self.numbering_area}).fetchone()
    con.close()

    return result

  def location_by_bssids(self, bssids):
    order_bssids = []
    for index, bssid in enumerate(bssids):
      order_bssids.append('WHEN "' + bssid + '" THEN ' + str(index + 1))

    con, cur = self.__open_route_db()
    sql_query = """
    SELECT
    a.bssid,
    b.id,
    b.name,
    b.lat,
    b.lon
    FROM wifi_networks a
    JOIN stop_points b ON a.stop_point_id = b.id
    WHERE a.bssid IN (%s)
    ORDER BY 
    CASE a.bssid
    %s
    END
    LIMIT 1""" % (','.join('?'*len(bssids)), '\n'.join(order_bssids))
 
    result = cur.execute(sql_query, bssids).fetchone()
    con.close()

    return result

  def get_lines(self, modes):
    con, cur = self.__open_route_db()

    sql_query = """
    SELECT 
    id,
    name,
    mode_name
    FROM lines
    WHERE mode_name IN (%s)""" % ','.join('?'*len(modes))

    result = cur.execute(sql_query, modes).fetchall()
    con.close()

    return result

  def get_route_sections(self, line_id, mode_id):
    con, cur = self.__open_route_db()

    sql_query = """
    SELECT 
    line_id,
    mode_id,
    direction,
    originator_id,
    destination_id,
    name,
    service_type
    FROM route_sections
    WHERE line_id = :line_id
    AND mode_id = :mode_id"""

    result = cur.execute(sql_query, {'line_id': line_id, 'mode_id': mode_id}).fetchall()
    con.close()

    return result

  def get_route_sequences(self, line_id, mode_id):
    con, cur = self.__open_route_db()

    sql_query = """
    SELECT 
    line_id,
    mode_id,
    direction,
    stop_point_id,
    branch_id,
    branch_name,
    service_type,
    sequence
    FROM route_sequences
    WHERE line_id = :line_id
    AND mode_id = :mode_id
    GROUP BY service_type,branch_id,direction"""

    result = cur.execute(sql_query, {'line_id': line_id, 'mode_id': mode_id}).fetchall()
    con.close()

    return result

  def get_route_sequence_details(self, line_id, mode_id, branch_id, direction):
    con, cur = self.__open_route_db()

    sql_query = """
    SELECT 
    a.line_id,
    a.mode_id,
    a.direction,
    a.stop_point_id,
    a.branch_id,
    a.branch_name,
    a.service_type,
    a.sequence,
    b.name AS stop_point_name
    FROM route_sequences a
    JOIN stop_points b ON a.stop_point_id = b.id
    WHERE a.line_id = :line_id
    AND a.mode_id = :mode_id
    AND branch_id = :branch_id
    AND direction = :direction
    ORDER BY a.service_type,a.branch_id,a.direction,a.sequence"""

    result = cur.execute(sql_query, {'line_id': line_id, 'mode_id': mode_id, 'branch_id': branch_id, 'direction': direction}).fetchall()
    con.close()

    return result

  def get_route_sequences_by_stops(self, from_stop_id, to_stop_id, modes):
    con, cur = self.__open_route_db()

    sql_query = """
SELECT 
a.line_id, 
a.mode_id, 
a.direction, 
a.branch_id, 
a.service_type, 
a.sequence, 
b.sequence AS sequence_b,
a.branch_name
FROM route_sequences a 
JOIN route_sequences b 
ON a.line_id = b.line_id 
AND a.mode_id = b.mode_id 
AND a.branch_id = b.branch_id 
AND a.direction = b.direction 
AND a.service_type = b.service_type 
AND a.sequence < b.sequence 
WHERE a.stop_point_id = :from_stop_id
AND b.stop_point_id = :to_stop_id
AND a.mode_id IN ("%s")
GROUP BY a.line_id, a.mode_id, a.direction, a.branch_id, a.service_type""" % '","'.join(modes)

    result = cur.execute(sql_query, {'from_stop_id': from_stop_id, 'to_stop_id': to_stop_id}).fetchall()
    con.close()

    return result

#mode names: dlr,overground,cable-car,national-rail,river-bus,river-tour,tflrail,tram,tube,bus
# stop_type: 2 = Bus Stop, 4 = Tram stop, 6 = Light Rail station, 8 = metro station, 10 = rail station
# dataset: 1 = ldbws, 2 = tfl, 3 = dbahn, 4 = vbb
# numbering area: 1 = UK, 2 = DE
