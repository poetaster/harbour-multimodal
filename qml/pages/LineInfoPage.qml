
import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
  id: page

  property string line_id: ''
  property string line_name: ''
  property string line_mode: ''

  property var route_sections: []

  SilicaFlickable {
    anchors {
      fill: parent
    }

    clip: false

    contentHeight: main_column.height + Theme.paddingLarge

    VerticalScrollDecorator {}

    Column {
      id: main_column
      spacing: Theme.paddingLarge
      width: parent.width

      PageHeader { title: line_name }

      Column {
        width: parent.width

        Repeater {
          model: route_sections

          ExpandingSectionItem {
            id: section

            property var route_stops: []

            width: main_column.width
            title: modelData.branch_name.replace(/ Rail Station| Underground Station| Tram Stop/g, "")

            content.sourceComponent: Column {
              id: content_column
              width: parent.width

              Repeater {
                model: route_stops

                Item {
                  width: content_column.width
                  height: Theme.itemSizeSmall

                  Rectangle {
                    width: 10
                    color: Theme.primaryColor
                    visible: index > 0
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
                    visible: index + 1 < route_stops.length
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
                    font.pixelSize: Theme.fontSizeMedium
                    text: main_handler.cleanup_destination(modelData.stop_point_name)
                    anchors {
                      verticalCenter: parent.verticalCenter
                      left: stop_circle.right
                      leftMargin: Theme.paddingSmall
                    }
                  }
                }
              }
            }

            Component.onCompleted: {
              route_stops = python.get_route_sequence_details(modelData.line_id, modelData.mode_id, modelData.branch_id, modelData.direction)
            }
          }
        }
      }
    }
  }
  
  Component.onCompleted: {
    route_sections = python.get_route_sequences(line_id, line_mode)
  }

  Component.onDestruction: {

  }

  onStatusChanged: {
    if (status === PageStatus.Active || status === PageStatus.Activating) app.active_page = 'line_info'
  }
}
