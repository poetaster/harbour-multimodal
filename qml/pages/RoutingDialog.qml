import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

Dialog {
  id: routing_dialog

  canAccept: Boolean(from_stop_point && to_stop_point)

  RemorseItem { id: remorse_item }

  property var routing_page
  property string from_name
  property string to_name
  
  property real latitude: 0.0
  property real longitude: 0.0

  property var start_time: null
  property var start_time_value: null
  property var start_date_value: null

  property var from_stop_point: {}
  property var to_stop_point: {}

  property var routing_modes: []
  property var route_modes: {'tube': false}

  property var route_modes_list: [
    [],
    ["national-rail", "elizabeth-line", "overground", "tube", "dlr", "tram", "bus", "replacement-bus", "walking"],
    ["national-express-rail", "national-rail", "regional-rail", "regional-express-rail", "overground", "tube", "tram", "bus", "walking"],
  ]

  property var route_mode_icons_list: [
    {},
    {
    "national-rail": 'nationalrail',
    "tflrail": "tflrail",
    "elizabeth-line": "elizabethline",
    "overground": 'overground', 
    "tube": 'tube', 
    "dlr": 'dlr', 
    "tram": 'tram', 
    "bus": 'bus', 
    "replacement-bus": 'replacementbus', 
    "walking": 'walking',
  },
  {
    "national-express-rail": 'de_ice', 
    "national-rail": 'de_ic', 
    "regional-rail": 'de_rb', 
    "regional-express-rail": 'de_re', 
    "overground": 'de_s', 
    "tube": 'de_u', 
    "tram": 'de_str', 
    "bus": 'de_bus', 
    "replacement-bus": 'de_sev', 
    "walking": 'walking',
  },
  ]

  property var route_mode_names_list: [
    {},
    {
    "national-rail": 'National Rail',
    "tflrail": "TfL Rail",
    "elizabeth-line": "Elizabeth line",
    "overground": 'Overground', 
    "tube": 'Underground', 
    "dlr": 'DLR', 
    "tram": 'Tram', 
    "bus": 'Bus', 
    "replacement-bus": 'Replacement Bus', 
    "walking": 'Walking',
  },
  {
    "national-express-rail": 'National Express Rail', 
    "national-rail": 'National Rail', 
    "regional-rail": 'Regional Rail', 
    "regional-express-rail": 'Regional Express Rail', 
    "overground": 'Suburban Rail', 
    "tube": 'Subway', 
    "tram": 'Tram', 
    "bus": 'Bus', 
    "replacement-bus": 'Replacement Bus', 
    "walking": 'Walking',
  },
  ]

  SilicaFlickable {
    anchors.fill: parent

    contentHeight: main_column.height

    VerticalScrollDecorator {}

    Column {
      id: main_column

      width: parent.width
      
      anchors {
        left: parent.left
        top: parent.top
      }

      DialogHeader {
        title: "Route preferences"
      }

      SectionHeader {
        text: "Origin"
      }

      ValueButton {
        id: from_button
        label: "From"
        value: from_name
        width: parent.width
        onClicked: {
          var dialog = pageStack.push("StopSearchDialog.qml", {
            'search_text': to_name,
            'pos_latitude': latitude,
            'pos_longitude': longitude,
          })
          dialog.accepted.connect(function() {
            from_button.value = dialog.stop_point.name
            routing_dialog.from_stop_point = {
              'id': dialog.stop_point.id,
              'name': dialog.stop_point.name,
              'lat': dialog.stop_point.lat,
              'lon': dialog.stop_point.lon,
              'numbering_area': dialog.stop_point.numbering_area,
              'dataset_id': dialog.stop_point.dataset_id,
              'lines': dialog.stop_point.lines,
              'modes': dialog.stop_point.modes,
            }
          })
        }
      }

      Button {                            
        //height: Theme.buttonHeightTiny
        width: height
        icon.source: "image://theme/icon-m-shuffle"
        anchors {
          right: parent.right
          rightMargin: Theme.horizontalPageMargin
        }

        onClicked: {
          var to_stop_point_new = routing_dialog.from_stop_point
          var to_name_new = routing_dialog.from_name

          routing_dialog.from_stop_point = routing_dialog.to_stop_point
          routing_dialog.from_name = routing_dialog.to_name
          routing_dialog.to_stop_point = to_stop_point_new
          routing_dialog.to_name = to_name_new

          console.log("swap: ", routing_dialog.from_name, '->', routing_dialog.to_name)
        }
      } 

      SectionHeader {
        text: "Destination"
      }

      ValueButton {
        id: to_button
        label: "To"
        value: to_name
        width: parent.width
        onClicked: {
          var dialog = pageStack.push("StopSearchDialog.qml", {
            'search_text': to_name,
            'pos_latitude': latitude,
            'pos_longitude': longitude,
          })
          dialog.accepted.connect(function() {
            to_button.value = dialog.stop_point.name
            routing_dialog.to_stop_point = {
              'id': dialog.stop_point.id,
              'name': dialog.stop_point.name,
              'lat': dialog.stop_point.lat,
              'lon': dialog.stop_point.lon,
              'numbering_area': dialog.stop_point.numbering_area,
              'dataset_id': dialog.stop_point.dataset_id,
              'lines': dialog.stop_point.lines,
              'modes': dialog.stop_point.modes,
            }

            console.log("two accepted:", routing_dialog.to_stop_point.name)
          })
        }
      }

      SectionHeader {
        text: "Leaving at"
      }

      ValueButton {
        id: date_button
        label: "Date"
        value: Qt.formatDate(start_time)
        width: parent.width
        onClicked: {
          var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
            date: start_time
          })
          dialog.accepted.connect(function() {
            date_button.value = dialog.dateText
            start_time.setFullYear(dialog.year)
            start_time.setMonth(dialog.month - 1)
            start_time.setDate(dialog.day)
            console.log(start_time)
          })
        }
      }

      ValueButton {
        id: time_button
        label: "Time"
        value: Qt.formatTime(start_time)
        width: parent.width
        onClicked: {
          var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
            hour: start_time.getHours(),
            minute: start_time.getMinutes(),
          })
          dialog.accepted.connect(function() {
            time_button.value = dialog.timeText
            start_time.setHours(dialog.hour, dialog.minute, 0, 0)
            console.log(start_time)
          })
        }
      }

      SectionHeader {
        text: "Transport modes"
      }

      Repeater {
        model: route_modes_list[app.settings.data_source.numbering_area] //["national-rail","tflrail","overground","tube","dlr","tram","bus","replacement-bus","walking"]
        Row {
          width: parent.width
          height: Theme.itemSizeExtraSmall
          anchors {
            rightMargin: Theme.paddingSmall
          }
          TextSwitch {
            id: mode_switch
            width: parent.width - mode_icon.width
            text: route_mode_names_list[app.settings.data_source.numbering_area][modelData]
            checked: routing_modes.indexOf(modelData) >= 0
            onCheckedChanged: {
              route_modes[modelData] = mode_switch.checked
            }
          }
          Image {
            id: mode_icon
            height: 72
            width: 84
            fillMode: Image.PreserveAspectFit
            source: "../../img/"+route_mode_icons_list[app.settings.data_source.numbering_area][modelData]+".svg"
            anchors {
              rightMargin: Theme.paddingMedium
              verticalCenter: mode_switch.verticalCenter
            }
          }
        }
      }

    }
  }

  onOpened: {
    console.log("RouteDialog opened")
    if (from_stop_point && from_stop_point.name) from_name = from_stop_point.name
    if (to_stop_point && to_stop_point.name) to_name = to_stop_point.name

    for (var i=0; i<routing_modes.length; i++) {
      route_modes[routing_modes[i]] = true
    }
  }

  onAccepted: {
    var selected_modes = []
    for (var mode_name in route_modes) {
      if (route_modes[mode_name]) selected_modes.push(mode_name);
    }
    routing_modes = selected_modes 
  }

  onRejected: {
    console.log("RouteDialog rejected")
  }

  onDone: {
    console.log("RouteDialog done")
  }

  onStatusChanged: {
    if (status === PageStatus.Active || status === PageStatus.Activating) app.active_page = 'routing_dialog'
  }
}
