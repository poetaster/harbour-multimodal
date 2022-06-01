import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
  id: routing_page

  property real latitude
  property real longitude

  property var from_stop_point
  property var to_stop_point

  property var route_journeys
  property var fares
  property bool data_requested: false

  property string title: ''
  property string page_name: ''

  property bool close_page: false

  property var journey_start_time: new Date()

  property var routing_modes: app.settings.routing.modes

  SilicaListView {
    id: list_view

    anchors.fill: parent

    PullDownMenu {
      id: pulley

      MenuItem {
        text: 'Route preferences'
        visible: true
        onClicked: {
          const routing_dialog = pageStack.push(Qt.resolvedUrl("RoutingDialog.qml"), {
            'routing_page': routing_page,
            'latitude': latitude,
            'longitude': longitude,
            'from_stop_point': from_stop_point,
            'to_stop_point': to_stop_point,
            'start_time': journey_start_time,
            'routing_modes': routing_modes,
          })
          routing_dialog.accepted.connect(function() {
            from_stop_point = routing_dialog.from_stop_point
            to_stop_point = routing_dialog.to_stop_point
            journey_start_time = routing_dialog.start_time
            routing_modes = routing_dialog.routing_modes
            data_requested = true
            python.r_get_journey(from_stop_point, to_stop_point, journey_start_time, app.settings.routing.preference, routing_modes);
            if (app.settings.routing.request_fares && from_stop_point.id.length && to_stop_point.id.length) python.r_get_fares(from_stop_point.id, to_stop_point.id);
          })
          routing_dialog.rejected.connect(routing_dialog_rejected)
        }
      }
    }

    header: Item {
      width: parent.width
      height: Theme.itemSizeMedium

      Label {
        id: departure_point_label
        text: from_stop_point.name
        truncationMode: TruncationMode.Fade
        font.pixelSize: Theme.fontSizeSmall
        anchors {
          top: parent.top
          left: parent.left
          leftMargin: Theme.paddingSmall
          topMargin: Theme.paddingMedium
        }
      }
      Label {
        id: arrival_point_label
        text: to_stop_point.name
        truncationMode: TruncationMode.Fade
        font.pixelSize: Theme.fontSizeSmall
        anchors {
          bottom: parent.bottom
          left: parent.left
          leftMargin: Theme.paddingSmall
          bottomMargin: Theme.paddingMedium
        }
      }
    }

    footer: Item {
      width: parent.width

      visible: fares && fares.length || false
      
      Column {
        id: fares_column
        width: parent.width
        spacing: Theme.paddingLarge

        SectionHeader {
          text: "Fares"
        }

        Repeater {
          id: fares_repeater
          model: fares

          Column {
            width: parent.width
            spacing: Theme.paddingSmall
            anchors {
              left: parent.left
            }

            property int fare_index: index

            Label {
              id: route_description_label
              text: modelData.route_description
              width: parent.width
              font.pixelSize: Theme.fontSizeExtraSmall
              wrapMode: Text.Wrap
              anchors {
                left: parent.left
                leftMargin: Theme.paddingSmall
              }
            }

            Column {
              id: price_column
              spacing: Theme.paddingSmall
              anchors {
                left: parent.left
                leftMargin: Theme.paddingSmall
              }
              Repeater {
                model: fares[fare_index].tickets
                Column {
                  Row {
                    Label {
                      id: ticket_time_label
                      width: routing_page.width / 2
                      font.pixelSize: Theme.fontSizeSmall
                      text: modelData.ticket_time
                    }
                    Label {
                      id: price_label
                      width: routing_page.width / 2 - mode_icon.width - Theme.paddingMedium
                      font.pixelSize: Theme.fontSizeSmall
                      text: modelData.currency + ' ' + modelData.cost
                    }
                    Image {
                      id: mode_icon
                      height: 72
                      width: 84
                      fillMode: Image.PreserveAspectFit
                      source: "../../img/" + modelData.mode.replace(/[^0-9a-z_]/gi, '') + '.svg'
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    BusyIndicator {
      anchors.centerIn: parent
      size: BusyIndicatorSize.Large
      running: data_requested
    }

    ViewPlaceholder {
      enabled: journeys_list_model.count == 0 && !data_requested
      text: "No routes"
      hintText: ""
    }

    spacing: 10

    model: ListModel {
      id: journeys_list_model
    }

    delegate: ListItem {
      id: list_item

      contentHeight: start_time_label.height + arrival_time_label.height + mode_icons_row.height + Theme.paddingLarge

      Rectangle {
        visible: index > 0
        width: parent.width
        height: 1
        color: Theme.highlightColor
        anchors {
          top: parent.top
        }
      }

      Rectangle {
        width: 10
        color: Theme.primaryColor
        anchors {
          top: start_time_label.verticalCenter
          bottom: arrival_time_label.verticalCenter
          left: parent.left
          leftMargin: 5
        }
      }

      Rectangle {
        id: start_time_rectangle
        height: 20
        width: 20
        radius: 10
        color: Theme.primaryColor
        anchors {
          verticalCenter: start_time_label.verticalCenter
          left: parent.left
        }
      }

      Label {
        id: start_time_label
        text: main_handler.parse_date(start_time).toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
        anchors {
          top: parent.top
          left: start_time_rectangle.right
          leftMargin: Theme.paddingSmall
          topMargin: Theme.paddingMedium
        }
      }

      Label {
        id: departure_point_label
        text: departure_point_name
        truncationMode: TruncationMode.Fade
        anchors {
          top: start_time_label.top
          left: start_time_label.right
          right: parent.right
          leftMargin: Theme.paddingMedium
        }
      }

      Icon {
        id: duration_icon
        height: Theme.iconSizeSmall
        width: Theme.iconSizeSmall
        anchors {
          verticalCenter: mode_icons_row.verticalCenter
          left: parent.left
          leftMargin: Theme.paddingLarge
        }
        source: "image://theme/icon-s-duration"
      }

      Label {
        id: duration_label
        text: main_handler.minutes_to_hours(duration)
        anchors {
          verticalCenter: duration_icon.verticalCenter
          left: duration_icon.right
        }
      }

      Row {
        id: mode_icons_row
        anchors {
          top: departure_point_label.bottom
          right: parent.right
        }

        Repeater {
          model: route_journeys[index] ? extract_icons(route_journeys[index].legs) : 0
          Image {
            id: mode_icon
            height: 72
            width: 84
            fillMode: Image.PreserveAspectFit
            source: "../../img/" + String(modelData) + '.svg'
            visible: Boolean(modelData)
          }
        }
      }

      Rectangle {
        id: arrival_time_rectangle
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
          top: mode_icons_row.bottom
          left: arrival_time_rectangle.right
          leftMargin: Theme.paddingSmall
        }
      }

      Label {
        id: arrval_point_label
        text: arrival_point_name
        truncationMode: TruncationMode.Fade
        anchors {
          top: arrival_time_label.top
          left: arrival_time_label.right
          right: parent.right
          leftMargin: Theme.paddingMedium
        }
      }

      onClicked: {
        console.log("Switch to JourneyPage - index:", index)
        pageStack.push(
          Qt.resolvedUrl("JourneyPage.qml"), {
            'journey': route_journeys[index],
          }
        )
      }

      Component.onCompleted: {

      }
    }

  }

  Component.onCompleted: {
    app.signal_a_get_journey.connect(process_journeys)
    app.signal_a_get_fares.connect(process_fares)

    if (!from_stop_point && latitude && longitude) {
      from_stop_point = {
        'id': '',
        'name': "Current position",
        'lat': latitude,
        'lon': longitude,
        'numbering_area': app.settings.data_source.numbering_area,
        'dataset_id': 0,
        'lines': '',
        'modes': '',
        'ask_for_settings': true,
      }
    }

    journey_start_time = new Date(journey_start_time.getTime() + app.settings.routing.start_time_offset * 60000)
    if (from_stop_point && !from_stop_point.ask_for_settings && to_stop_point) {
      data_requested = true;
      journeys_list_model.clear()
      python.r_get_journey(from_stop_point, to_stop_point, journey_start_time, app.settings.routing.preference, routing_modes);
      if (app.settings.routing.request_fares && from_stop_point.id.length) python.r_get_fares(from_stop_point.id, to_stop_point.id);

      main_handler.add_history({
        'page_name': 'RoutingPage.qml',
        'title': '⇨' + main_handler.cleanup_destination(to_stop_point.name),
        'latitude': latitude,
        'longitude': longitude,
        'from_stop_point': from_stop_point,
        'to_stop_point': to_stop_point,
      })
    }
  }

  Component.onDestruction: {
    app.signal_a_get_journey.disconnect(process_journeys)
    app.signal_a_get_fares.disconnect(process_fares)
  }

  onStatusChanged: {
    if (status === PageStatus.Active) {
      if (close_page) {
        pageStack.pop()
      }

      if (!from_stop_point || from_stop_point.ask_for_settings || !to_stop_point) {
        const routing_dialog = pageStack.push(Qt.resolvedUrl("RoutingDialog.qml"), {
          'routing_page': routing_page,
          'latitude': latitude,
          'longitude': longitude,
          'from_stop_point': from_stop_point,
          'to_stop_point': to_stop_point,
          'start_time': journey_start_time,
          'routing_modes': routing_modes,
        }, PageStackAction.Immediate)
        routing_dialog.accepted.connect(function() {
          from_stop_point = routing_dialog.from_stop_point
          to_stop_point = routing_dialog.to_stop_point
          journey_start_time = routing_dialog.start_time
          routing_modes = routing_dialog.routing_modes
          from_stop_point.ask_for_settings = false
          data_requested = true;
          journeys_list_model.clear()
          python.r_get_journey(from_stop_point, to_stop_point, journey_start_time, app.settings.routing.preference, routing_modes);
          if (app.settings.routing.request_fares && from_stop_point.id.length && to_stop_point.id.length) python.r_get_fares(from_stop_point.id, to_stop_point.id);

          main_handler.add_history({
            'page_name': 'RoutingPage.qml',
            'title': '⇨' + main_handler.cleanup_destination(to_stop_point.name),
            'latitude': latitude,
            'longitude': longitude,
            'from_stop_point': from_stop_point,
            'to_stop_point': to_stop_point,
          })
        })
        routing_dialog.rejected.connect(routing_dialog_rejected)
      }

      if (status === PageStatus.Activating) app.active_page = 'routing'
    }
  }

  function process_journeys(journeys) {
    data_requested = false
    route_journeys = journeys
    //console.log('process_journeys:', JSON.stringify(journeys))
    if (!journeys) return;
    journeys_list_model.clear()
    var fare_details = []

    for (var i=0; i<journeys.length; i++) {  
      for (var a=0; a<journeys[i].legs.length; a++) {
        if (a == 0) journeys[i].departure_point_name = journeys[i].legs[a].departure_point_name
        journeys[i].arrival_point_name = journeys[i].legs[a].arrival_point_name
      }

      if (journeys[i].fare) {
        fare_details.push(journeys[i].fare)
      }

      journeys_list_model.append(journeys[i]);
    }

    if (app.settings.routing.request_fares) fares = fare_details    
  }

  function process_fares(fare_details) {
    //console.log('process_fares:', JSON.stringify(fare_details))
    if (!fare_details) return;

    fares = fare_details
    console.log('fare details:', fare_details.length)
  }

  function extract_modes(legs) {
    var modes = []
    for (var i=0; i<legs.length; i++) {
      modes.push(legs[i].mode)
    }

    return modes
  }

  function extract_icons(legs) {
    var icons = []
    for (var i=0; i<legs.length; i++) {
      icons.push(legs[i].icon_name)
    }

    return icons
  }

  function routing_dialog_rejected() {
    console.log('routing_dialog_rejected - Route Settings not changed')
    if (!from_stop_point || !to_stop_point || from_stop_point.ask_for_settings ) {
      close_page = true
    }
  }
}
