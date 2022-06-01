import QtQuick 2.0
import Sailfish.Silica 1.0
import QtSensors 5.2

Item {
  id: cover_position_view
  property real pos_latitude: 51.50733946347199
  property real pos_longitude: -0.12764754131318562
  property real pos_accuracy: 9999

  Compass {
    id: compass
    active: cover_position_view.visible
    skipDuplicates: true
  }
  
  Label {
    id: latitude_info_label
    text: 'φ'
    anchors {
      top: parent.top
      topMargin: Theme.paddingMedium
      left: parent.left
      leftMargin: Theme.paddingMedium
    }
  }

  Label {
    id: latitude_label
    text: pos_latitude.toFixed(8)
    anchors {
      top: parent.top
      topMargin: Theme.paddingMedium
      right: parent.right
      rightMargin: Theme.paddingMedium
    }
  }

  Label {
    id: longitude_info_label
    text: 'λ'
    anchors {
      top: latitude_label.bottom
      topMargin: Theme.paddingMedium
      left: parent.left
      leftMargin: Theme.paddingMedium
    }
  }

  Label {
    id: longitude_label
    text: pos_longitude.toFixed(8)
    anchors {
      top: latitude_label.bottom
      topMargin: Theme.paddingMedium
      right: parent.right
      rightMargin: Theme.paddingMedium
    }
  }

  Label {
    id: accuracy_info_label
    text: 'Err'
    anchors {
      top: longitude_label.bottom
      topMargin: Theme.paddingMedium
      left: parent.left
      leftMargin: Theme.paddingMedium
    }
  }

  Label {
    id: accuracy_label
    text: Math.round(pos_accuracy) + ' m'
    anchors {
      top: longitude_label.bottom
      topMargin: Theme.paddingMedium
      right: parent.right
      rightMargin: Theme.paddingMedium
    }
  }

  Icon {
    id: compass_icon
    height: Theme.itemSizeMedium
    width: Theme.itemSizeMedium
    anchors {
      horizontalCenter: parent.horizontalCenter
      verticalCenter: parent.verticalCenter
    }
    source: "../../img/compass.svg"
    transformOrigin: Item.Center
    rotation: compass.reading ? compass.reading.azimuth : 0
  }

  Label {
    id: compass_label
    text: compass.reading ? compass.reading.azimuth + ' °' : ''
    anchors {
      top: compass_icon.bottom
      topMargin: Theme.paddingMedium
      horizontalCenter: parent.horizontalCenter
    }
  }

  Component.onCompleted: {

  }

  function position_update(latitude, longitude, accuracy, timestamp) {
    pos_latitude = latitude
    pos_longitude = longitude
    pos_accuracy = accuracy

    //if (page_active) draw_location();
    console.log('cover_map_view - position_update:',latitude, longitude, accuracy, timestamp)
  }

  CoverActionList {
    enabled: cover_position_view.visible
    CoverAction {
      iconSource: "image://theme/icon-m-select-all"
      onTriggered: {
        Clipboard.text = pos_latitude + ',' + pos_longitude
      }
    }
  }
}