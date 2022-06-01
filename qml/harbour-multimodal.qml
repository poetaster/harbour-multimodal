import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow {
  id: app

  signal signal_a_search_stop(var stops)
  signal signal_a_geo_stop(var stop)
  signal signal_a_geo_stops(var stops)
  signal signal_a_stops_by_ids(var stops)
  signal signal_a_get_predictions(var predictions)
  signal signal_a_get_predictions_fastest(var predictions)
  signal signal_a_get_vehicle_predictions(var predictions)
  signal signal_a_get_journey(var journeys)
  signal signal_a_get_trip(var trip)
  signal signal_a_get_fares(var fare_details)
  signal signal_a_get_disruptions(var disruptions)
  signal signal_a_get_mode_status(var status_entries)
  signal signal_a_get_station_messages(var station_messages)
  signal signal_position_update(var latitude, var longitude, var accuracy, var timestamp)
  signal signal_settings_loaded()
  signal signal_reload_data()
  signal signal_error(string module_id, string method_id, string description)

  property string version: '0.85'
  property bool use_location: false

  property var settings
  property var saved_stop_points
  property string active_page: ''

  property var alerts_displayed:  { '_all': 0 }
  property var page_history: []

  DBusHandler {
    id: dbus_handler
  }

  MainHandler {
    id: main_handler
  }

  PythonHandler {
    id: python
  }

  NotificationsHandler {
    id: notifications_handler
  }

  initialPage: Component { 
    id: initial_page

    MainPage {
      id: page
    }
  }
  
  cover: Component { 
    id: cover_component

    CoverPage {
      id: cover_page
    } 
  }

  Component.onCompleted: {
    Qt.application.name = "multimodal";
    Qt.application.organization = "app.qml";
  }
}
