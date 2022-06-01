import QtQuick 2.0
import Sailfish.Silica 1.0

Component {
  Rectangle {
    property var timetable_entry

    id: train_predictions_widget
    height: Theme.itemSizeMedium

    color: timetable_entry.main_color
    property int minimal_left_margin: 5


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

    Image {
      id: mode_icon
      height: 50
      width: visible ? 45 : 0
      fillMode: Image.PreserveAspectFit
      source: timetable_entry.icon_name ? "../../img/"+String(timetable_entry.icon_name)+".svg" : ''
      visible: Boolean(timetable_entry.icon_name && (timetable_entry.module == 'dbahn' || timetable_entry.module == 'trest'))
      anchors {
        verticalCenter: destination_label.verticalCenter
        left: mark_rectangle.right
        leftMargin: minimal_left_margin
      }
    }

    Label {
      id: destination_label
      text: timetable_entry.title
      wrapMode: Text.WordWrap
      font.pixelSize: Theme.fontSizeMedium
      truncationMode: TruncationMode.Fade
      font.strikeout: Boolean(timetable_entry.is_cancelled)
      color: timetable_entry.text_color
      anchors {
        top: parent.top
        left: mode_icon.right
        rightMargin: Theme.paddingSmall
        leftMargin: mode_icon.visible ? Theme.paddingSmall : 0
        right: time_to_station_label.left
      }
    }

    Label {
      id: scheduled_label
      font.pixelSize: Theme.fontSizeExtraSmall
      visible: Boolean(timetable_entry.time_planned)
      text: main_handler.short_time(timetable_entry.time_planned)
      color: timetable_entry.text_color
      anchors {
        top: destination_label.bottom
        left: mark_rectangle.right
        leftMargin: minimal_left_margin
        rightMargin: Theme.paddingSmall
      }
    }

    Label {
      id: via_label
      font.pixelSize: Theme.fontSizeExtraSmall
      text: String(timetable_entry.via)
      visible: Boolean(timetable_entry.via)
      color: timetable_entry.text_color
      anchors {
        top: destination_label.bottom
        left: scheduled_label.right
        leftMargin: Theme.paddingSmall
        rightMargin: Theme.paddingSmall
      }
    }

    Label {
      id: name_label
      wrapMode: Text.WordWrap
      font.pixelSize: Theme.fontSizeExtraSmall
      color: timetable_entry.text_color
      text: timetable_entry.subtitle
      anchors {
        bottom: parent.bottom
        left: mark_rectangle.right
        leftMargin: minimal_left_margin
        rightMargin: Theme.paddingSmall
      }
    }

    Label {
      id: platform_prefix_label
      wrapMode: Text.WordWrap
      font.pixelSize: Theme.fontSizeExtraSmall
      text: String(timetable_entry.platform_prefix)
      visible: Boolean(timetable_entry.platform_prefix)
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
      visible: platform_label.visible
      color: timetable_entry.text_color
      fillMode: Image.PreserveAspectFit
      width: visible ? 25 : 0
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
      wrapMode: Text.WordWrap
      font.pixelSize: Theme.fontSizeExtraSmall
      text: String(timetable_entry.platform_name)
      visible: Boolean(timetable_entry.platform_name)
      width: visible ? contentWidth : 0
      color: timetable_entry.text_color
      anchors {
        bottom: parent.bottom
        right: parent.right
        leftMargin: Theme.paddingSmall
        rightMargin: Theme.paddingSmall
      }
    }

    Icon {
      id: carriage_icon
      visible: length_label.visible
      color: timetable_entry.text_color
      fillMode: Image.PreserveAspectFit
      width: visible ? 30 : 0
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
      visible: Boolean(timetable_entry.number_carriages && timetable_entry.number_carriages > 0)
      wrapMode: Text.WordWrap
      font.pixelSize: Theme.fontSizeExtraSmall
      text: String(timetable_entry.number_carriages)
      color: timetable_entry.text_color
      width: visible ? contentWidth : 0
      anchors {
        bottom: parent.bottom
        right: platform_prefix_label.left
        leftMargin: Theme.paddingSmall
        rightMargin: Theme.paddingMedium
      }
    }

    Label {
      id: time_to_station_label
      visible: Boolean(!timetable_entry.is_cancelled && timetable_entry.time_to_station)
      text: Math.round(timetable_entry.time_to_station / 60)
      wrapMode: Text.WordWrap
      font.pixelSize: Theme.fontSizeLarge
      color: timetable_entry.text_color
      anchors {
        top: parent.top
        topMargin: -10
        right: parent.right
        leftMargin: Theme.paddingSmall
        rightMargin: Theme.paddingSmall
      }
    }

    Label {
      id: arrival_label
      visible: !Boolean(timetable_entry.is_cancelled || timetable_entry.time_planned === timetable_entry.time_expected)
      font.pixelSize: Theme.fontSizeExtraSmall
      text: main_handler.short_time(timetable_entry.time_expected)
      color: timetable_entry.text_color
      anchors {
        bottom: platform_label.top
        right: parent.right
        leftMargin: Theme.paddingSmall
        rightMargin: Theme.paddingSmall
      }
    }

    Icon {
      id: fastest_train_icon
      height: Theme.iconSizeSmall
      width: Theme.iconSizeSmall
      visible: Boolean(fastest_service.length && fastest_service === timetable_entry.service_id)
      color: timetable_entry.text_color
      anchors {
        verticalCenter: no_realtime_label.verticalCenter
        right: no_realtime_label.left
        leftMargin: Theme.paddingSmall
        rightMargin: Theme.paddingSmall
      }
      source: "image://theme/icon-s-timer"
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

    Icon {
      id: cancel_reason_icon
      height: Theme.iconSizeSmall
      width: Theme.iconSizeSmall
      visible: Boolean(timetable_entry.cancel_reason)
      color: timetable_entry.text_color
      anchors {
        bottom: platform_label.top
        right: arrival_label.left
        leftMargin: Theme.paddingSmall
        rightMargin: Theme.paddingSmall
      }
      source: "image://theme/icon-s-filled-warning"
    }

    Icon {
      id: delay_reason_icon
      height: Theme.iconSizeSmall
      width: Theme.iconSizeSmall
      visible: Boolean(timetable_entry.delay_reason)
      color: timetable_entry.text_color
      anchors {
        bottom: platform_label.top
        right: cancel_reason_icon.left
        leftMargin: Theme.paddingSmall
        rightMargin: Theme.paddingSmall
      }
      source: "image://theme/icon-s-warning"
    }
  }
}