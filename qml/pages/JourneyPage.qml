import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
  id: journey_page

  property var journey

  property string title: ''
  property string page_name: ''

  property bool show_calling_points: Boolean(app.settings.routing.show_calling_points)

  SilicaListView {
    id: list_view

    anchors.fill: parent

    PullDownMenu {
      id: pulley
      MenuItem {
        id: show_cp_item
        visible: !show_calling_points
        text: "Show calling points"
        onClicked: {
          show_calling_points = true
        }
      }
      MenuItem {
        id: hide_cp_item
        visible: show_calling_points
        text: "Hide calling points"
        onClicked: {
          show_calling_points = false
        }
      }
    }

    header: Item {
      width: parent.width
      height: Theme.itemSizeMedium

      Label {
        id: start_time_label
        text: main_handler.parse_date(journey.start_time).toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
        font.pixelSize: Theme.fontSizeSmall
        anchors {
          top: parent.top
          left: parent.left
          leftMargin: Theme.paddingSmall
          topMargin: Theme.paddingMedium
        }
      }

      Label {
        id: departure_point_top_label
        text: journey.departure_point_name
        truncationMode: TruncationMode.Fade
        font.pixelSize: Theme.fontSizeSmall
        anchors {
          top: start_time_label.top
          left: start_time_label.right
          right: parent.right
          leftMargin: Theme.paddingMedium
        }
      }

      Label {
        id: arrival_time_label
        text: main_handler.parse_date(journey.arrival_time).toLocaleTimeString(Qt.locale(), Locale.ShortFormat)  
        font.pixelSize: Theme.fontSizeSmall
        anchors {
          top: start_time_label.bottom
          left: parent.left
          leftMargin: Theme.paddingSmall
        }
      }

      Label {
        id: arrval_point_label
        text: journey.arrival_point_name
        truncationMode: TruncationMode.Fade
        font.pixelSize: Theme.fontSizeSmall
        anchors {
          top: arrival_time_label.top
          left: arrival_time_label.right
          right: parent.right
          leftMargin: Theme.paddingMedium
        }
      }

      Icon {
        id: duration_icon
        height: Theme.iconSizeSmall
        width: Theme.iconSizeSmall
        anchors {
          verticalCenter: parent.verticalCenter
          right: duration_label.left
        }
        source: "image://theme/icon-s-duration"
      }

      Label {
        id: duration_label
        text: main_handler.minutes_to_hours(journey.duration)
        anchors {
          verticalCenter: duration_icon.verticalCenter
          right: parent.right
          rightMargin: Theme.paddingMedium
        }
      }
    }

    spacing: 10

    model: ListModel {
      id: legs_list_model
    }

    delegate: ListItem {
      id: list_item

      contentHeight: stops_column.height + options_column.height + departure_time_label.height + arrival_time_label.height + Theme.paddingSmall

      Column {
        id: options_column
        anchors {
          top: parent.top
          leftMargin: Theme.paddingMedium
        }

        Repeater {
          model: journey.legs[index] ? journey.legs[index].options : 0
          Rectangle {
            id: line_color_rectangle
            height: option_label.height + directions_label.height
            width: list_item.width
            color: String(modelData.main_color)

            Rectangle {
              id: mainline_rail_rectangle
              visible: Boolean(modelData.mark_color)
              width: 20
              color: String(modelData.mark_color)
              anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
              }
            }

            Column {
              anchors {
                left: parent.left
              }
              Label {
                id: option_label
                font.pixelSize: Theme.fontSizeExtraSmall
                text: modelData.name.length ? modelData.name : summary
                color: modelData.text_color
                anchors {
                  left: parent.left
                  leftMargin: Theme.paddingMedium
                }
              }
              Label {
                visible: cleanup_destinations(modelData.directions).join('·').length
                id: directions_label
                font.pixelSize: Theme.fontSizeSmall
                text: "➡" + cleanup_destinations(modelData.directions).join('·')
                color: modelData.text_color
              }
              Label {
                visible: modelData.mode == 'walking' && Boolean(modelData.distance > 0)
                id: walking_distance_label
                font.pixelSize: Theme.fontSizeSmall
                text: " " + (modelData.distance >= 1000.0 ? (modelData.distance / 1000).toFixed(1) + 'km': Math.round(modelData.distance) + "m")
                color: modelData.text_color
              }
            }
          } 
        }
      }

      Rectangle {
        width: 10
        color: Theme.primaryColor
        anchors {
          top: departure_time_label.verticalCenter
          bottom: departure_time_label.bottom
          left: parent.left
          leftMargin: 5
        }
      }

      Rectangle {
        id: stop_circle_departure
        height: 20
        width: 20
        radius: 10
        color: Theme.primaryColor
        anchors {
          verticalCenter: departure_time_label.verticalCenter
          left: parent.left
        }
      }

      Label {
        id: departure_time_label
        text: main_handler.parse_date(model.departure_time).toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
        anchors {
          top: options_column.bottom
          left: stop_circle_departure.right
          leftMargin: Theme.paddingSmall
        }
      }

      Label {
        id: departure_point_label
        text: main_handler.cleanup_destination(model.departure_point_name) 
        truncationMode: TruncationMode.Fade
        anchors {
          top: departure_time_label.top
          left: departure_time_label.right
          right: departure_point_platform_icon.left
          leftMargin: Theme.paddingMedium
        }
      }

      Icon {
        id: departure_point_platform_icon
        width: 25
        visible: departure_point_platform_label.visible
        fillMode: Image.PreserveAspectFit
        anchors {
          bottom: departure_point_platform_label.baseline
          right: departure_point_platform_label.left
          leftMargin: Theme.paddingSmall
          rightMargin: Theme.paddingSmall
        }
        source: "../../img/platform.svg"
      }

      Label {
        visible: Boolean(model.departure_point_platform)
        id: departure_point_platform_label
        font.pixelSize: Theme.fontSizeExtraSmall
        text: String(model.departure_point_platform)
        anchors {
          top: departure_point_label.top
          right: parent.right
          rightMargin: Theme.paddingSmall
        }
      }

      Row {
        id: mode_icons_row
        anchors {
          top: parent.top
          right: parent.right
          leftMargin: Theme.paddingMedium
          topMargin: Theme.paddingMedium
        }
        BusStopIcon {
          id: bus_stop_icon
          stop_text: String(model.departure_point_stop_letter)
          visible: Boolean(model.departure_point_stop_letter)
        }
        Image {
          id: mode_icon
          visible: !bus_stop_icon.visible
          height: 72
          width: 84
          fillMode: Image.PreserveAspectFit
          source: "../../img/" + String(model.icon_name) + '.svg'
        }
      }

      Rectangle {
        id: stops_vertical_rectangle
        width: 10
        color: Theme.primaryColor
        anchors {
          top: departure_time_label.bottom
          bottom: arrival_time_label.top
          left: parent.left
          leftMargin: 5
        }
      }

      Column {
        id: stops_column
        visible: show_calling_points
        height: visible ? stops_repeater.contentHeight : 0
        anchors {
          top: departure_time_label.bottom
          left: stops_vertical_rectangle.right
          leftMargin: Theme.paddingMedium
        }

        Repeater {
          id: stops_repeater
          model: {
            if (!journey.legs[index]) return 0;
            return journey.legs[index].stops
          }
          
          Label {
            id: enroute_stop_label
            font.pixelSize: Theme.fontSizeExtraSmall
            text: modelData.title
          }
        }
      }

      Label {
        id: duration_label
        text: main_handler.minutes_to_hours(duration)
        anchors {
          verticalCenter: stops_column.verticalCenter
          right: parent.right
          rightMargin: Theme.paddingMedium
        }
      }

      Icon {
        id: disruption_icon
        height: Theme.iconSizeSmall
        width: Theme.iconSizeSmall
        visible: Boolean(model.id_disrupted)
        anchors {
          top: duration_label.bottom
          topMargin: 0
          right: parent.right
          rightMargin: Theme.paddingMedium
        }
        source: "image://theme/icon-s-warning"
      }

      Rectangle {
        width: 10
        color: Theme.primaryColor
        anchors {
          bottom: arrival_time_label.verticalCenter
          top: arrival_time_label.top
          left: parent.left
          leftMargin: 5
        }
      }

      Rectangle {
        id: stop_circle_arrival
        height: 20
        width: 20
        radius: 10
        color: Theme.primaryColor
        anchors {
          verticalCenter: arrival_time_label.verticalCenter
          left: parent.left
        }
      }

      Label {
        id: arrival_time_label
        text: main_handler.parse_date(arrival_time).toLocaleTimeString(Qt.locale(), Locale.ShortFormat)  
        anchors {
          top: stops_column.bottom
          left: stop_circle_arrival.right
          leftMargin: Theme.paddingSmall
        }
      }

      Label {
        id: arrval_point_label
        text: main_handler.cleanup_destination(arrival_point_name)  
        truncationMode: TruncationMode.Fade
        anchors {
          top: stops_column.bottom
          left: arrival_time_label.right
          right: arrival_point_platform_icon.left
          leftMargin: Theme.paddingMedium
        }
      }

      Icon {
        id: arrival_point_platform_icon
        width: 25
        visible: arrival_point_platform_label.visible
        fillMode: Image.PreserveAspectFit
        anchors {
          bottom: arrival_point_platform_label.baseline
          right: arrival_point_platform_label.left
          leftMargin: Theme.paddingSmall
          rightMargin: Theme.paddingSmall
        }
        source: "../../img/platform.svg"
      }

      Label {
        visible: Boolean(model.arrival_point_platform)
        id: arrival_point_platform_label
        font.pixelSize: Theme.fontSizeExtraSmall
        text: String(model.arrival_point_platform)
        anchors {
          bottom: arrval_point_label.bottom
          right: parent.right
          rightMargin: Theme.paddingSmall
        }
      }

      Component.onCompleted: {

      }

      onClicked: {
        if (!model.departure_point_id || !model.departure_point_id.length || model.mode == 'walking') return;

        const stop_point = python.get_stop_by_code_name_letter(model.departure_point_id, model.departure_point_name, model.departure_point_stop_letter);

        console.log("stop_point:", stop_point);
        if (stop_point) {
          pageStack.push(
            Qt.resolvedUrl("PredictionsPage.qml"), {
              'stop_point': stop_point
            }
          )
         return 
        }

        pageStack.push(
          Qt.resolvedUrl("PredictionsPage.qml"), {
            'stop_point': {
              'id': departure_point_id,
              'name': model.departure_point_name,
              'indicator': model.departure_point_stop_letter,
              'code': python.get_stop_code(model.departure_point_id) || '', 
              'modes': model.mode,
              'line_ids': undefined,
            }
          }
        )
      }
    }
  }

  onShow_calling_pointsChanged: {
    if (!show_calling_points) return;
    for (var i=0; i<journey.legs.length; i++) {
      if (journey.legs[i].trip_id && journey.legs[i].options[0].line_id) python.r_get_trip(journey.legs[i].trip_id, journey.legs[i].options[0].line_id, journey.legs[i].departure_point_id, journey.legs[i].arrival_point_id);
    }
  }

  Component.onCompleted: {
    app.signal_a_get_trip.connect(process_trips)
   
    draw_journey();
    
    main_handler.add_history({
      'page_name': 'JourneyPage.qml',
      'title': '⇨' + main_handler.parse_date(journey.start_time).toLocaleTimeString(Qt.locale(), Locale.ShortFormat) + ' ' + journey.arrival_point_name,
      'journey': journey,
    })
  }

  Component.onDestruction: {
    app.signal_a_get_trip.disconnect(process_trips)
  }

  onStatusChanged: {
    if (status === PageStatus.Active || status === PageStatus.Activating) app.active_page = 'journey'
  }

  function cleanup_destinations(desinations) {
    var clean = [];
    for (var i=0; i<desinations.length; i++) {  
      clean.push(main_handler.cleanup_destination(desinations[i]))
    }
    return clean;
  }

  function draw_journey() {
    legs_list_model.clear()
    for (var i=0; i<journey.legs.length; i++) {  
      legs_list_model.append(journey.legs[i]);
    }
  }

  function process_trips(trip) {
    if (!trip.stops.length) return;

    for (var i=0; i<journey.legs.length; i++) {
      var leg = journey.legs[i]
      if (leg.trip_id !== trip.trip_id) continue;
      leg.stops = trip.stops
      legs_list_model.remove(i, 1)
      legs_list_model.insert(i, leg)
    }

    for (var i=0; i<trip.remarks.length; i++) {
      console.log("process_trips - remark: ", trip.remarks[i].type, trip.remarks[i].code, trip.remarks[i].text)
    }
  }
}
