import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.3
import MeeGo.Connman 0.2

Item {
  id: main_handler

  property string active_page: app.active_page
  property real position_latitude: 0.0
  property real position_longitude: 0.0
  property real position_accuracy: 9999
  property var position_time: new Date()
  property string position_tech: ''

  property bool map_available: false

  property var bssids_seen: {'dummy_bssid': 0}

  readonly property int dataset_ldbws: 1
  readonly property int dataset_tfl: 2
  readonly property int dataset_dbahn: 3
  readonly property int dataset_trest_dbahn: 4
  readonly property int dataset_tfgm: 5
  readonly property int dataset_tfgm_xml: 6
  readonly property int dataset_vbb: 7
  

  PositionSource {
    id: position_source
    updateInterval: active_page == 'map' ? 1000 : 10000
    active: app.use_location
    
    onPositionChanged: {
      update_location('loc', position_source.position.coordinate.latitude, position_source.position.coordinate.longitude, position_source.position.horizontalAccuracy, position_source.position.timestamp)
    }
  }

  TechnologyModel {
    id: wifi_networks
    name: "wifi"
    filter: "AvailableServices"
    onScanRequestFinished: wifi_networks_update(wifi_networks)
  }

  Timer {
    id: wifi_networks_timer
    interval: 10000
    running: wifi_networks.powered && app.settings.location.use_wifi_location
    repeat: true
    triggeredOnStart: true

    onTriggered: wifi_networks.requestScan()
  }

  Timer {
    id: reload_timer
    interval: app.settings.predictions.reload_timer * 1000
    running: (app.active_page == 'predictions' || app.active_page == 'vehicle_predictions') && app.settings.predictions.reload_timer > 20
    repeat: true
    triggeredOnStart: false

    onTriggered: {
      if (isNaN(app.settings.predictions.reload_timer) || app.settings.predictions.reload_timer < 20) {
        reload_timer.stop()
        return
      }
      app.signal_reload_data()
    }
  }

  Item {
    Loader {
      id: map_checker
      source: "MapChecker.qml"

      onLoaded: {
        main_handler.map_available = true
      }
    }
  }

  Component.onCompleted: {
    Qt.application.name = 'multimodal'                                                       
    Qt.application.organization = 'app.qml'                                                
    Qt.application.version = app.version    
    app.signal_settings_loaded.connect(settings_loaded)
    app.signal_a_get_predictions.connect(reset_reload_timer)
    app.signal_a_get_predictions_fastest.connect(reset_reload_timer)
    app.signal_a_get_vehicle_predictions.connect(reset_reload_timer)
  }

  Component.onDestruction: {
    app.signal_settings_loaded.disconnect(settings_loaded)
    app.signal_a_get_predictions.disconnect(reset_reload_timer)
    app.signal_a_get_predictions_fastest.disconnect(reset_reload_timer)
    app.signal_a_get_vehicle_predictions.disconnect(reset_reload_timer)
  }

  onActive_pageChanged: {
    console.log('active page:', active_page)
  }

  function cleanup_destination(destination_name) {
    if (!destination_name) return ''
    var station_types = ['DLR Station', 'Underground Station', 'Rail Station', '(S-Bahn)', '(S)', '(Elizabeth line)', ', Berlin'];

    for (var type_index in station_types) {
      var station_type = station_types[type_index];
      if (destination_name.lastIndexOf(station_type) > 1) return destination_name.substring(0, destination_name.lastIndexOf(station_type)).trim();
    }

    return destination_name;
  }

  function short_time(timestamp) {
    return new Date(timestamp * 1000).toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
  }

  function calculate_distance(lat1, lon1, lat2, lon2) {
    const R = 6371e3;
    const phi1 = lat1 * Math.PI/180;
    const phi2 = lat2 * Math.PI/180;
    const delta_phi = (lat2-lat1) * Math.PI/180;
    const delta_lambda = (lon2-lon1) * Math.PI/180;
    const a = Math.sin(delta_phi/2) * Math.sin(delta_phi/2) + (Math.cos(phi1) * Math.cos(phi2) * Math.sin(delta_lambda/2) * Math.sin(delta_lambda/2));
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    const d = R * c;

    return d;
  }

  function bounding_box(lat, lon, delta_y, delta_x) {
    const lat_f = 8.99321605918718e-6;
    const lon_f = 1.444892306208929e-5;
    if (delta_x == undefined) delta_x = delta_y;

    return [lat + lat_f * delta_y, lon - lon_f * delta_x, lat - lat_f * delta_y, lon + lon_f * delta_x]
  }

  function letter_to_direction(letter) {
    if (!letter.match(/\W/)) return letter;

    switch(letter.replace(/\W/g, '')) {
      case "E":
        return '→' //"➡";
        break;
      case "W":
        return '←' //"⬅";
        break;
      case "S":
        return '↓' //"⬇";
        break;
      case "N":
        return '↑' //"⬆";
        break;
      case "SE":
        return '↑' //"⬊";
        break;
      case "NE":
        return '↗' //"⬈";
        break;
      case "NW":
        return '↖' //"⬉";
        break;
      case "SW":
        return '↙' //"⬋";
        break;
      case "null":
        return "";
        break;
      default:
        return letter
    } 
  }

  function minutes_to_hours(min) { 
    const hours = Math.floor(min / 60);  
    const minutes = min % 60;
    return hours + ":" + (minutes < 10 ? '0' + minutes : minutes)
  }

  function tz_offset_string() {
    return String(new Date()).substr(25)
  }

  function parse_date(date_string) {
    if (date_string.indexOf('Z') < 0 && date_string.indexOf('+') < 0) return new Date(Date.parse(date_string+ ' ' + tz_offset_string()))
    return new Date(Date.parse(date_string))
  }
  
  function settings_loaded() {

  }

  function wifi_networks_update(networks_list) {
    console.log("wifi_networks_update - networks:", networks_list.count)
    var bssids = []
    for (var i=0; i<networks_list.count; i++) {
      const network = networks_list.get(i)
      console.log(i, "- bssid:", network.bssid, "name:", network.name, 'f:', network.frequency, 'sig:', network.strength, "%, first seen:", bssids_seen[network.bssid])
      if (network.strength > 5) bssids.push(network.bssid)
    }

    Object.keys(bssids_seen).forEach(function (bssid) { 
      if (bssids.indexOf(bssid) === -1) {
        delete bssids_seen[bssid];
      }
    })

    const timestamp = Math.round(Date.now() / 1000)
    if (bssids.length < 1) return;

    for (var i=0; i<bssids.length; i++) {
      if (!bssids_seen[bssids[i]]) bssids_seen[bssids[i]] = timestamp;
    }

    bssids.sort(function(a, b){
      return  bssids_seen[b] - bssids_seen[a]
    })

    const position = python.get_location_by_bssids(bssids);
    if (position) {
      console.log("wifi location:", position.id, position.name, position.lat, position.lon)
      update_location('wifi', position.lat, position.lon, 100, new Date())
    }
  }

  function update_location(tech, lat, lon, acc, timestamp) {
    if (tech != position_tech && acc > position_accuracy && (timestamp.getTime() - position_time.getTime()) / 1000 < 15) {
      console.log('update_location - ignoring update - tech:', tech, 'location:', lat, lon, 'acc:', acc, 'ts:', timestamp)
      return;
    }

    console.log('update_location - tech:', tech, 'location:', lat, lon, 'acc:', acc, 'ts:', timestamp)

    position_tech = tech
    position_latitude = lat
    position_longitude = lon
    position_accuracy = acc
    position_time = timestamp
    
    app.signal_position_update(lat, lon, acc, timestamp);
  }

  function reset_reload_timer() {
    reload_timer.restart();
  }

  function add_history(page_data) {
    app.page_history.push(page_data);
  }

  function get_history(max_entries) {
    var history = new Array(max_entries)
    var history_titles = {}
    var history_index = 0;

    for (var index=app.page_history.length-1; index>=0; index--) {
      if (history_index > 4) break;
      if (history_titles[app.page_history[index].title]) continue;

      history[history_index] = index
      history_titles[app.page_history[index].title] = index
      history_index++
    }

    for (var index=history_index; index<history.length; index++) {
      history[index] = -1;
    }

    return history;
  }

  function has_arrivals(ds) {
    return (ds === dataset_ldbws || ds === dataset_tfl || ds === dataset_dbahn || ds === dataset_trest_dbahn || ds == dataset_vbb)
  }

  function has_departures(ds) {
    return (ds === dataset_ldbws || ds === dataset_tfgm || ds == dataset_tfgm_xml || ds === dataset_dbahn || ds === dataset_trest_dbahn || ds === dataset_vbb)
  }

  function has_fastest_trains(ds) {
    return (ds === dataset_ldbws)
  }
}
