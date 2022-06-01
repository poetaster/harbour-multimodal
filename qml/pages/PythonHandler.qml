import QtQuick 2.0
import io.thp.pyotherside 1.5

Python {
  id: python

  Component.onCompleted: {
    setHandler('a_search_stop', a_search_stop);
    setHandler('a_geo_stop', a_geo_stop);
    setHandler('a_geo_stops', a_geo_stops);
    setHandler('a_stops_by_ids', a_stops_by_ids);
    setHandler('a_get_predictions', a_get_predictions);
    setHandler('a_get_predictions_fastest', a_get_predictions_fastest);
    setHandler('a_get_vehicle_predictions', a_get_vehicle_predictions);
    setHandler('a_get_journey', a_get_journey);
    setHandler('a_get_trip', a_get_trip);
    setHandler('a_get_fares', a_get_fares);
    setHandler('a_get_disruptions', a_get_disruptions);
    setHandler('a_get_mode_status', a_get_mode_status);
    setHandler('a_get_station_messages', a_get_station_messages);
    setHandler('error', error_handler);

    addImportPath(Qt.resolvedUrl('../../src'));
    importModule('tfl', function () {
      call('tfl.tfl_object.set_app', [app]);
      call('tfl.tfl_object.set_python_handler', [python]);
    });
    importModule('database', function () {
      call('database.database_object.set_app', [app]);
      call('database.database_object.set_python_handler', [python]);
    });
    importModule('ldbws', function () {});
    importModule('dbahn', function () {});
    importModule('tfgm', function () {});
    importModule('tfgm_xml', function () {});
    importModule('trest', function () {});

    importModule('configuration', function () {
      const settings = call_sync('configuration.multimodal_configuration.load', [app.version]);
      load_settings(settings);
    });
  }

  Component.onDestruction: {
    save_settings();
  }

  onError: {
    console.log('ERROR - unhandled error received:', traceback);
  }

  onReceived: {
    console.log('ERROR - unhandled data received:', data);  
  }

  function error_handler(module_id, method_id, description) {
    console.log('Module ERROR - source:', module_id, method_id, 'error:', description);
    app.signal_error(module_id, method_id, description);
  }

  function stop_point_sort_default(a, b) {
    const stop_sort_pref = {
      '2': app.settings.sorting.order_bus_stops,
      '8': app.settings.sorting.order_metro_stations,
      '10': app.settings.sorting.order_train_stations,
    }

    const a_type_v = stop_sort_pref[a.stop_type] || app.settings.sorting.order_metro_stations
    const b_type_v = stop_sort_pref[b.stop_type] || app.settings.sorting.order_metro_stations

    if (a_type_v != b_type_v) return a_type_v - b_type_v;
    if (app.use_location) {
      return main_handler.calculate_distance(main_handler.position_latitude, main_handler.position_longitude, a.lat, a.lon) - main_handler.calculate_distance(main_handler.position_latitude, main_handler.position_longitude, b.lat, b.lon)
    }
    if(a.name < b.name) { return -1; }
    if(a.name > b.name) { return 1; }
    return 0;
  }

  function get_stop_by_id(stop_point_id) {
    return call_sync('database.database_object.get_stop_by_id', [stop_point_id]);
  }

  function get_stop_code(stop_point_id) {
    const stop_code = call_sync('database.database_object.get_stop_code', [stop_point_id]);
    console.log('get_stop_code - id:', stop_point_id, 'ldbws:', stop_code);
    return stop_code;
  }

  function get_stop_by_code_name_letter(stop_point_id, stop_name, stop_letter) {
    const stop_point = call_sync('database.database_object.get_stop_by_code_name_letter', [stop_point_id, stop_name, stop_letter]);
    return stop_point;
  }

  function get_location_by_bssids(bssids) {
    return call_sync('database.database_object.get_location_by_bssids', [bssids]);
  }

  function r_stops_by_ids(stop_point_ids) {
    var stops = call('database.database_object.r_stops_by_ids', [stop_point_ids]);
  }

  function a_stops_by_ids(stops) {
    app.signal_a_stops_by_ids(stops);
  }

  function r_search_stop(search_str) {
    console.log("r_search_stop:", search_str);
    var stops = call('database.database_object.r_search_stop', [search_str]);
  }

  function r_search_stop_online(search_str) {
    console.log("r_search_stop_online:", search_str);
    if (app.settings.data_source.numbering_area == 2) call('trest.trest_object.r_search_stop', [search_str])
    else call('database.database_object.r_search_stop', [search_str]); //fallback to database
  }

  function a_search_stop(stops) {
    stops.sort(stop_point_sort_default);
    stops.forEach(function(stop) {
      if (stop.stop_code) {
        if (!stop.modes || stop.modes.length < 3) stop.modes = "national-rail"
      } else stop.stop_code = '';
    });

    app.signal_a_search_stop(stops);
  }

  function r_geo_stop(lat1, lon1, lat2, lon2) {
    console.log("r_geo_stop:", lat1, lon1, lat2, lon2);
    var stops = call('database.database_object.r_geo_stop', [lat1, lon1, lat2, lon2]);
  }

  function r_geo_stops(lat1, lon1, lat2, lon2) {
    console.log("r_geo_stops:", lat1, lon1, lat2, lon2);
    var stops = call('database.database_object.r_geo_stops', [lat1, lon1, lat2, lon2]);
  }

  function r_geo_stop_modes(lat1, lon1, lat2, lon2, modes) {
    console.log("r_geo_stop_modes:", lat1, lon1, lat2, lon2, modes);
    var stops = call('database.database_object.r_geo_stop_modes', [lat1, lon1, lat2, lon2, modes]);
  }

  function r_geo_stops_modes(lat1, lon1, lat2, lon2, modes) {
    console.log("r_geo_stops_modes:", lat1, lon1, lat2, lon2, modes);
    var stops = call('database.database_object.r_geo_stops_modes', [lat1, lon1, lat2, lon2, modes]);
  }

  function r_geo_stop_types(lat1, lon1, lat2, lon2, stop_types) {
    console.log("r_geo_stop_types:", lat1, lon1, lat2, lon2, stop_types);
    var stops = call('database.database_object.r_geo_stop_types', [lat1, lon1, lat2, lon2, stop_types]);
  }

  function r_geo_stops_types(lat1, lon1, lat2, lon2, stop_types) {
    console.log("r_geo_stops_types:", lat1, lon1, lat2, lon2, stop_types);
    var stops = call('database.database_object.r_geo_stops_types', [lat1, lon1, lat2, lon2, stop_types]);
  }

  function a_geo_stop(stop) {
    app.signal_a_geo_stop(stop);
  }

  function a_geo_stops(stops) {
    stops.sort(stop_point_sort_default);

    stops.forEach(function(stop) {
      if (!stop.stop_code) stop.stop_code = '';
    });

    app.signal_a_geo_stops(stops);
  }

  function r_get_departures(stop_point, to_stop_point) {
    if (!stop_point) {
      app.signal_error('python_handler', 'r_get_departures', 'No stop point');
      return;
    }

    if (!stop_point.dataset_id && !stop_point.numbering_area) {
      if (app.settings.data_source.numbering_area == 2) {
        stop_point.numbering_area = 2
        stop_point.dataset_id = 4
      }
    }
    console.log("r_get_departures:", stop_point.id, 'dataset:', stop_point.dataset_id);
    
    switch(stop_point.dataset_id) {
      case 1:
        if (to_stop_point) call('ldbws.ldbws_object.r_get_departures', [stop_point.stop_code, to_stop_point.stop_code])
        else call('ldbws.ldbws_object.r_get_departures', [stop_point.stop_code])
        break;
      case 2:
        call('tfl.tfl_object.r_get_predictions', [stop_point.id]);
        break;
      case 3:
        call('dbahn.dbahn_object.r_get_departures', [stop_point.id])
        break;
      case 4:
        call('trest.trest_object.r_get_departures', [stop_point.id, stop_point.dataset_id])
        break;
      case 5:
        call('tfgm.tfgm_object.r_get_predictions', [stop_point.stop_code]);
        break;
      case 6:
        call('tfgm_xml.tfgm_xml_object.r_get_predictions', [stop_point.stop_code, stop_point.stop_letter]);
        break;
      default:
        app.signal_error('python_handler', 'r_get_departures', 'Unhandled dataset');
    }
  }

  function r_get_arrivals(stop_point) {
    console.log("r_get_arrivals:", stop_point.id);
    
    switch(stop_point.dataset_id) {
      case 1:
        call('ldbws.ldbws_object.r_get_arrivals', [stop_point.stop_code])
        break;
      case 2:
        call('tfl.tfl_object.r_get_predictions', [stop_point.id]);
        break;
      case 3:
        call('dbahn.dbahn_object.r_get_arrivals', [stop_point.id])
        break;
      case 4:
        call('trest.trest_object.r_get_arrivals', [stop_point.id, stop_point.dataset_id])
        break;
      case 5:
        call('tfgm.tfgm_object.r_get_predictions', [stop_point.stop_code]);
        break;
      default:
        app.signal_error('python_handler', 'r_get_arrivals', 'Unhandled dataset');
    }
  }

  function r_get_predictions(stop_point_id) {
    console.log("r_get_predictions:", stop_point_id);
    var stops = call('tfl.tfl_object.r_get_predictions', [stop_point_id]);
  }

  function a_get_predictions(predictions) {
    if (!predictions || predictions.length < 1) {
      console.log('a_get_predictions - no set')
      app.signal_a_get_predictions([]);
      return;
    }

    predictions.sort(function(a, b) {
      if (a.timeToStation) return a.timeToStation - b.timeToStation;
      if (a.time_to_station) return a.time_to_station - b.time_to_station;
    });

    //console.log(JSON.stringify(predictions));

    app.signal_a_get_predictions(predictions);
  }

  function a_get_predictions_fastest(predictions) {
    if (!predictions || predictions.length < 1) {
      console.log('a_get_predictions_fastest - no set')
      app.signal_a_get_predictions_fastest([]);
      return;
    }

    app.signal_a_get_predictions_fastest(predictions);
  }

  function r_get_vehicle_predictions(vehicle_id, line_id) {
    console.log("r_get_vehicle_predictions:", vehicle_id, line_id);
    var stops = call('tfl.tfl_object.r_get_vehicle_predictions', [vehicle_id, line_id]);
  }

  function a_get_vehicle_predictions(predictions) {
    app.signal_a_get_vehicle_predictions(predictions);
  }

  function r_get_journey(from_stop_point, to_stop_point, start_time, routing_preference, routing_modes) {
    console.log("r_get_journey:", from_stop_point.id, "->", to_stop_point.id);

    if (app.settings.data_source.numbering_area == 1) var stops = call('tfl.tfl_object.r_get_journey', [from_stop_point, to_stop_point, start_time, routing_preference, routing_modes]);
    else if (app.settings.data_source.numbering_area == 2) var stops = call('trest.trest_object.r_get_journey', [from_stop_point, to_stop_point, start_time.getTime(), routing_preference, routing_modes]);    
  }

  function a_get_journey(journeys) {
    app.signal_a_get_journey(journeys);
  }

  function r_get_trip(trip_id, line_id, from_stop_point_id, to_stop_point_id) {
    console.log("r_get_trip:", from_stop_point_id, "->", to_stop_point_id, "area:", app.settings.data_source.numbering_area);

    if (app.settings.data_source.numbering_area == 2) call('trest.trest_object.r_get_trip', [trip_id, line_id, from_stop_point_id, to_stop_point_id]);    
  }

  function a_get_trip(trip) {
    if (trip) app.signal_a_get_trip(trip);
  }

  function a_get_fares(fare_details) {
    app.signal_a_get_fares(fare_details);
  }

  function r_get_ldbws_departures(stop_code, to_stop_code) {
    console.log("r_get_ldbws_departures:", stop_code);
    var stops = call('ldbws.ldbws_object.r_get_departures', [stop_code, to_stop_code]);
  }

  function r_get_ldbws_arrivals(stop_code, to_stop_code) {
    console.log("r_get_ldbws_arrivals:", stop_code);
    var stops = call('ldbws.ldbws_object.r_get_arrivals', [stop_code, to_stop_code]);
  }

  function r_get_ldbws_next_departures(stop_code, to_stop_code) {
    var stops = call('ldbws.ldbws_object.r_get_next_departures', [stop_code, to_stop_code]);
  }

  function r_get_ldbws_fastest_departures(stop_code, to_stop_code) {
    var stops = call('ldbws.ldbws_object.r_get_fastest_departures', [stop_code, to_stop_code]);
  }

  function r_get_ldbws_service_details(service_id, origin_codes, destination_codes) {
    console.log("r_get_ldbws_service_details:", service_id);
    var stops = call('ldbws.ldbws_object.r_get_service_details', [service_id, origin_codes, destination_codes]);
  }

  function r_get_trest_service_details(service_id, line_id) {
    console.log("r_get_trest_trip_details - service_id:", service_id, "line_id:", line_id);
    var stops = call('trest.trest_object.r_get_service_details', [service_id, line_id]);
  }

  function r_get_fares(from_stop_point_id, to_stop_point_id) {
    if (app.settings.data_source.numbering_area != 1) return;

    console.log("r_get_fares:", from_stop_point_id, "->", to_stop_point_id);
    var stops = call('tfl.tfl_object.r_get_fares', [from_stop_point_id, to_stop_point_id]);
  }

  function r_get_disruptions(modes) {
    console.log("r_get_disruptions:", modes);
    var stops = call('tfl.tfl_object.r_get_disruptions', [modes]);
  }

  function a_get_disruptions(disruptions) {
    app.signal_a_get_disruptions(disruptions);
  }

  function get_lines(modes) {
    return call_sync('database.database_object.get_lines', [modes]);
  }

  function get_route_sections(line_id, mode_id) {
    return call_sync('database.database_object.get_route_sections', [line_id, mode_id]);
  }

  function get_route_sequences(line_id, mode_id) {
    return call_sync('database.database_object.get_route_sequences', [line_id, mode_id]);
  }

  function get_route_sequence_details(line_id, mode_id, branch_id, direction) {
    return call_sync('database.database_object.get_route_sequence_details', [line_id, mode_id, branch_id, direction]);
  }

  function get_route_sequences_by_stops(from_stop_id, to_stop_id, modes) {
    return call_sync('database.database_object.get_route_sequences_by_stops', [from_stop_id, to_stop_id, modes]);
  }

  function r_get_mode_status(modes) {
    console.log("r_get_mode_status:", modes);
    var stops = call('tfl.tfl_object.r_get_mode_status', [modes]);
  }

  function a_get_mode_status(status_entries) {
    app.signal_a_get_mode_status(status_entries);
  }

  function a_get_station_messages(station_messages) {
    app.signal_a_get_station_messages(station_messages);
    console.log("a_get_station_messages:", station_messages);
  }

  function load_settings(settings) {
    if (!settings) {
      console.log('ERROR load_settings - no settings');
      return;
    }

    console.log('load_settings - version:',settings.general.program_version);

    call('database.database_object.set_numbering_area', [settings.data_source.numbering_area]);

    app.settings = settings
    app.use_location = app.settings.location.use_location;
    app.saved_stop_points = call_sync('configuration.multimodal_configuration.saved_stop_points_get_area', [settings.data_source.numbering_area]);
    a_stops_by_ids(app.saved_stop_points)
    app.signal_settings_loaded();
  }

  function save_settings() {
    app.settings.history.active_page = app.active_page

    call('configuration.multimodal_configuration.save', [app.settings]);
  }

  function stop_point_save(stop_point) {
    console.log('stop_point_save:', call_sync('configuration.multimodal_configuration.saved_stop_points_save', [stop_point]));
    app.saved_stop_points = call_sync('configuration.multimodal_configuration.saved_stop_points_get_area', [settings.data_source.numbering_area]);
    a_stops_by_ids(app.saved_stop_points)
  }
  
  function stop_point_delete(stop_point_id) {
    console.log('stop_point_delete:', call_sync('configuration.multimodal_configuration.saved_stop_points_delete', [stop_point_id, settings.data_source.numbering_area]));
    app.saved_stop_points = call_sync('configuration.multimodal_configuration.saved_stop_points_get_area', [settings.data_source.numbering_area]);
    a_stops_by_ids(app.saved_stop_points)
  }

  function get_colors(module_id, operator_id, mode_id, type_id, line_id) {
    return call_sync('tfl.tfl_object.get_colors', [operator_id, mode_id, type_id, line_id]);
  }
}

