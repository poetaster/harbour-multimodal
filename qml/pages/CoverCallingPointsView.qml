import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
  property var calling_points: []

  Column {
    width: parent.width
    height: parent.height
    anchors {
      top: parent.top
      topMargin: Theme.paddingSmall
      left: parent.left
    }

    spacing: 0

    Repeater {
      id: calling_points_repeater
      model: calling_points

      Item {
        width: parent.width
        height: time_to_station_label.height

        Rectangle {
          visible: modelData.is_requesting_station == true
          width: parent.width - 6
          height: 1
          color: Theme.highlightColor
          anchors {
            top: parent.top
            right: parent.right
          }
        }

        Rectangle {
          visible: modelData.is_requesting_station == true
          width: parent.width - 6
          height: 1
          color: Theme.highlightColor
          anchors {
            bottom: parent.bottom
            right: parent.right
          }
        }

        Rectangle {
          width: 6
          color: Theme.primaryColor
          visible: !Boolean(modelData.is_origin)
          anchors {
            top: parent.top
            bottom: parent.verticalCenter
            left: parent.left
            leftMargin: 3
          }
        }

        Rectangle {
          width: 6
          color: Theme.primaryColor
          visible: !Boolean(modelData.is_destination)
          anchors {
            top: parent.verticalCenter
            bottom: parent.bottom
            left: parent.left
            leftMargin: 3
          }
        }

        Rectangle {
          id: stop_circle
          height: 12
          width: 12
          radius: 6
          color: Theme.primaryColor
          anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
          }
        }

        Label {
          id: info_label
          font.pixelSize: Theme.fontSizeExtraSmall
          text: modelData.title
          truncationMode: TruncationMode.Fade
          anchors {
            verticalCenter: parent.verticalCenter
            left: stop_circle.right
            leftMargin: Theme.paddingSmall
            right: time_to_station_label.left
          }
        }

        Label {
          id: time_to_station_label
          font.pixelSize: Theme.fontSizeSmall
          text: Math.round(modelData.time_to_station / 60)
          visible: !modelData.is_cancelled && Boolean(modelData.time_to_station)
          anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: Theme.paddingSmall
          }
        }
      }
    }
  }

  Component.onCompleted: {

  }
}