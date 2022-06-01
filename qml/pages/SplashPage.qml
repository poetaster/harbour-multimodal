import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
  id: splash_page

  property int progress_value: 0

  Timer {
    id: progress_timer

    interval: 10
    running: true
    repeat: true
    onTriggered: {
      if (progress_value < 100) {
        progress_value++;
      } else {
        progress_timer.running = false;
        pageStack.pop();
      }
    }
  }

  Image {
    id: splash_image
    anchors.fill: parent
    source: "../../img/splash.jpg"
    fillMode: Image.PreserveAspectCrop
  }

  Column {
    height: parent.height / 4
    anchors {
      bottom: parent.bottom
      right: parent.right
      left: parent.left
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
      id: copyright_label
      anchors {
        horizontalCenter: parent.horizontalCenter
      }
      font.pixelSize: Theme.fontSizeMedium
      text: "© 2017-2022"
    }
    Image {
      id: anarchy_image
      width: copyright_label.height * 2
      height: copyright_label.height * 2
      anchors {
        horizontalCenter: parent.horizontalCenter
      }
      source: "../../img/anarchy.svg"
    }

    ProgressBar {
      width: parent.width
      anchors {
        horizontalCenter: parent.horizontalCenter
      }
      minimumValue: 0
      maximumValue: 100
      value: progress_value
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
