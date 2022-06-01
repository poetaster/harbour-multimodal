import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
  property var stop_points: []

  Column {
    width: parent.width
    height: parent.height
    anchors {
      top: parent.top
      topMargin: Theme.paddingSmall
      left: parent.left
    }

    spacing: 5

    Repeater {
      id: stop_points_repeater
      model: stop_points

      Item {
        width: parent.width
        height: icons_widget.height

        Label {
          id: info_label
          font.pixelSize: Theme.fontSizeExtraSmall
          text: modelData.name
          truncationMode: TruncationMode.Fade
          anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: Theme.paddingSmall
            right: icons_widget.left
          }
        }

        ModesIconsWidget {
          id: icons_widget
          icon_height: 38
          height: 40
          stop_numbering_area: modelData.numbering_area
          stop_dataset_id: modelData.dataset_id
          stop_modes: modelData.modes
          stop_stop_type: modelData.stop_type
          stop_stop_letter: modelData.stop_letter

          anchors {
            right: parent.right
            rightMargin: Theme.paddingSmall
            verticalCenter: parent.verticalCenter
          }
        }
      }
    }
  }

  Component.onCompleted: {

  }
}