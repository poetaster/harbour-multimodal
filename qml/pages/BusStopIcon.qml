import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
  id: self
  property string stop_text: " "

  height: 74
  width: height

  Rectangle {
    id: bus_stop_icon
    height: self.height
    width: self.width
    radius: height/2
    color: "red"
    anchors.centerIn: parent
    
    Label {
      height: self.height * 0.9
      width: self.width * 0.9
      color: "white"
      fontSizeMode: Text.Fit
      horizontalAlignment: Text.AlignHCenter
      id: stop_letter_label
      text: main_handler.letter_to_direction(stop_text)
      anchors {
        centerIn: parent
      }
      font.bold: true
    }
  }
}
