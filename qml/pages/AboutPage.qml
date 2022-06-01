import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
  id: about_page

  Column {
    height: parent.height
    anchors {
      top: parent.top
      right: parent.right
      left: parent.left
      topMargin: Theme.paddingLarge
    }
    Label {
      id: title_label
      anchors {
        horizontalCenter: parent.horizontalCenter
      }
      font.pixelSize: Theme.fontSizeHuge
      text: "MultiModal"
    }
    Label {
      id: version_label
      anchors {
        horizontalCenter: parent.horizontalCenter
      }
      font.pixelSize: Theme.fontSizeMedium
      text: "Version " + app.version
    }
    Label {
      id: own_copyright_label
      wrapMode: Text.WordWrap
      anchors {
        horizontalCenter: parent.horizontalCenter
      }
      font.pixelSize: Theme.fontSizeMedium
      text: "© 2017-2021"
    }
    Label {
      id: tfl_copyright_label
      wrapMode: Text.WordWrap
      anchors {
        horizontalCenter: parent.horizontalCenter
      }
      font.pixelSize: Theme.fontSizeMedium
      text: "Powered by TfL Open Data"
    }
    Label {
      id: tfgm_copyright_label
      wrapMode: Text.WordWrap
      anchors {
        horizontalCenter: parent.horizontalCenter
      }
      font.pixelSize: Theme.fontSizeMedium
      text: "Powered by TfGM data"
    }
    Label {
      id: db_copyright_label
      wrapMode: Text.WordWrap
      anchors {
        horizontalCenter: parent.horizontalCenter
      }
      font.pixelSize: Theme.fontSizeMedium
      text: "Powered by Deutsche Bahn data"
    }
    Label {
      id: crown_copyright_label
      width: parent.width
      wrapMode: Text.WordWrap
      horizontalAlignment: Text.AlignHCenter
      font.pixelSize: Theme.fontSizeMedium
      text: "Contains OS data © Crown copyright and database rights 2016"
      anchors {
        horizontalCenter: parent.horizontalCenter
      }
    }
    Label {
      id: mapbox_copyright_label
      width: parent.width
      wrapMode: Text.WordWrap
      horizontalAlignment: Text.AlignHCenter
      font.pixelSize: Theme.fontSizeMedium
      text: "© Mapbox, © OpenStreetMap"
      anchors {
        horizontalCenter: parent.horizontalCenter
      }
    }
  } 
  
  
  

  Component.onCompleted: {

  }

  Component.onDestruction: {

  }

  onStatusChanged: {
    if (status === PageStatus.Active || status === PageStatus.Activating) app.active_page = 'splash'
  }
}
