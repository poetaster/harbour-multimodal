import QtQuick 2.0
import Sailfish.Silica 1.0

Component {
  ListItem {
    id: list_item

    contentHeight: Theme.itemSizeMedium
    
    highlighted: index == index_selected

    menu: ContextMenu {
      visible: true        
      MenuLabel {
        visible: Boolean(from_stop_point)
        text: from_stop_point ? "From: " + main_handler.cleanup_destination(from_stop_point.name) : ''
      }
      MenuLabel {
        visible: show_context_menu && Boolean(to_stop_point)
        text: to_stop_point ? "To: " + main_handler.cleanup_destination(to_stop_point.name) : ''
      }
      MenuItem {
        visible: show_context_menu
        text: "Route to here"
        onClicked: {
          to_stop_point = stop_points[id]

          app.settings.history.to_stop_point_id = to_stop_point.id
          app.settings.history.to_stop_point_name = to_stop_point.name
          app.settings.history.to_stop_point_code = to_stop_point.code

          pageStack.push(
            Qt.resolvedUrl("RoutingPage.qml"), {
              'latitude': pos_latitude,
              'longitude': pos_longitude,
              'from_stop_point': from_stop_point,
              'to_stop_point': to_stop_point,
            }
          )
        }
      }
      MenuItem {
        visible: show_context_menu && Boolean(!to_stop_point || to_stop_point.id !== id)
        text: "Set as destination"
        onClicked: {
          to_stop_point = stop_points[id]

          app.settings.history.to_stop_point_id = to_stop_point.id
          app.settings.history.to_stop_point_name = to_stop_point.name
          app.settings.history.to_stop_point_code = to_stop_point.code
        }
      }
      MenuItem {
        visible: show_context_menu && Boolean(!from_stop_point || from_stop_point.id !== id)
        text: "Set as starting point"
        onClicked: {
          from_stop_point = stop_points[id]

          app.settings.history.from_stop_point_id = from_stop_point.id
          app.settings.history.from_stop_point_name = from_stop_point.name
          app.settings.history.from_stop_point_code = from_stop_point.code
        }
      }
      MenuItem {
        text: "Add to favourites"
        visible: Boolean(model.saved) == false
        onClicked: {
          python.stop_point_save({
            'id': model.id,
            'stop_code': model.stop_code,
            'name': model.name,
            'lat': model.lat,
            'lon': model.lon,
            'indicator': model.indicator,
            'stop_letter': model.stop_letter,
            'fare_zone': model.fare_zone,
            'towards': model.towards,
            'heading': model.heading,
            'stop_type': model.stop_type,
            'traffic_type': model.traffic_type,
            'dataset_id': model.dataset_id,
            'numbering_area': model.numbering_area ? model.numbering_area : app.settings.data_source.numbering_area,
            'created_at': model.created_at,
            'updated_at': model.updated_at,
            'modes': model.modes,
            'lines': model.lines,
          })
        }
      }
      MenuItem {
        visible: main_handler.map_available && show_context_menu
        text: "Show on map"
        onClicked: {
          pageStack.push(
            Qt.resolvedUrl("MapPage.qml"), {
              'stop_point': stop_points[id],
            }
          )
        }
      }
      MenuItem {
        text: "Remove from favourites"
        visible: Boolean(model.saved)
        onClicked: {
          python.stop_point_delete(id)
        }
      }
      onActiveChanged: {
        console.log("Menu is:", active)
        list_update_disabled = active
      }
    }

    Rectangle {
      visible: index > 0
      width: parent.width
      height: 1
      color: Theme.highlightColor
      anchors {
        top: parent.top
      }
    }

    Row {
      id: favorites_row
      anchors {
        top: parent.top
        right: parent.right
      }
      Icon {
        id: route_icon
        height: 30
        width: 30
        source: "image://theme/icon-s-task"
        color: Boolean(to_stop_point) && to_stop_point.id == id ? Theme.highlightColor : Theme.defaultColor
        visible: (Boolean(from_stop_point) && from_stop_point.id == id) || (Boolean(to_stop_point) && to_stop_point.id == id)
      }
      Icon {
        id: favorites_icon
        height: 30
        width: 30
        source: "image://theme/icon-s-favorite"
        visible: Boolean(model.saved)
      }
    }

    Label {
      id: name_label
      anchors {
        top: parent.top
        left: parent.left
        leftMargin: Theme.paddingMedium
        right: icons_widget.left
      }
      truncationMode: TruncationMode.Fade
      fontSizeMode: Text.Fit
      minimumPixelSize: Theme.fontSizeExtraSmall
      font.pixelSize: Theme.fontSizeMedium
      text: main_handler.cleanup_destination(name)
    }

    Label {
      id: towards_label
      anchors {
        top: name_label.bottom
        left: parent.left
        leftMargin: Theme.paddingMedium
        right: distance_label.left
      }
      visible: towards.length > 0 || fare_zone.length > 0
      truncationMode: TruncationMode.Fade
      font.pixelSize: Theme.fontSizeExtraSmall
      text: towards.length > 0 ? (heading.length ? main_handler.letter_to_direction('>' + heading) : '') + towards : (fare_zone.length > 0 ? (heading.length ? main_handler.letter_to_direction('>' + heading) : '') + 'Zone: ' + fare_zone : '' )
    }
    
    Label {
      id: lines_label
      anchors {
        bottom: parent.bottom
        left: parent.left
        leftMargin: Theme.paddingMedium
        right: distance_label.left
      }
      truncationMode: TruncationMode.Fade
      font.pixelSize: Theme.fontSizeExtraSmall
      text: typeof lines !== 'undefined' ? String(lines).replace(/,/g, '·') : ''
    }

    Label {
      id: distance_label
      anchors {
        bottom: parent.bottom
        rightMargin: Theme.paddingSmall
        right: parent.right
      }
      visible: app.use_location
      truncationMode: TruncationMode.Fade
      font.pixelSize: Theme.fontSizeExtraSmall
      text: {
        var distance = main_handler.calculate_distance(pos_latitude, pos_longitude, lat, lon);
        return distance >= 1000.0 ? (distance / 1000).toFixed(1) + 'km': Math.round(distance) + "m"
      } 
    }

    ModesIconsWidget {
      id: icons_widget
      stop_numbering_area: numbering_area
      stop_dataset_id: dataset_id
      stop_modes: modes
      stop_stop_type: stop_type
      stop_stop_letter: stop_letter

      anchors {
        right: parent.right
        rightMargin: Theme.paddingMedium
        verticalCenter: parent.verticalCenter
      }
    }

    onClicked: {
      if (show_context_menu) {
        pageStack.push(
          Qt.resolvedUrl("PredictionsPage.qml"), {
            'stop_point': stop_points[id],
          }
        )
      } else {
        console.log("SELECTED INDEX: ", index);
        index_selected = index
      }
    }
  }
}