import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
  id: station_messages_page

  property var stop_point
  property var station_messages

  property string title: ''
  property string page_name: ''
  property bool data_requested: false

  SilicaListView {
    id: list_view

    anchors.fill: parent
    spacing: Theme.paddingLarge

    header: Item {
      id: header_item
      height: Theme.itemSizeLarge
      width: parent.width

      Label {
        id: stop_name_label
        text: main_handler.cleanup_destination(stop_point.name)
        truncationMode: TruncationMode.Fade
        anchors {
          verticalCenter: header_item.verticalCenter
          left: parent.left
          right: icons_widget.left
          leftMargin: Theme.paddingSmall
        }
      }
        
      ModesIconsWidget {
        id: icons_widget
        stop_numbering_area: stop_point.numbering_area
        stop_dataset_id: stop_point.dataset_id
        stop_modes: stop_point.modes
        stop_stop_type: stop_point.stop_type
        stop_stop_letter: stop_point.stop_letter

        anchors {
          right: parent.right
          rightMargin: Theme.paddingMedium
          verticalCenter: parent.verticalCenter
        }
      }
    }

    BusyIndicator {
      anchors.centerIn: parent
      size: BusyIndicatorSize.Large
      running: data_requested
    }

    ViewPlaceholder {
      enabled: messages_model.count == 0 && !data_requested
      text: "No messages"
      hintText: ""
    }

    model: ListModel {
      id: messages_model
    }

    delegate: ListItem {
      id: list_item

      contentHeight: disruption_label.height

      Icon {
        id: disruption_icon
        height: Theme.iconSizeSmall
        width: Theme.iconSizeSmall
        visible: true
        source: "image://theme/icon-s-warning"
        anchors {
          left: parent.left
          leftMargin: Theme.paddingMedium
          rightMargin: Theme.paddingSmall
          verticalCenter: disruption_label.verticalCenter
        }
      }

      LinkedLabel {
        id: disruption_label
        visible: true
        text: model.description
        wrapMode: Text.WordWrap
        defaultLinkActions: true
        font.pixelSize: Theme.fontSizeExtraSmall
        anchors {
          left: disruption_icon.right
          right: parent.right
          leftMargin: Theme.paddingSmall
          rightMargin: Theme.paddingMedium
        }
      }
      
      Component.onCompleted: {

      }
    }

  }

  Component.onCompleted: {
    process_messages(station_messages)
  }

  Component.onDestruction: {

  }

  onStatusChanged: {
    if (status === PageStatus.Active || status === PageStatus.Activating) app.active_page = 'station_messages'
  }

  function process_messages(messages) {
    data_requested = false

    console.log('process_messages:', JSON.stringify(messages))
    if (!messages) return;

    messages_model.clear()
    for (var i=0; i<messages.length; i++) {  
      messages_model.append({'description': messages[i]});
    }
  }
}
