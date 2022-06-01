import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

Dialog {
  id: settings_dialog

  RemorseItem { id: remorse_item }

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

      }

      SectionHeader {
        text: "Display"
      }

      TextField {
        id: reload_timer_field
        width: parent.width
        label: "Automatic reload timer"
        placeholderText: "Time in seconds"
        description: "Time, in seconds, after views get automatically reloaded."
        inputMethodHints: Qt.ImhDigitsOnly
        validator: IntValidator {bottom: 0; top: 65534;}
        text: app.settings.predictions.reload_timer
        Keys.onReturnPressed: {

        }
      }

      SectionHeader {
        text: "Location"
      }

      Row {
        width: parent.width
        Switch {
          id: use_location_switch
          checked: app.settings.location.use_location
          icon.source: "image://theme/icon-m-location"
        }
        TextField {
          id: search_radius_field
          width: parent.width
          label: "Search radius"
          placeholderText: "Search radius in meters"
          inputMethodHints: Qt.ImhDigitsOnly
          validator: IntValidator {bottom: 1; top: 65534;}
          text: app.settings.location.search_radius
          Keys.onReturnPressed: {

          }
          anchors {
            verticalCenter: use_location_switch.verticalCenter
          }
        }
      }

      SectionHeader {
        text: "Routing"
      }

      ComboBox {
        id: routing_preferences_selector
        width: parent.width
        label: "Preference"

        menu: ContextMenu {
          MenuItem { text: "Fewest changes " }
          MenuItem { text: "Fastest" }
          MenuItem { text: "Least walking" }
        }
      }

      TextField {
        id: routing_time_offset_field
        width: parent.width
        label: "Time offset"
        placeholderText: "Time offset in minutes"
        inputMethodHints: Qt.ImhDigitsOnly
        validator: IntValidator {bottom: 1; top: 65534;}
        text: app.settings.routing.start_time_offset
        Keys.onReturnPressed: {

        }
        anchors {
          
        }
      }

      TextSwitch {
        id: fares_switch
        checked: app.settings.routing.request_fares
        text: "Show fares"
        description: "Look up TfL fares if possible"
      }

      TextSwitch {
        id: calling_points_switch
        checked: Boolean(app.settings.routing.show_calling_points)
        text: "Show calling points"
        description: "Display all calling points if available."
      }

      Label {
        text: "Transport modes"
        anchors {
          left: parent.left
          leftMargin: Theme.horizontalPageMargin
        }
      }

      Repeater {

        model: route_modes_list[app.settings.data_source.numbering_area] //["national-rail","tflrail","overground","tube","dlr","tram","bus","replacement-bus","walking"]
        Row {
          width: parent.width
          height: Theme.itemSizeExtraSmall
          anchors {
            rightMargin: Theme.paddingLarge
          }
          TextSwitch {
            id: mode_switch
            width: parent.width - mode_icon.width
            text: route_mode_names_list[app.settings.data_source.numbering_area][modelData]
            checked: app.settings.routing.modes.indexOf(modelData) >= 0
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

      SectionHeader {
        text: "Sort order"
      }

      ComboBox {
        id: stop_point_sort_order_selector
        width: parent.width
        label: "Sort order"

        menu: ContextMenu {
          MenuItem { text: "Distance" }
          MenuItem { text: "Train Stations, Tube Stations, Tram Stops → Bus Stops" }
          MenuItem { text: "Train Stations → Tube Stations, Tram Stops → Bus Stops" }
        }
      }

      SectionHeader {
        text: "History"
      }

      TextSwitch {
        id: history_menu_switch
        width: parent.width
        text: 'Page history'
        description: "Show history in main menu"
        checked: app.settings.history.show_in_menu
      }

      SectionHeader {
        text: "Default search area"
      }

      ComboBox {
        id: numbering_area_selector
        width: parent.width
        label: "Area"

        menu: ContextMenu {
          MenuItem { 
            enabled: false
            text: "Not selected"
          }
          MenuItem { text: "Great Britain" }
          MenuItem { text: "Germany" }
        }
      }

      SectionHeader {
        text: "Smartwatch"
      }

      ComboBox {
        id: smartwatch_fastest_train_selector
        width: parent.width
        label: "Fastest train"

        menu: ContextMenu {
          MenuItem { text: "Disabled" }
          MenuItem { text: "Send Alert" }
        }
      }

      ComboBox {
        id: smartwatch_button_selector
        width: parent.width
        label: "Reload button"

        menu: ContextMenu {
          MenuItem { text: "Disabled" }
          MenuItem { text: "Press 1" }
          MenuItem { text: "Press 2" }
          MenuItem { text: "Press 3" }
          MenuItem { text: "Press 4" }
          MenuItem { text: "Press 5" }
        }
      }
    }
  }

  onOpened: {
    console.log("SettingsDialog opened")
    routing_preferences_selector.currentIndex = ["leastinterchange", "leasttime", "leastwalking"].indexOf(app.settings.routing.preference)
    for (var i=0; i<app.settings.routing.modes.length; i++) {
      route_modes[app.settings.routing.modes[i]] = true
    }

    if ((app.settings.sorting.order_bus_stops > app.settings.sorting.order_metro_stations) &&(app.settings.sorting.order_metro_stations > app.settings.sorting.order_train_stations)) stop_point_sort_order_selector.currentIndex = 2;
    else if (app.settings.sorting.order_bus_stops > app.settings.sorting.order_metro_stations || app.settings.sorting.order_bus_stops >  app.settings.sorting.order_train_stations) stop_point_sort_order_selector.currentIndex = 1;
    else stop_point_sort_order_selector.currentIndex = 0;

    numbering_area_selector.currentIndex = app.settings.data_source.numbering_area
    app.settings.sorting.order_bus_stops
    app.settings.sorting.order_metro_stations
    app.settings.sorting.order_train_stations

    smartwatch_fastest_train_selector.currentIndex = app.settings.smartwatch.fastest_train_alert ? 1 : 0
    smartwatch_button_selector.currentIndex = app.settings.smartwatch.reload_button
  }

  onAccepted: {
    console.log("SettingsDialog accepted")
    app.settings.predictions.reload_timer = parseInt(reload_timer_field.text)
    if (isNaN(app.settings.predictions.reload_timer) || app.settings.predictions.reload_timer < 30) app.settings.predictions.reload_timer = 0
    app.settings.location.search_radius = parseInt(search_radius_field.text)
    app.settings.location.use_location = use_location_switch.checked
    app.settings.routing.start_time_offset = parseInt(routing_time_offset_field.text)
    app.settings.routing.preference = ["leastinterchange", "leasttime", "leastwalking"][routing_preferences_selector.currentIndex]
    app.settings.routing.modes = []
    Object.keys(route_modes).forEach(function (mode_name) { 
      if (route_modes[mode_name]) app.settings.routing.modes.push(mode_name);
    })
    app.settings.routing.request_fares = fares_switch.checked
    app.settings.routing.show_calling_points = calling_points_switch.checked
    app.settings.history.show_in_menu = history_menu_switch.checked
    switch (stop_point_sort_order_selector.currentIndex) {
      case 2:
        app.settings.sorting.order_train_stations = 1
        app.settings.sorting.order_metro_stations = 2
        app.settings.sorting.order_bus_stops = 3
        break;
      case 1:
        app.settings.sorting.order_train_stations = 1
        app.settings.sorting.order_metro_stations = 1
        app.settings.sorting.order_bus_stops = 2
        break;
      default:
        app.settings.sorting.order_train_stations = 1
        app.settings.sorting.order_metro_stations = 1
        app.settings.sorting.order_bus_stops = 1
    }
    app.settings.data_source.numbering_area = numbering_area_selector.currentIndex
    app.settings.smartwatch.reload_button = smartwatch_button_selector.currentIndex
    app.settings.smartwatch.fastest_train_alert = Boolean(smartwatch_fastest_train_selector.currentIndex === 1)
  }

  onRejected: {
    console.log("SettingsDialog rejected")
  }

  onDone: {
    console.log("SettingsDialog done")
  }

  onStatusChanged: {
    if (status === PageStatus.Active || status === PageStatus.Activating) app.active_page = 'settings'
  }
}
