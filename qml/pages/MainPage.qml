import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
  id: page

  property string search_text: ''
  property bool page_init: false
  property bool page_active: app.active_page == 'main'

  property var from_stop_point
  property var to_stop_point

  property var saved_stops: []

  property bool list_update_disabled: false
  property real pos_latitude: 51.50733946347199
  property real pos_longitude: -0.12764754131318562
  property real pos_accuracy: 9999

  property var stop_points: {}

  property int page_history1: -1
  property int page_history2: -1
  property int page_history3: -1
  property int page_history4: -1
  property int page_history5: -1

  property bool show_context_menu: true
  property int index_selected: -1

  SilicaListView {
    id: list_view

    height: parent.height - (panel_bottom.expanded ? panel_bottom.visibleSize : 0)
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
    }

    clip: panel_bottom.expanded

    PullDownMenu {
      id: pulley

      MenuItem {
        text: app.page_history[page_history5] ? app.page_history[page_history5].title : ''
        visible: app.settings.history.show_in_menu && page_history5 > -1
        onClicked: {
          pageStack.push(Qt.resolvedUrl(app.page_history[page_history5].page_name), app.page_history[page_history5])
        }
      }

      MenuItem {
        text: app.page_history[page_history4] ? app.page_history[page_history4].title : ''
        visible: app.settings.history.show_in_menu && page_history4 > -1
        onClicked: {
          pageStack.push(Qt.resolvedUrl(app.page_history[page_history4].page_name), app.page_history[page_history4])
        }
      }

      MenuItem {
        text: app.page_history[page_history3] ? app.page_history[page_history3].title : ''
        visible: app.settings.history.show_in_menu && page_history3 > -1
        onClicked: {
          pageStack.push(Qt.resolvedUrl(app.page_history[page_history3].page_name), app.page_history[page_history3])
        }
      }

      MenuItem {
        text: app.page_history[page_history2] ? app.page_history[page_history2].title : ''
        visible: app.settings.history.show_in_menu && page_history2 > -1
        onClicked: {
          pageStack.push(Qt.resolvedUrl(app.page_history[page_history2].page_name), app.page_history[page_history2])
        }
      }
    
      MenuItem {
        text: app.page_history[page_history1] ? app.page_history[page_history1].title : ''
        visible: app.settings.history.show_in_menu && page_history1 > -1
        onClicked: {
          pageStack.push(Qt.resolvedUrl(app.page_history[page_history1].page_name), app.page_history[page_history1])
        }
      }
      
      MenuLabel {
        visible: app.settings.history.show_in_menu
        text: "History" 
      }

      MenuItem {
        text: "About"
        visible: false
        onClicked: {
          pageStack.push(Qt.resolvedUrl("AboutPage.qml"), {})
        }
      }
      MenuItem {
        text: "Settings"
        onClicked: {
          const settings_dialog = pageStack.push(Qt.resolvedUrl("SettingsDialog.qml"), {})
          settings_dialog.accepted.connect(settings_dialog_accepted)
        }
      }
      MenuItem {
        visible: Boolean(app.settings.data_source.numbering_area == 1)
        text: "Lines"
        onClicked: {
          pageStack.push(Qt.resolvedUrl("LineStatusPage.qml"), {})
        }
      }
      MenuItem {
        visible: main_handler.map_available
        text: "Map view"
        onClicked: {
          pageStack.push(
            Qt.resolvedUrl("MapPage.qml"), {
              'pos_latitude': pos_latitude,
              'pos_longitude': pos_longitude,
              'pos_accuracy': pos_accuracy,
            }
          )
        }
      }
      MenuItem {
        visible: true
        text: "Route"
        onClicked: {
          pageStack.push(
            Qt.resolvedUrl("RoutingPage.qml"), {
              'latitude': pos_latitude,
              'longitude': pos_longitude,
              'from_stop_point': from_stop_point,
              'to_stop_point': to_stop_point,
            }
          )
        }
      }
    }

    header: Item {
      width: parent.width
      height: search_field.height

      SearchField {
        id: search_field
        width: parent.width
        placeholderText: "Search"
        text: ""

        onTextChanged: {
          if (search_field.text.trim().length > 0) search_text = search_field.text
          else search_text = '';

          if (search_text.length > 1) python.r_search_stop('%' + search_text + '%');
          else if (search_text.length < 1) {
            list_model.default_stops();
            if (app.settings.location.use_location) request_geo_stops();
          }
        }
      }

      Icon {
        id: location_icon
        height: Theme.iconSizeSmall
        width: Theme.iconSizeSmall
        visible: app.use_location
        anchors {
          verticalCenter: parent.verticalCenter
          right: parent.right
          rightMargin: Theme.paddingMedium
        }
        source: "image://theme/icon-m-location"
        Behavior on opacity { FadeAnimator {} }
        Timer {
          id: loc_icon_timer1
          running: !pos_accuracy || pos_accuracy > app.settings.location.search_radius
          repeat: true
          interval: 2000
          onTriggered: {
            location_icon.opacity = 0.0
            loc_icon_timer2.running = true
          }
        }
        Timer {
          id: loc_icon_timer2
          running: false
          repeat: false
          interval: 990
          onTriggered: {
            location_icon.opacity = 1.0
          }
        }
      }
    }

    currentIndex: -1

    model: ListModel {
      id: list_model

      function clear_stops() {
        stop_points = {};
        clear();
      }

      function replace_stops() {
        clear_stops();
        for (var a=0; a<arguments.length; a++) {
          for (var i=0; i<arguments[a].length; i++) {
            if (stop_points[arguments[a][i].id]) continue;
            if (!arguments[a][i].lines) arguments[a][i].lines = '';
            if (!arguments[a][i].modes) arguments[a][i].modes = '';
            if (!arguments[a][i].line_ids) arguments[a][i].line_ids = '';
            stop_points[arguments[a][i].id] = arguments[a][i];
            append(arguments[a][i]);
          }
        }
      }

      function default_stops() {
        replace_stops(saved_stops)
      }

      function a_search_stop(stops) {
        if (!page_active) return;
        replace_stops(stops)
      }

      function a_geo_stops(stops) {
        if (!page_active) return;
        replace_stops(saved_stops, stops)
      }

      function a_stops_by_ids(stops) {
        saved_stops = stops;
        if (search_text.length < 1) default_stops();
      }

      function position_update(latitude, longitude, accuracy, timestamp) {
        pos_latitude = latitude
        pos_longitude = longitude
        pos_accuracy = accuracy

        if (!page_active) return;
        request_geo_stops();
      }

      Component.onCompleted: update([])
    }

    spacing: 10

    delegate: StopPointWidget {}
 
    ViewPlaceholder {
      enabled: list_model.count == 0
      text: "No stops or stations"
      hintText: search_text.length > 1 ? 'No stop or station found for this name or code' :  app.use_location ? "You can search for the stop or station name or SMS code" : 'You can search for the stop or station name or enalble location service'
    }
  }

  DockedPanel {
    id: panel_bottom

    width: parent.width
    height: disruptions_column.height
    open: false
    modal: true

    dock: Dock.Bottom

    Column {
      id: disruptions_column
      width: parent.width
      spacing: Theme.paddingLarge

      Repeater {
        id: disruptions_repeater
        //model: disruptions_sig

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
              source: "image://theme/icon-s-"+ (modelData.category == 'StatusAlert' ? "filled-" : "") +"warning"
               anchors {
                leftMargin: Theme.paddingMedium
                verticalCenter: disruption_label.verticalCenter
              }
            }

            Label {
              id: disruption_label
              width: parent.width - disruption_icon.width
              visible: true
              text: modelData.description
              wrapMode: Text.WordWrap
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
        pageStack.push(Qt.resolvedUrl("LineStatusPage.qml"), {})
      }
    }
  }

  Component.onCompleted: {
    app.signal_settings_loaded.connect(settings_loaded)
    app.signal_a_search_stop.connect(list_model.a_search_stop)
    app.signal_a_geo_stops.connect(list_model.a_geo_stops)
    app.signal_a_stops_by_ids.connect(list_model.a_stops_by_ids)
    app.signal_a_get_disruptions.connect(a_get_disruptions)
    app.signal_position_update.connect(list_model.position_update)
    app.signal_error.connect(error_handler)
  }

  Component.onDestruction: {
    app.signal_settings_loaded.disconnect(settings_loaded)
    app.signal_a_search_stop.disconnect(list_model.a_search_stop)
    app.signal_a_geo_stops.disconnect(list_model.a_geo_stops)
    app.signal_a_stops_by_ids.disconnect(list_model.a_stops_by_ids)
    app.signal_a_get_disruptions.disconnect(a_get_disruptions)
    app.signal_position_update.disconnect(list_model.position_update)
    app.signal_error.disconnect(error_handler)
  }

  onStatusChanged: {
    if (status === PageStatus.Active || status === PageStatus.Activating) app.active_page = 'main'
    if (status === PageStatus.Active) {
      var history = main_handler.get_history(5)
      page_history1 = history[0]
      page_history2 = history[1]
      page_history3 = history[2]
      page_history4 = history[3]
      page_history5 = history[4]
    }
  }

  function settings_loaded() {
    if (app.settings.general.program_version != app.version) {
      app.settings.general.program_version = app.version;
      pageStack.push(Qt.resolvedUrl("SplashPage.qml"), {}, PageStackAction.Immediate)
    }

    //python.r_get_disruptions(['national-rail','tflrail','overground','tube'])

    if (app.settings.history.to_stop_point_id.length) to_stop_point = python.get_stop_by_id(app.settings.history.to_stop_point_id)
    if (app.settings.history.from_stop_point_id.length) from_stop_point = python.get_stop_by_id(app.settings.history.from_stop_point_id)
  }

  function error_handler(module_id, method_id, description) {
    
  }

  function settings_dialog_accepted() {
    app.use_location = app.settings.location.use_location
    python.save_settings();
  }

  function request_geo_stops() {
    var p = main_handler.bounding_box(pos_latitude, pos_longitude, app.settings.location.search_radius) 
    console.log('request_geo_stops - bounding box:', p, 'distance:', main_handler.calculate_distance(p[0],p[1],p[2],p[3]))
    if (search_text.length < 1 && !list_update_disabled) python.r_geo_stops(p[0],p[1],p[2],p[3]);

    if (search_text.length < 1 && !list_update_disabled) python.r_geo_stops(p[0],p[1],p[2],p[3]);
  }

  function a_get_disruptions(disruptions) {
    if (!disruptions) return;

    var disruptions_sig = []
    for (var i=0; i<disruptions.length; i++) {
      console.log('a_get_disruptions - category:', disruptions[i].category, 'type:',  disruptions[i].type, 'description:', disruptions[i].description);
      if (disruptions[i].category == "RealTime") {
        disruptions_sig.push(disruptions[i])
      }
    }
    
    if (!disruptions_sig.length) return
    disruptions_repeater.model = disruptions_sig
    panel_bottom.show()
  }
}
