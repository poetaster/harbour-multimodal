import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

Dialog {
  id: stop_search_dialog

  property var search_text
  property var from_stop_point: null
  property var to_stop_point: null
  property var stop_point: null
  property real pos_latitude: 0.0
  property real pos_longitude: 0.0
  property bool show_context_menu: false
  property int index_selected: -1
  property bool list_update_disabled: false

  property bool data_requested: false

  canAccept: index_selected > -1

  Timer {
    id: input_timer
    repeat: false
    interval: 500
    running: false
    onTriggered: {
      if (search_field.text.length > 2) {
        data_requested = true
        python.r_search_stop_online('%' + search_field.text + '%');
      }
    }
  }

  SilicaFlickable {
    anchors.fill: parent

    VerticalScrollDecorator {}

    DialogHeader {
      id: dialog_header
    }

    BusyIndicator {
      anchors.centerIn: parent
      size: BusyIndicatorSize.Large
      running: data_requested
    }

    SearchField {
      id: search_field
      width: parent.width
      height: Theme.itemSizeLarge 

      anchors {
        top: dialog_header.bottom
      }

      Binding {
        target: stop_search_dialog
        property: "search_text"
        value: search_field.text.toLowerCase().trim()
      }

      onTextChanged: {
        if (search_field.text.length > 2) {
          input_timer.restart()
        }
        else {
          input_timer.stop()
          list_model.clear()
        }
      }
    }

    SilicaListView {
      width: parent.width
      
      anchors {
        top: search_field.bottom
        bottom: parent.bottom
      }
      model: list_model 
      delegate: StopPointWidget {
      
      }
    }
  }

  ListModel {
    id: list_model

    function a_search_stop(stops) {
      data_requested = false
      clear()
      for (var i = 0; i < stops.length; ++i) {
        console.log("a_search_stop name:", stops[i].name)
        append(stops[i])
      }
    }
  }

  onOpened: {
    app.signal_a_search_stop.connect(list_model.a_search_stop)
    console.log("StopSearchDialog opened")
  }

  onAccepted: {
    console.log("StopSearchDialog accepted:")
    stop_point = list_model.get(index_selected)
  }

  onRejected: {
    console.log("StopSearchDialog rejected")
  }

  onDone: {
    app.signal_a_search_stop.disconnect(list_model.a_search_stop)
    console.log("StopSearchDialog done")
  }

  onStatusChanged: {
    if (status === PageStatus.Active || status === PageStatus.Activating) app.active_page = 'stop_search_dialog'
  }
}
