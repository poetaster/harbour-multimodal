import QtQuick 2.2
import Sailfish.Silica 1.0

Item {
  id: self

  height: parent.height
  width: Theme.paddingLarge

  property string color

  Rectangle { 
    id: rounded_rect 
    color: self.color
    
    radius: 10
    anchors {
      left: parent.left
    }

    height: parent.height
    width: parent.width
  }

  Rectangle {  
    color: self.color
    
    anchors {
      right: rounded_rect.right
    }

    height: parent.height
    width: rounded_rect.width / 2
  }
}

