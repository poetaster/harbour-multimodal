import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
  id: page

  property bool data_requested: false

  SilicaListView {
    id: list_view

    height: parent.height
    width: parent.width

    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
    }

    currentIndex: -1

    model: ListModel {
      id: list_model
    }

    section {
      property: "mode_name"
      criteria: ViewSection.FullString
      delegate: Item {
        width: parent.width
        height: Theme.itemSizeExtraSmall
        visible: true
        Image {
          id: mode_icon
          height: 72
          width: 84
          fillMode: Image.PreserveAspectFit
          source: "../../img/" + section.replace(/[^0-9a-z]/gi, '') + '.svg'
          anchors {
            bottom: parent.bottom
            bottomMargin: Theme.paddingSmall
            right: parent.right
            rightMargin: Theme.paddingSmall
          }
        }
      }
    }

    spacing: 10

    delegate: ListItem {
      id: list_item

      contentHeight: Theme.itemSizeLarge + Theme.paddingSmall

      Timer {
        id: close_timer
        repeat: false
        running: false
        interval: 1000
        onTriggered: {
          reason_label.maximumLineCount = 1
          contentHeight = Theme.itemSizeMedium + Theme.paddingMedium
        }
      }

      menu: ContextMenu {
        visible: false        
        MenuItem {
          visible: true
          text: "More Information"
          onClicked: {
            pageStack.push(
              Qt.resolvedUrl("LineInfoPage.qml"), {
                'line_id': id,
                'line_name': name,
                'line_mode': mode_name,
              }
            )
          }
        }
      }

      Rectangle {
        anchors.fill: parent
        color: model.main_color
      }

      Rectangle {
        id: rail_rectangle
        visible: Boolean(model.mark_color)
        width: 20
        color: String(model.mark_color)
        anchors {
          top: parent.top
          bottom: parent.bottom
          left: parent.left
        }
      }

      Label {
        id: name_label
        text: name
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.fontSizeMedium
        truncationMode: TruncationMode.Fade
        color: model.text_color
        anchors {
          top: parent.top
          //topMargin: Theme.paddingSmall
          left: rail_rectangle.right
          leftMargin: Theme.paddingSmall
          right: severity_image.left
        }
      }

      Icon {
        id: severity_image
        height: Theme.iconSizeSmall
        width: Theme.iconSizeSmall
        source: severity_to_icon(default_status.statusSeverity)
        color: model.text_color
        anchors {
          top: parent.top
          topMargin: Theme.paddingSmall
          right: parent.right
          rightMargin: Theme.paddingSmall
        }
      }

      Label {
        id: severity_description_label
        text: default_status.statusSeverityDescription
        visible: default_status.statusSeverityDescription.length
        color: model.text_color
        anchors {
          top: severity_image.bottom
          //topMargin: Theme.paddingSmall
          right: parent.right
          rightMargin: Theme.paddingSmall
        }
      }

      Label {
        id: reason_label
        text: default_status.reason ? default_status.reason : ''
        visible: default_status.reason != undefined && default_status.reason.length && default_status.reason != 'https://www.nationalrail.co.uk/'
        wrapMode: Text.WordWrap
        font.pixelSize: Theme.fontSizeExtraSmall
        truncationMode: TruncationMode.Fade
        maximumLineCount: 1
        color: model.text_color
        anchors {
          top: severity_description_label.bottom
          //topMargin: Theme.paddingSmall
          left: rail_rectangle.right
          leftMargin: Theme.paddingSmall
          right: parent.right
          rightMargin: Theme.paddingSmall
        }
      }

      Icon {
        id: truncated_image
        height: Theme.iconSizeSmall
        width: Theme.iconSizeSmall
        source: 'image://theme/icon-s-unfocused-down'
        visible: reason_label.truncated
        color: model.text_color
        anchors {
          bottom: parent.bottom
          right: parent.right
        }
      }

      onClicked: {
        if (reason_label.truncated) {
          reason_label.maximumLineCount = 100
          contentHeight = Theme.itemSizeMedium + reason_label.height
        } else {
          pageStack.push(
            Qt.resolvedUrl("LineInfoPage.qml"), {
              'line_id': id,
              'line_name': name,
              'line_mode': mode_name,
            }
          )
          if (contentHeight > Theme.itemSizeMedium + Theme.paddingMedium) close_timer.restart()
        }
      }
    }
 
    ViewPlaceholder {
      enabled: list_model.count == 0
      text: "No status"
      hintText: ''
    }

    BusyIndicator {
      anchors.centerIn: parent
      size: BusyIndicatorSize.Large
      running: data_requested
    }
  }

  Component.onCompleted: {
    app.signal_a_get_disruptions.connect(a_get_disruptions)
    app.signal_a_get_mode_status.connect(a_get_mode_status)
    populate_lines()
    request_data()
  }

  Component.onDestruction: {
    app.signal_a_get_disruptions.disconnect(a_get_disruptions)
    app.signal_a_get_mode_status.disconnect(a_get_mode_status)
  }

  onStatusChanged: {
    if (status === PageStatus.Active || status === PageStatus.Activating) app.active_page = 'line_status'
  }

  function request_data() {
    data_requested = true
    python.r_get_mode_status(['national-rail','elizabeth-line','overground','tube', 'tram'])
  }

  function populate_lines() {
    var lines = python.get_lines(['national-rail','elizabeth-line','overground','tube', 'tram'])
    if (!lines) return;

    lines.sort(function(a, b){
      if (a.mode_name !== b.mode_name) return mode_to_value(a.mode_name) - mode_to_value(b.mode_name)

      if(a.name < b.name) { return -1; }
      if(a.name > b.name) { return 1; }
      return 0;
    })

    var disruptions_sig = []
    for (var i=0; i<lines.length; i++) {
      lines[i].default_status = {'statusSeverityDescription': ''}

      var colors = python.get_colors('tfl', '', lines[i].mode_name, '', lines[i].id)
      lines[i].main_color = colors[0]
      lines[i].mark_color = colors[1]
      lines[i].text_color = colors[2]

      list_model.append(lines[i])
    }
  }

  function a_get_disruptions(disruptions) {
    if (!disruptions) return;

    var disruptions_sig = []
    for (var i=0; i<disruptions.length; i++) {
      console.log('a_get_disruptions - category:', disruptions[i].category, 'type:',  disruptions[i].type, 'description:', disruptions[i].description);
      if (disruptions[i].category == "RealTime") {
        disruptions_sig.push(disruptions[i])
      }
    }
    
    if (!disruptions_sig.length) return
    disruptions_repeater.model = disruptions_sig
    panel_bottom.show()
  }

  function find_index(array, id) {
    for(var i = 0; i < array.length; i++) {
      if (array[i].id === id) return i;
    }
    return -1
  }

  function a_get_mode_status(status_entries) {
    data_requested = false
    if (!status_entries) return;

    for(var i = 0; i < list_model.rowCount(); i++) {
      const list_item = list_model.get(i);

      const index = find_index(status_entries, list_item.id)
      if (index < 0) continue;

      list_item.default_status = status_entries[index].lineStatuses[0]
    }
  }

  function severity_to_icon(status_severity) {
    const icons = [
      'image://theme/icon-s-developer',  // 0: Special Service,
      'image://theme/icon-s-blocked',  // 1: Closed,
      'image://theme/icon-s-blocked',  // 2: Suspended,
      'image://theme/icon-s-filled-warning',  // 3: Part Suspended,
      'image://theme/icon-s-filled-warning',  // 4: Planned Closure,
      'image://theme/icon-s-filled-warning',  // 5: Part Closure,
      'image://theme/icon-s-warning',  // 6: Severe Delays,
      'image://theme/icon-s-warning',  // 7: Reduced Service,
      'image://theme/icon-s-warning',  // 8: Bus Service,
      'image://theme/icon-s-duration',  // 9: Minor Delays,
      'image://theme/icon-s-checkmark',  //10: Good Service,
      'image://theme/icon-s-filled-warning',  //11: Part Closed,
      'image://theme/icon-s-warning',  //12: Exit Only,
      'image://theme/icon-s-warning',  //13: No Step Free Access,
      'image://theme/icon-s-warning',  //14: Change of frequency,
      'image://theme/icon-s-warning',  //15: Diverted,
      'image://theme/icon-s-blocked',  //16: Not Running,
      'image://theme/icon-s-warning',  //17: Issues Reported,
      'image://theme/icon-s-checkmark',  //18: No Issues,
      'image://theme/icon-s-warning',  //19: Information,
      'image://theme/icon-s-blocked',  //20: Service Closed
    ]

    return icons[status_severity] || ''
  }

  function mode_to_value(mode_name) {
    const mode_values = {
      'tube': 1,
      'overground': 2,
      'elizabeth-line': 3,
      'tram': 4,
      'national-rail': 5,
      'bus': 6, 
    }

    return (mode_values[mode_name] || 7)
  }
}
