import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
  id: calling_points_page

  property bool data_requested: false
  property var stop_point
  property var timetable_entry

  property string title: ''
  property string page_name: ''

  SilicaListView {
    width: parent.width;
    height: parent.height
    clip: true

    anchors {
      fill: parent
    }

    PullDownMenu {
      id: pulley
      MenuItem {
        id: test_item
        text: "Reload"
        onClicked: {
          reload_data();
        }
      }
    }

    BusyIndicator {
      anchors.centerIn: parent
      size: BusyIndicatorSize.Large
      running: data_requested
    }

    ViewPlaceholder {
      enabled: list_model.count == 0 && !data_requested
      text: "No data"
      hintText: "No vehicle data"
    }

    header: Rectangle {
      id: header_item
      height: Theme.itemSizeSmall
      width: parent.width

      color: timetable_entry.main_color

      Rectangle {
        id: mark_rectangle
        visible: Boolean(timetable_entry.mark_color)
        width: 20
        color: String(timetable_entry.mark_color)
        anchors {
          top: parent.top
          bottom: parent.bottom
          left: parent.left
        }
      }

      Label {
        id: destination_label
        text: timetable_entry.title
        truncationMode: TruncationMode.Fade
        font.strikeout: timetable_entry.is_cancelled
        color: timetable_entry.text_color
        anchors {
          top: parent.top
          topMargin: Theme.paddingSmall
          left: mark_rectangle.right
          right: mode_icon.left
          leftMargin: Theme.paddingExtraSmall
        }
      }

      Label {
        id: line_name_label
        text: timetable_entry.subtitle
        truncationMode: TruncationMode.Fade
        font.pixelSize: Theme.fontSizeExtraSmall
        color: timetable_entry.text_color
        anchors {
          top: destination_label.bottom
          left: mark_rectangle.right
          right: carriage_icon.left
          leftMargin: Theme.paddingExtraSmall
        }
      }

      Label {
        id: platform_prefix_label
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.fontSizeExtraSmall
        text: String(timetable_entry.platform_prefix)
        visible: platform_label.visible && Boolean(timetable_entry.platform_prefix)
        color: timetable_entry.text_color
        width: visible ? contentWidth : 0
        anchors {
          bottom: parent.bottom
          right: platform_icon.left
          leftMargin: Theme.paddingSmall
          rightMargin: Theme.paddingSmall
        }
      }

      Icon {
        id: platform_icon
        width: 25
        visible: platform_label.visible
        fillMode: Image.PreserveAspectFit
        color: timetable_entry.text_color
        anchors {
          bottom: platform_label.baseline
          right: platform_label.left
          leftMargin: Theme.paddingSmall
          rightMargin: Theme.paddingSmall
        }
        source: "../../img/platform.svg"
      }

      Label {
        id: platform_label
        visible: Boolean(timetable_entry.platform_name)
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.fontSizeExtraSmall
        text: String(timetable_entry.platform_name)
        color: timetable_entry.text_color
        anchors {
          top: destination_label.bottom
          right: mode_icon.left
          leftMargin: Theme.paddingSmall
          rightMargin: Theme.paddingSmall
        }
      }

      Icon {
        id: carriage_icon
        width: visible ? 30 : 0
        visible: length_label.visible
        fillMode: Image.PreserveAspectFit
        color: timetable_entry.text_color
        anchors {
          bottom: length_label.baseline
          right: length_label.left
          leftMargin: Theme.paddingSmall
          rightMargin: Theme.paddingSmall
        }
        source: "../../img/carriage.svg"
      }

      Label {
        id: length_label
        visible: Boolean(timetable_entry.number_carriages > 0)
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.fontSizeExtraSmall
        text: String(timetable_entry.number_carriages)
        color: timetable_entry.text_color
        width: visible ? contentWidth : 0
        anchors {
          top: destination_label.bottom
          right: platform_prefix_label.left
          leftMargin: Theme.paddingSmall
          rightMargin: Theme.paddingMedium
        }
      }

      Rectangle {
        id: vehicle_id_rectangle
        visible: Boolean(timetable_entry.vehicle_id_display)
        width: visible ? vehicle_id_label.width : 0
        height: vehicle_id_label.height
        color: "yellow"

        anchors {
          verticalCenter: parent.verticalCenter
          rightMargin: Theme.paddingSmall
          right: mode_icon.left
        }

        Label {
          id: vehicle_id_label
          font.pixelSize: Theme.fontSizeExtraSmall
          font.bold: true
          text: " " + timetable_entry.vehicle_id + " "
          anchors {
            bottom: parent.bottom
            right: parent.right
            rightMargin: Theme.paddingExtraSmall
            leftMargin: Theme.paddingExtraSmall
          }
          color: "black"
        }
      }

      Image {
        id: mode_icon
        height: 72
        width: 84
        fillMode: Image.PreserveAspectFit
        source: "../../img/"+String(timetable_entry.icon_name)+".svg"
        visible: Boolean(timetable_entry.icon_name)
        anchors {
          right: parent.right
          rightMargin: Theme.paddingMedium
          verticalCenter: header_item.verticalCenter
        }
      }
    }

    footer: Item {
      height: delay_reason_label.height + cancel_reason_label.height + Theme.paddingLarge
      width: parent.width

      Icon {
        id: delay_reason_icon
        height: Theme.iconSizeSmall
        width: Theme.iconSizeSmall
        visible: Boolean(timetable_entry.delay_reason)
        anchors {
          top: parent.top
          topMargin: Theme.paddingMedium
          left: parent.left
          leftMargin: Theme.paddingMedium
        }
        source: "image://theme/icon-s-warning"
      }

      Label {
        id: delay_reason_label
        visible: Boolean(timetable_entry.delay_reason)
        text: String(timetable_entry.delay_reason)
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.fontSizeExtraSmall
        anchors {
          top: parent.top
          topMargin: Theme.paddingMedium
          left: delay_reason_icon.right
          leftMargin: Theme.paddingMedium
          right: parent.right
          rightMargin: Theme.paddingMedium
        }
      }

      Icon {
        id: cancel_reason_icon
        height: Theme.iconSizeSmall
        width: Theme.iconSizeSmall
        visible: Boolean(timetable_entry.cancel_reason)
        anchors {
          top: delay_reason_icon.bottom
          topMargin: Theme.paddingMedium
          left: parent.left
          leftMargin: Theme.paddingMedium
        }
        source: "image://theme/icon-s-filled-warning"
      }

      Label {
        id: cancel_reason_label
        visible: Boolean(timetable_entry.cancel_reason)
        text: String(timetable_entry.cancel_reason)
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.fontSizeExtraSmall
        anchors {
          top: delay_reason_label.bottom
          topMargin: Theme.paddingMedium
          left: cancel_reason_icon.right
          leftMargin: Theme.paddingMedium
          right: parent.right
          rightMargin: Theme.paddingMedium
        }
      }
    }

    section {
      property: "set_index"
      criteria: ViewSection.FullString
      delegate: Item {
        width: parent.width
        height: visible ? Theme.itemSizeExtraSmall : 0
        visible: section != "0"
        SectionHeader {
          visible: section != "0"
          text: "Dividing Train"
        }
      }
    }

    model: ListModel {
        id: list_model

        function a_get_vehicle_predictions(prediction_sets) {
          data_requested = false;
          if (typeof(prediction_sets) !== 'object') return;
          clear()
          for (var s=0; s<prediction_sets.length; s++) {
            const predictions = prediction_sets[s]
            for (var i=0; i<predictions.length; i++) {
              append(predictions[i]);
            }
          }
        }

      Component.onCompleted: update([])
    }

    spacing: 0

    delegate: ListItem {
      id: list_item
      contentHeight: Theme.itemSizeSmall

      Rectangle {
        visible: {
          return (stop_point.id && stop_point.id == model.calling_point_id) || model.is_requesting_station == true
        }
        width: parent.width - 10
        height: 1
        color: Theme.highlightColor
        anchors {
          top: parent.top
          right: parent.right
        }
      }

      Rectangle {
        visible: (stop_point.id && stop_point.id == model.calling_point_id) || model.is_requesting_station == true
        width: parent.width - 10
        height: 1
        color: Theme.highlightColor
        anchors {
          bottom: parent.bottom
          right: parent.right
        }
      }

      Rectangle {
        width: 10
        color: Theme.primaryColor
        visible: !(model.is_origin || (timetable_entry.origin_id  && timetable_entry.origin_id === model.calling_point_id) || (timetable_entry.origin_codes.indexOf(model.stop_code) !== -1 && timetable_entry.destination_codes.indexOf(model.stop_code) === -1))
        anchors {
          top: parent.top
          bottom: parent.verticalCenter
          left: parent.left
          leftMargin: 5
        }
      }

      Rectangle {
        width: 10
        color: Theme.primaryColor
        visible: !(model.is_destination || (timetable_entry.destination_id  && timetable_entry.destination_id === model.calling_point_id) || (timetable_entry.destination_codes.indexOf(model.stop_code) !== -1 && timetable_entry.origin_codes.indexOf(model.stop_code) === -1))
        anchors {
          top: parent.verticalCenter
          bottom: parent.bottom
          left: parent.left
          leftMargin: 5
        }
      }

      Rectangle {
        id: stop_circle
        height: 20
        width: 20
        radius: 10
        color: Theme.primaryColor
        anchors {
          verticalCenter: parent.verticalCenter
          left: parent.left
        }
      }

      Label {
        id: name_label
        truncationMode: TruncationMode.Fade
        font.strikeout: model.is_cancelled
        text: model.title
        anchors {
          verticalCenter: parent.verticalCenter
          left: stop_circle.left
          leftMargin: Theme.paddingLarge
        }
      }

      Label {
        id: time_to_station_label
        text: Math.round(model.time_to_station / 60)
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.fontSizeLarge
        visible: !model.is_cancelled && Boolean(model.time_to_station)
        anchors {
          top: parent.top
           right: parent.right
          leftMargin: Theme.paddingMedium
          rightMargin: Theme.paddingMedium
        }
      }

      Label {
        id: arrival_label
        visible: Boolean(model.time_expected)
        anchors {
          bottom: parent.bottom
          right: parent.right
          rightMargin: Theme.paddingMedium
        }
        font.pixelSize: Theme.fontSizeExtraSmall
        text: main_handler.short_time(model.time_expected)
      }
    }

    Component.onCompleted: {
      app.signal_a_get_vehicle_predictions.connect(list_model.a_get_vehicle_predictions)
      app.signal_reload_data.connect(reload_data)
      load_calling_points();

      main_handler.add_history({
        'page_name': 'CallingPointsPage.qml',
        'title': main_handler.short_time(timetable_entry.time_expected || timetable_entry.time_planned) + ' ' + timetable_entry.title,
        'stop_point': stop_point,
        'timetable_entry': timetable_entry,
      })
    }

    Component.onDestruction: {
      data_requested = false;
      app.signal_a_get_vehicle_predictions.disconnect(list_model.a_get_vehicle_predictions)
      app.signal_reload_data.disconnect(reload_data)
    }
  }
  

  onStatusChanged: {
    if (status === PageStatus.Active || status === PageStatus.Activating) app.active_page = 'vehicle_predictions'
  }

  function load_calling_points() {
    data_requested = true;
    if (timetable_entry.calling_points && timetable_entry.calling_points.length > 0) {
      app.signal_a_get_vehicle_predictions(timetable_entry.calling_points)
      return;
    }

    if (timetable_entry.module == 'ldbws') python.r_get_ldbws_service_details(timetable_entry.service_id, timetable_entry.origin_codes, timetable_entry.destination_codes);
    else if (timetable_entry.module == 'trest') python.r_get_trest_service_details(timetable_entry.service_id, timetable_entry.line_id);
    else python.r_get_vehicle_predictions(timetable_entry.vehicle_id, timetable_entry.line_id);
  }

  function reload_data() {
    if (app.active_page !== 'vehicle_predictions') return;
    load_calling_points()
  }
}
