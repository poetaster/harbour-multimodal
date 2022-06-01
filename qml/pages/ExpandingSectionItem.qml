import QtQuick 2.0
import Sailfish.Silica 1.0

Item { 
  id: main_item
  height: Theme.itemSizeSmall + (expanded ? content_item.height : 0)
  property alias title: name_label.text
  property bool expanded
  property alias content: content_loader

  BackgroundItem {
    id: header_item
    width: parent.width
    height: Theme.itemSizeSmall

    Rectangle {
      anchors.fill: parent
      gradient: Gradient {
        GradientStop {
          position: 0.0
          color: Theme.rgba(header_item.palette.highlightBackgroundColor, 0.1)
        }
        GradientStop {
          position: 1.0
          color: "transparent"
        }
      }
    }

    Icon {
      id: expand_icon

      anchors {
        left: parent.left
        leftMargin: Theme.paddingSmall
        verticalCenter: parent.verticalCenter
      }

      source: "image://theme/icon-m-" + (main_item.expanded ? 'down' : 'right')
      highlighted: header_item.down
    }

    Label {
      id: name_label
      font.pixelSize: Theme.fontSizeSmall
      truncationMode: TruncationMode.Fade
      anchors {
        verticalCenter: parent.verticalCenter
        left: expand_icon.right
        right: parent.right
      }
    }

    onClicked: {
      expanded = !expanded
    }
  }

  Item {
    id: content_item
    visible: main_item.expanded
    width: parent.width
    height: content_loader.height
    anchors {
      top: header_item.bottom
      left: parent.left
    }

    Loader {
      id: content_loader
      width: parent.width
      active: false
    }
  }

  onExpandedChanged: {
    if (expanded) {
      content_loader.active = true
    }
  }
}