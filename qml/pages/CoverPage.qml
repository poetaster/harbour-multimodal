import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
  id: cover_page

  property bool reload_requested: false
  property string ldbws_service_id: ''
  property string vehicle_id: ""
  property string fastest_service: ''

  Icon {
    id: background_image
    source: "../../img/harbour-multimodal.svg"
    fillMode: Image.PreserveAspectFit
    opacity: 0.15
    width: parent.width * 0.8
    anchors {
      verticalCenter: parent.verticalCenter
      horizontalCenter: parent.horizontalCenter
    }
  }

  CoverMainView {
    id: cover_main_view
    visible: app.active_page == 'main'
    width: parent.width
    height: parent.height
    anchors {
      top: parent.top
      left: parent.left
    }
  }

  CoverPredictionsView {
    id: cover_predictions_view
    visible: app.active_page == 'predictions'
    width: parent.width
    height: parent.height
    anchors {
      top: parent.top
      left: parent.left
    }
  }

  CoverCallingPointsView {
    id: cover_calling_points_view
    visible: app.active_page == 'vehicle_predictions'
    width: parent.width
    height: parent.height
    anchors {
      top: parent.top
      left: parent.left
    }
  }

  CoverPositionView {
    id: cover_position_view
    visible: app.active_page == 'map'
    width: parent.width
    height: parent.height
    anchors {
      top: parent.top
      left: parent.left
    }
  }

  BusyIndicator {
    anchors.centerIn: parent
    size: BusyIndicatorSize.Small
    running: reload_requested
  }

  CoverActionList {
    enabled: app.active_page == 'predictions' || app.active_page == 'vehicle_predictions'
    CoverAction {
      iconSource: "image://theme/icon-cover-sync"
      onTriggered: {
        reload_requested = true
        app.signal_reload_data()
      }
    }
  }

  Component.onCompleted: {
    app.signal_a_get_predictions.connect(a_get_predictions)
    app.signal_a_get_predictions_fastest.connect(a_get_predictions_fastest)
    app.signal_a_geo_stops.connect(a_geo_stops)
    app.signal_a_get_vehicle_predictions.connect(a_get_vehicle_predictions)
  }

  Component.onDestruction: {
    app.signal_a_get_predictions.disconnect(a_get_predictions)
    app.signal_a_get_predictions_fastest.disconnect(a_get_predictions_fastest)
    app.signal_a_geo_stops.disconnect(a_geo_stops)
    app.signal_a_get_vehicle_predictions.disconnect(a_get_vehicle_predictions)
  }

  onStatusChanged: {
    console.log('cover status:', status)
    if (status === PageStatus.Active) {
      app.signal_position_update.connect(cover_position_view.position_update)
    } else if (status === PageStatus.Inactive) {
      app.signal_position_update.disconnect(cover_position_view.position_update)
    }
  }

  function a_get_predictions(predictions) {
    reload_requested = false
    
    var destinations = {}
    var cover_predictions = []
    for (var i=0; i<predictions.length; i++) {
      if (predictions[i].is_cancelled) continue;
      var index = destinations[predictions[i].title + '_' + predictions[i].subtitle]
      if (index == undefined) {
        index = cover_predictions.length
        destinations[predictions[i].title + '_' + predictions[i].subtitle] = index
        cover_predictions.push({
          'title': predictions[i].title,
          'time_to_station': predictions[i].time_to_station, 
          'service_id': predictions[i].service_id,
          'mark_color': predictions[i].mark_color,
          'main_color': predictions[i].main_color,
          'text_color': predictions[i].text_color,
          'times_to_station': []
        })

        console.log('cover - a_get_predictions - title:', predictions[i].title)

      } else if (cover_predictions[index].time_to_station < 60) {
        cover_predictions[index].time_to_station = predictions[i].time_to_station
        cover_predictions[index].times_to_station.push(predictions[i].time_to_station)
      } else {
        cover_predictions[index].times_to_station.push(predictions[i].time_to_station)
      }
    }

    cover_predictions_view.predictions = cover_predictions
  }

  function a_get_predictions_fastest(timetable_entries) {
    for (var i=0; i<timetable_entries.length; i++) {
      fastest_service = timetable_entries[i].service_id
      break
    }
  }

  function a_geo_stops(stop_points) {
    reload_requested = false

    cover_main_view.stop_points = stop_points
  }

  function a_get_vehicle_predictions(prediction_sets) {
    reload_requested = false
    if (typeof(prediction_sets) !== 'object') return;
    cover_calling_points_view.calling_points = []
    var last_calling_point_id = ''
    var last_expected_arrival = '';
    var selected_predictions = []
    var time_to_station_positive = false
    for (var s=0; s<prediction_sets.length; s++) {
      const predictions = prediction_sets[s]
      for (var i=0; i<predictions.length; i++) {
        if (last_calling_point_id && predictions[i].calling_point_id === last_calling_point_id) continue;
        if (!time_to_station_positive) time_to_station_positive = predictions[i].timeToStation > 0
        if (!time_to_station_positive && predictions[i].timeToStation < -5 && predictions[i + 1] && predictions[i + 1].timeToStation < -5) continue
        if (predictions[i].is_cancelled) continue
        last_calling_point_id = predictions[i].calling_point_id
        last_expected_arrival = predictions[i].time_expected
        selected_predictions.push(predictions[i])
      }
      break;
    }

    cover_calling_points_view.calling_points = selected_predictions
  }
}
