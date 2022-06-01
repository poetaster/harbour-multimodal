import QtQuick 2.0
import Sailfish.Silica 1.0

Component {
  Rectangle {
    property var timetable_entry
    
    id: bus_predictions_widget
    height: Theme.itemSizeMedium
    color: timetable_entry.main_color

    Label {
      id: name_label
      text: timetable_entry.title
      wrapMode: Text.WordWrap
      font.pixelSize: Theme.fontSizeLarge
      color: timetable_entry.text_color
      anchors {
        top: parent.top
        topMargin: -10
        left: parent.left
        leftMargin: Theme.paddingSmall
        rightMargin: Theme.paddingSmall
      }
    }

    Label {
      id: destination_label
      text: timetable_entry.subtitle
      wrapMode: Text.WordWrap
      font.pixelSize: Theme.fontSizeExtraSmall
      truncationMode: TruncationMode.Fade
      color: timetable_entry.text_color
      anchors {
        bottom: parent.bottom
        left: parent.left
        leftMargin: Theme.paddingSmall
        rightMargin: Theme.paddingSmall
        bottomMargin: Theme.paddingSmall
        right: vehicle_id_rectangle.left
      }
    }

    Label {
      id: time_to_station_label
      text: Math.round(timetable_entry.time_to_station / 60)
      wrapMode: Text.WordWrap
      font.pixelSize: Theme.fontSizeLarge
      color: timetable_entry.text_color
      visible: Boolean(!timetable_entry.is_cancelled && timetable_entry.time_to_station)
      anchors {
        top: parent.top
        topMargin: -10
        right: parent.right
        leftMargin: Theme.paddingSmall
        rightMargin: Theme.paddingSmall
      }
    }
    
    Icon {
      id: no_realtime_label
      width: visible ? Theme.iconSizeSmall : 0
      height: width
      visible: !Boolean(timetable_entry.is_realtime_data)
      color: timetable_entry.text_color
      anchors {
        verticalCenter: time_to_station_label.verticalCenter
        right: time_to_station_label.left
        leftMargin: Theme.paddingSmall
        rightMargin: Theme.paddingSmall
      }
      source: "image://theme/icon-s-time"
    }

    Label {
      id: arrival_label
      font.pixelSize: Theme.fontSizeExtraSmall
      text: main_handler.short_time(timetable_entry.time_expected)
      color: timetable_entry.text_color
      anchors {
        bottom: vehicle_id_rectangle.top
        right: parent.right
        leftMargin: Theme.paddingSmall
        rightMargin: Theme.paddingSmall
      }
    }

    Rectangle {
      id: vehicle_id_rectangle

      visible: timetable_entry.vehicle_id_display
      width: vehicle_id_label.width
      height: vehicle_id_label.height
      anchors {
        bottom: parent.bottom
        right: parent.right
        rightMargin: Theme.paddingSmall
        bottomMargin: Theme.paddingSmall
      }
      color: "yellow"

      Label {
        id: vehicle_id_label
        font.pixelSize: Theme.fontSizeExtraSmall
        font.bold: true
        text: " " + timetable_entry.vehicle_id_display + " "
        anchors {
          bottom: parent.bottom
          right: parent.right
          rightMargin: Theme.paddingExtraSmall
          leftMargin: Theme.paddingExtraSmall
        }
        color: "black"
      }
    }
  }
}