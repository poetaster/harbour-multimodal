import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
  id: dashboard_page

  property var stop_point
  property var to_stop_point

  property bool data_requested: false
  property int board_type: 0
  property var prediction_data: []

  property bool direct_route_exists: false

  property string title: ''
  property string page_name: ''

  property string fastest_service: ''
  property var station_messages: []

  SilicaFlickable {
    Item {
      id: header_item
      height: Theme.itemSizeExtraSmall
      width: parent.width

      Label {
        id: stop_name_label
        text: main_handler.cleanup_destination(stop_point.name)
        truncationMode: TruncationMode.Fade
        fontSizeMode: Text.Fit
        minimumPixelSize: Theme.fontSizeExtraSmall
        font.pixelSize: Theme.fontSizeMedium
        anchors {
          verticalCenter: header_item.verticalCenter
          left: parent.left
          right: icons_widget.left
          leftMargin: Theme.paddingSmall
        }
      }
        
      ModesIconsWidget {
        id: icons_widget
        stop_numbering_area: stop_point.numbering_area
        stop_dataset_id: stop_point.dataset_id
        stop_modes: stop_point.modes
        stop_stop_type: stop_point.stop_type
        stop_stop_letter: stop_point.stop_letter

        anchors {
          right: parent.right
          rightMargin: Theme.paddingMedium
          verticalCenter: parent.verticalCenter
        }
      }
    }

    width: parent.width;
    //height: parent.height
    clip: panel_bottom.expanded
    height: parent.height - (panel_bottom.expanded ? panel_bottom.visibleSize : 0)

    PullDownMenu {
      id: pulley
      MenuItem {
        id: messages_item
        visible: station_messages.length
        text: "Station messages"
        onClicked: {
          pageStack.push(
            Qt.resolvedUrl("StationMessagesPage.qml"), {
              'stop_point': stop_point,
              'station_messages': station_messages,
            }
          )
        }
      }
      MenuItem {
        id: show_map_item
        visible: main_handler.map_available && pageContainer && pageContainer.depth < 3 //&& false //corruption of double-linked list has to be fixed before enabling
        text: "Show on map"
        onClicked: {
          pageStack.push(
            Qt.resolvedUrl("MapPage.qml"), {
              'stop_point': stop_point,
            }
          )
        }
      }
      MenuItem {
        id: departures_to_item
        visible: board_type !== 2 && direct_route_exists
        text: to_stop_point ? "Trains to " + main_handler.cleanup_destination(to_stop_point.name) : ''
        onClicked: {
          request_departures_to();
        }
      }
      MenuItem {
        id: arrivals_item
        visible: board_type !== 1 && main_handler.has_arrivals(stop_point.dataset_id)
        text: "Show arrivals"
        onClicked: {
          request_arrivals();
        }
      }
      MenuItem {
        id: departures_item
        visible: board_type !== 0 && main_handler.has_departures(stop_point.dataset_id)
        text: "Show departures"
        onClicked: {
          request_departures();
        }
      }
      MenuItem {
        id: reloadt_item
        text: "Reload"
        onClicked: reload_data()
      }
    }

    SilicaListView {
      width: parent.width;
      height: parent.height - Theme.itemSizeExtraSmall 
      clip: true

      anchors {
        top: header_item.bottom
      }

      BusyIndicator {
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: data_requested
      }

      ViewPlaceholder {
        enabled: list_model.count == 0 && !data_requested
        text: board_type === 1 ? "No arrivals" : "No departures"
        hintText: ""
      }

      model: ListModel {
          id: list_model

          function a_get_predictions(predictions) {
            if (predictions && predictions.length > 0) request_fatest_departures();
            data_requested = false;
            prediction_data = predictions
            clear()
            for (var i=0; i<predictions.length; i++) {
              if (board_type !== 1 && predictions[i].destination_id == stop_point.id) continue;

              predictions[i].prediction_data_index = i
              append(predictions[i]);
            }
          }

          function a_get_predictions_fastest(timetable_entries) {
            for (var i=0; i<timetable_entries.length; i++) {
              fastest_service = timetable_entries[i].service_id
              break
            }
          }

        Component.onCompleted: update([])
      }

      spacing: 10

      delegate: Loader {
        id: loader
        
        height: Theme.itemSizeMedium

        width: parent.width
        sourceComponent: {
          if (model.module === 'tfl' && model.transport_mode == 'bus') return  bus_predictions_widget;
          return train_predictions_widget;
        }

        MouseArea {
          width: loader.width
          height: loader.height
          enabled: Boolean(model.service_id || model.vehicle_id || (model.vehicleId && model.vehicleId.length > 0 && model.vehicleId != "000"))
          onClicked: {
            //API does not provide vehicle data)
            if (model.module === 'tfgm') return None;
            
            pageStack.push(
              Qt.resolvedUrl("CallingPointsPage.qml"), {
                'timetable_entry': prediction_data[prediction_data_index],
                'stop_point': stop_point,
              }
            )
              
          }
        }

        onLoaded: {
          loader.item.timetable_entry = prediction_data[prediction_data_index]
        }
      }

      TrainPredictionWidget { id: train_predictions_widget }
      BusPredictionWidget { id: bus_predictions_widget }

    }
  }

  DockedPanel {
    id: panel_bottom

    width: parent.width
    height: station_messages_column.height
    open: false
    modal: true

    dock: Dock.Bottom

    Column {
      id: station_messages_column
      width: parent.width
      spacing: Theme.paddingLarge

      Repeater {
        id: station_messages_repeater
        //model: station_messages_sig

        Column {
          width: parent.width
          spacing: Theme.paddingSmall
          anchors {
            left: parent.left
          }

          Row {
            width: parent.width
          
            Icon {
              id: disruption_icon
              height: Theme.iconSizeSmall
              width: Theme.iconSizeSmall
              visible: true
              source: "image://theme/icon-s-warning"
               anchors {
                leftMargin: Theme.paddingMedium
                verticalCenter: disruption_label.verticalCenter
              }
            }

            LinkedLabel {
              id: disruption_label
              width: parent.width - disruption_icon.width
              visible: true
              text: modelData.description
              wrapMode: Text.WordWrap
              defaultLinkActions: true
              font.pixelSize: Theme.fontSizeExtraSmall
              anchors {
                leftMargin: Theme.paddingMedium
              }
            }
          }
        }
      }
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        panel_bottom.hide()
      }
    }
  }

  Component.onCompleted: {
    app.signal_a_get_predictions.connect(list_model.a_get_predictions)
    app.signal_a_get_predictions_fastest.connect(list_model.a_get_predictions_fastest)
    app.signal_a_get_station_messages.connect(a_get_station_messages)
    app.signal_reload_data.connect(reload_data)
    app.signal_error.connect(error_handler)

    if (main_handler.has_departures(stop_point.dataset_id)) request_departures();
    else if (main_handler.has_arrivals(stop_point.dataset_id)) request_arrivals();
    else console.log('ERROR unhandled dataset_id:', stop_point.dataset_id)
    
    if (stop_point.id.length) {
      if (app.settings.history.to_stop_point_id.length && app.settings.history.to_stop_point_id !== stop_point.id) {
        to_stop_point = python.get_stop_by_id(app.settings.history.to_stop_point_id)

        if (to_stop_point) {
          const route_sequences = python.get_route_sequences_by_stops(stop_point.id, to_stop_point.id, ['national-rail', 'tflrail', 'overground'])
          console.log("direct routes - to_stop_point.id - from:", stop_point.id, 'to:', to_stop_point.id, 'routes:', route_sequences.length)
          direct_route_exists = route_sequences && route_sequences.length > 0
        }
      } 
      
      if (!direct_route_exists && app.settings.history.from_stop_point_id.length && app.settings.history.from_stop_point_id !== stop_point.id) {
        to_stop_point = python.get_stop_by_id(app.settings.history.from_stop_point_id)

        if (to_stop_point) {
          const route_sequences = python.get_route_sequences_by_stops(stop_point.id, to_stop_point.id, ['national-rail', 'tflrail', 'overground'])
          console.log("direct routes - from_stop_point.id - from:", stop_point.id, 'to:', to_stop_point.id, 'routes:', route_sequences.length)
          direct_route_exists = route_sequences && route_sequences.length > 0
        }
      }
    }

    var title = main_handler.cleanup_destination(stop_point.name)
    if (stop_point.stop_letter && stop_point.stop_letter.length > 0) title += ' (' +  stop_point.stop_letter + ')'
    switch(stop_point.stop_type) {
      case 2: //Bus Stop
      case 4: //Tram stop
        title += ' 🚏';
        break;
      case 6: //Light Rail station
      case 8: //metro station
      case 10: //rail station
        title += ' 🚉';
        break;
      case 12: //ferry port
        title += ' 🚢';
        break;
      case 12: //cable car station
        title += ' 🚡';
        break;
    } 

    main_handler.add_history({
      'page_name': 'PredictionsPage.qml',
      'title': title,
      'stop_point': stop_point,
      'to_stop_point': to_stop_point,
    })
  }

  Component.onDestruction: {
    data_requested = false;
    app.signal_a_get_predictions.disconnect(list_model.a_get_predictions)
    app.signal_a_get_predictions_fastest.disconnect(list_model.a_get_predictions_fastest)
    app.signal_a_get_station_messages.disconnect(a_get_station_messages)
    app.signal_reload_data.disconnect(reload_data)
    app.signal_error.disconnect(error_handler)
  }

  onStatusChanged: {
    if (status === PageStatus.Active || status === PageStatus.Activating) app.active_page = 'predictions'
    //console.log('predictions_page - status:', status, 'container depth:', pageContainer.depth)
  }

  function error_handler(module_id, method_id, description) {
    data_requested = false;
  }

  function reload_data() {
    if (app.active_page !== 'predictions') return;
    
    if (board_type === 1) request_arrivals();
    else if (board_type === 2) request_departures_to()
    else request_departures();
  }

  function request_departures_to() {
    data_requested = true;
    board_type = 2;
    python.r_get_departures(stop_point, to_stop_point);
  }

  function request_fatest_departures() {
    if (!direct_route_exists || !main_handler.has_fastest_trains(stop_point.dataset_id) || !main_handler.has_fastest_trains(to_stop_point.dataset_id) || board_type === 1) return;
    python.r_get_ldbws_fastest_departures(stop_point.stop_code, to_stop_point.stop_code);
  }

  function request_departures() {
    data_requested = true;
    board_type = 0;
    python.r_get_departures(stop_point);
  }

  function request_arrivals() {
    data_requested = true;
    board_type = 1;
    python.r_get_arrivals(stop_point);
  }

  function a_get_station_messages(messages) {
    if (!messages) return;

    station_messages = messages

    var station_messages_sig = []
    for (var i=0; i<messages.length; i++) {
      if (app.alerts_displayed[messages[i]] && app.alerts_displayed[messages[i]] + 3600 > Math.round(Date.now() / 1000)) continue;
      station_messages_sig.push({'description': messages[i]})
      app.alerts_displayed[messages[i]] = Math.round(Date.now() / 1000)
    }
    
    if (!station_messages_sig.length) return
    station_messages_repeater.model = station_messages_sig
    panel_bottom.show()
  }
}
