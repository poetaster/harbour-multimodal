import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
  property int stop_numbering_area: 0
  property int stop_dataset_id: 0
  property string stop_modes: ''
  property string stop_stop_letter: ''
  property int stop_stop_type: 0
  property int icon_height: 72
  width: icons_row.width

  Row {
    id: icons_row
    height: icon_height

    anchors {
      right: parent.right
      verticalCenter: parent.verticalCenter
    }

    BusStopIcon {
      id: bus_stop_icon
      height: parent.height
      stop_text: stop_stop_letter
      visible: stop_numbering_area != 2 && String(stop_modes).indexOf('bus') !== -1 && String(stop_modes).indexOf('river-bus') === -1
    }
    
    Image {
      id: bus_icon
      height: parent.height
      fillMode: Image.PreserveAspectFit
      source: "../../img/de_bus.svg"
      visible: stop_numbering_area == 2 && String(stop_modes).indexOf('bus') !== -1
    }

    Image {
      id: tube_icon
      height: parent.height
      fillMode: Image.PreserveAspectFit
      source: stop_numbering_area == 2 ? "../../img/de_u.svg" : "../../img/tube.svg"
      visible: String(stop_modes).indexOf('tube') !== -1 || String(stop_modes).indexOf('subway') !== -1
    }

    Image {
      id: dlr_icon
      height: parent.height
      fillMode: Image.PreserveAspectFit
      source: "../../img/dlr.svg"
      visible: String(stop_modes).indexOf('dlr') !== -1
    }

    Image {
      id: overground_icon
      height: parent.height
      fillMode: Image.PreserveAspectFit
      source: stop_numbering_area == 2 ? "../../img/de_s.svg" : "../../img/overground.svg"
      visible: String(stop_modes).indexOf('overground') !== -1 || String(stop_modes).indexOf('suburban') !== -1
    }

    Image {
      id: elizabeth_icon
      height: parent.height
      fillMode: Image.PreserveAspectFit
      source: "../../img/elizabethline.svg"
      visible: String(stop_modes).indexOf('elizabeth') !== -1
    }

    Image {
      id: tflrail_icon
      height: parent.height
      fillMode: Image.PreserveAspectFit
      source: "../../img/tflrail.svg"
      visible: false //String(stop_modes).indexOf('tflrail') !== -1
    }

    Image {
      id: tram_icon
      height: parent.height
      fillMode: Image.PreserveAspectFit
      source: stop_numbering_area == 2 ? "../../img/de_str.svg" : (stop_dataset_id == 5 ? "../../img/metrolink_tram.svg" : "../../img/tram.svg")
      visible: String(stop_modes).indexOf('tram') !== -1
    }

    Image {
      id: river_icon
      height: parent.height
      fillMode: Image.PreserveAspectFit
      source: "../../img/river.svg"
      visible: String(stop_modes).indexOf('river-bus') !== -1
    }

    Image {
      id: nationalrail_icon
      height: parent.height
      fillMode: Image.PreserveAspectFit
      source: stop_numbering_area == 2 ? "../../img/train.svg" : "../../img/nationalrail.svg"
      visible: (String(stop_modes).indexOf('national-rail') !== -1) || stop_stop_type === 10 || String(stop_modes).indexOf('regional') !== -1 || String(stop_modes).indexOf('national') !== -1
    }
  }
}