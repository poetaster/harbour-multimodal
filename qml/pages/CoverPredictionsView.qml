import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
  property var predictions: []

  Column {
    width: parent.width
    height: parent.height
    anchors {
      top: parent.top
      topMargin: Theme.paddingSmall
      left: parent.left
    }

    spacing: 2

    Repeater {
      id: predictions_repeater
      model: predictions

      Item {
        width: parent.width
        height: time_to_station_label.height

        Rectangle {
          id: main_rectangle
          visible: true
          width: parent.width
          color: modelData.main_color
          anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
          }
        }

        Rectangle {
          id: mark_rectangle
          visible: Boolean(modelData.mark_color)
          width: 10
          color: String(modelData.mark_color)
          anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
          }
        }

        Label {
          id: info_label
          font.pixelSize: Theme.fontSizeExtraSmall
          text: modelData.title
          truncationMode: TruncationMode.Fade
          color: modelData.text_color
          font.strikeout:Boolean(modelData.cancelled || modelData.ldbws_cancelled)
          anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: Theme.paddingSmall
            right: time_to_station_label.left
          }
        }

        Label {
          id: time_to_station_label
          font.pixelSize: Theme.fontSizeSmall
          text: Math.round(modelData.time_to_station / 60)
          visible: Boolean(!modelData.is_cancelled && modelData.time_to_station)
          color: modelData.text_color
          anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: Theme.paddingSmall
          }
        }

        Icon {
          id: fastest_train_image
          height: Theme.iconSizeExtraSmall
          width: Theme.iconSizeExtraSmall
          visible: Boolean(fastest_service.length && fastest_service === modelData.service_id)
          color: modelData.text_color
          anchors {
            verticalCenter: time_to_station_label.verticalCenter
            right: time_to_station_label.left
          }
          source: "image://theme/icon-s-timer"
        }
      }
    }
  }

  Component.onCompleted: {

  }
}