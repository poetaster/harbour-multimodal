import QtQuick 2.0
import Sailfish.Silica 1.0
import MapboxMap 1.0
import QtPositioning 5.3

Page 
{
  id: map_page

  property real pos_latitude: 51.50733946347199
  property real pos_longitude: -0.12764754131318562
  property real pos_accuracy: 9999

  property bool stops_requested: false

  property var low_zoom_modes: ['national-rail', 'tflrail']
  property var medium_zoom_modes: ['national-rail', 'tflrail', 'overground', 'tube', 'dlr']
  property var high_zoom_modes: ['national-rail', 'tflrail', 'overground', 'tube', 'dlr', 'tram', 'bus']

  //2 = Bus Stop, 4 = Tram stop, 6 = Light Rail station, 8 = metro station, 10 = rail station
  property var low_zoom_stop_types: [10]
  property var medium_zoom_stop_types: [4, 6, 8, 10]
  property var high_zoom_stop_types: [2, 4, 6, 8, 10]

  property bool follow_location: false
  property bool page_active: app.active_page == 'map'
  property var stop_point
  property var last_bounding_box

  Timer {
    id: request_stops_timer
    interval: 500
    running: false
    repeat: false
    onTriggered: {
      request_stops()
    }
  }

  DockedPanel {
    id: panel_top

    width: parent.width
    height: Theme.itemSizeMedium + Theme.paddingSmall
    open: Boolean(stop_point)
    dock: Dock.Top

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
      text: stop_point ? stop_point.name : ''
    }

    Label {
      id: towards_label
      anchors {
        top: name_label.bottom
        left: parent.left
        leftMargin: Theme.paddingMedium
        right: distance_label.left
      }
      visible: stop_point ? (stop_point.towards.length > 0 || stop_point.fare_zone.length > 0) : ''
      truncationMode: TruncationMode.Fade
      font.pixelSize: Theme.fontSizeExtraSmall
      text: stop_point ? (stop_point.towards.length > 0 ? (stop_point.heading.length ? main_handler.letter_to_direction('>' + stop_point.heading) : '') + stop_point.towards : (stop_point.fare_zone.length > 0 ? (stop_point.heading.length ? main_handler.letter_to_direction('>' + stop_point.heading) : '') + 'Zone: ' + stop_point.fare_zone : '' )) : ''
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
      text: stop_point ? stop_point.lines.replace(/,/g, '·') : ''
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
        if (!stop_point) return '';
        const distance = main_handler.calculate_distance(pos_latitude, pos_longitude, stop_point.lat, stop_point.lon);
        return distance >= 1000.0 ? (distance / 1000).toFixed(1) + 'km': Math.round(distance) + "m"
      } 
    }

    ModesIconsWidget {
      id: icons_widget
      stop_numbering_area: stop_point ? stop_point.numbering_area : 0
      stop_dataset_id: stop_point ? stop_point.dataset_id : 0
      stop_modes: stop_point ? stop_point.modes : ''
      stop_stop_type: stop_point ? stop_point.stop_type : 0
      stop_stop_letter: stop_point ? stop_point.stop_letter : ''

      anchors {
        right: parent.right
        rightMargin: Theme.paddingMedium
        verticalCenter: parent.verticalCenter
      }
    }
  }

  MouseArea {
    width: panel_top.width
    height: panel_top.height
    onClicked: {
      pageStack.push(
        Qt.resolvedUrl("PredictionsPage.qml"), {
          'stop_point': stop_point
        }
      )
    }
  }

  DockedPanel {
    id: panel_bottom

    width: parent.width
    height: Theme.itemSizeLarge

    dock: Dock.Bottom

    Row {
      anchors {
        top: parent.top
      }
    }
  }

  SilicaFlickable {
    clip: panel_top.expanded

    height: parent.height - panel_top.height - panel_bottom.height
    width: parent.width

    anchors {
      top: panel_top.bottom
      bottom: panel_bottom.top
      topMargin: panel_top.margin
      bottomMargin: panel_bottom.margin
    }

    MapboxMap {
      id: map
      width: parent.width
      anchors {
        fill: parent
      }

      center: QtPositioning.coordinate(51.50733946347199, -0.12764754131318562)
      zoomLevel: 14.0
      minimumZoomLevel: 0
      maximumZoomLevel: 20
      pixelRatio: 3.0

      accessToken: app.settings._default_keys.mapbox_key
      cacheDatabaseMaximalSize: 1024*1024*1024
      cacheDatabasePath: app.settings._paths.map_cache_database

      styleUrl: Theme.colorScheme === Theme.DarkOnLight ? 'mapbox://styles/mapbox/light-v10' : 'mapbox://styles/mapbox/dark-v10'
    
      MapboxMapGestureArea {
        map: map

        activeClickedGeo: true
        activeDoubleClickedGeo: true
        activePressAndHoldGeo: true

        onClicked: {
          console.log("Click:", mouse.y, 't:', panel_top.height, 'b:', map.height - panel_bottom.height)

          if (mouse.y < panel_top.height) {
            stop_point = undefined
          } else if (mouse.y > map.height - panel_bottom.height) {
            //Bottom pannel disabled, left in for future use
            //panel_bottom.open = !panel_bottom.open
          }
        }
  
        onPressAndHold: console.log("Press and hold: ", mouse.x, mouse.y)

        onDoubleClicked: {
          console.log("Double click: ", mouse.x, mouse.y)
          position_marker_item.visible = !position_marker_item.visible
          if (!position_marker_item.visible) stop_point = null
        }

        onClickedGeo: {
          console.log("Click geo: " + geocoordinate + " sensitivity: " + degLatPerPixel + " " + degLonPerPixel)
          request_stop(geocoordinate.latitude, geocoordinate.longitude)
        }
        onDoubleClickedGeo: {
          console.log("DoubleClick geo: " + geocoordinate + " sensitivity: " + degLatPerPixel + " " + degLonPerPixel)
        }
        onPressAndHoldGeo: {
          
        }
      }

      onCenterChanged: {
        request_stops_timer.restart()
      }
      onZoomLevelChanged: {
        request_stops_timer.restart()
        app.settings.history.map_zoom = map.zoomLevel
      }
    }

    Rectangle {                                                         
      id: position_marker_item                                   
      anchors {
        right: parent.right
        bottom: parent.bottom
        rightMargin: Theme.paddingLarge
        bottomMargin: Theme.paddingLarge
      }      

      color: "lightgrey"
      width: Theme.itemSizeSmall
      height: width                                                                                                                                          
      radius: width/2

      Rectangle {
        height: position_marker_item.height * 0.63
        width: height
        radius: width/2
        color: "grey"
        anchors.centerIn: parent
      }

      Rectangle {
        height: position_marker_item.height * 0.3
        width: height
        radius: width/2
        color: follow_location ? "green" : "blue"
        anchors.centerIn: parent
      }

      MouseArea {
        anchors.fill: parent
        onClicked: {
          follow_location = !follow_location
          if (follow_location) {
            map.center = QtPositioning.coordinate(pos_latitude, pos_longitude)
            map.setPaintProperty("location", "circle-color", "green")
          } else {
            map.setPaintProperty("location", "circle-color", "blue")
          }
        }
      }                                                                                                                                         
    } 




  }

  Component.onCompleted: {
    app.signal_position_update.connect(position_update)
    app.signal_a_geo_stops.connect(a_geo_stops)
    app.signal_a_geo_stop.connect(a_geo_stop)

    if (stop_point) map.center = QtPositioning.coordinate(stop_point.lat, stop_point.lon)
    else map.center = QtPositioning.coordinate(pos_latitude, pos_longitude)

    if (!(app.settings.history.map_zoom >= map.minimumZoomLevel && app.settings.history.map_zoom <= map.maximumZoomLevel)) app.settings.history.map_zoom = 14
    map.zoomLevel = app.settings.history.map_zoom
    create_stop_layers()
    create_position_layer()
  }

  Component.onDestruction: {
    app.signal_position_update.disconnect(position_update)
    app.signal_a_geo_stops.disconnect(a_geo_stops)
    app.signal_a_geo_stop.disconnect(a_geo_stop)
  }

  onStatusChanged: {
    if (status === PageStatus.Active || status === PageStatus.Activating) app.active_page = 'map'
  }

  function modes_by_zoom() {
    if (map.zoomLevel < 8.0) const modes = low_zoom_modes;
    else if (map.zoomLevel < 13.0) const modes = medium_zoom_modes;
    else const modes = high_zoom_modes
    return modes
  }

  function stop_types_by_zoom() {
    if (map.zoomLevel < 8.0) return low_zoom_stop_types;
    else if (map.zoomLevel < 13.0) return medium_zoom_stop_types;
    return high_zoom_stop_types;
  }

  function create_map_circle(latitude, longitude, radius) {
    const angles = 20;
    var coordinate_pairs = [];
    for(var i=0; i<angles; i++) {
      coordinate_pairs.push([longitude + (radius/(111320 * Math.cos(latitude * Math.PI / 180)) * Math.cos((i / angles) * (2* Math.PI))), latitude + (radius/110574 * Math.sin((i/angles) * (2 * Math.PI)))]);
    }
    coordinate_pairs.push(coordinate_pairs[0]);

    return {
      "type": "geojson",
      "data": {
        "type": "FeatureCollection",
        "features": [{
          "type": "Feature",
          "geometry": {
            "type": "Polygon",
            "coordinates": [coordinate_pairs]
          }
        }]
      }
    }
  }

  function request_stop(latitude, longitude) {
    const p = main_handler.bounding_box(latitude, longitude, 50 * map.metersPerPixel, 50 * map.metersPerPixel)
    console.log('request_stop - bounding box:', p, 'distance:', main_handler.calculate_distance(p[0],p[1],p[2],p[3]))
    python.r_geo_stop_types(p[0],p[1],p[2],p[3], stop_types_by_zoom());
  }

  function request_stops() {
    if (stops_requested) return;

    var p = bounding_box();
    console.log('request_stops - bounding box:', p, 'distance:', main_handler.calculate_distance(p[0],p[1],p[2],p[3]))
  
    last_bounding_box = p;
    stops_requested = true;
    python.r_geo_stops_types(p[0],p[1],p[2],p[3], stop_types_by_zoom());
  }

  function a_geo_stop(stop) {
    if (!stop) return;
    stop_point = stop
    position_marker_item.visible = true
  }

  function a_geo_stops(stops) {
    stops_requested = false;
    update_stops(stops);
  }

  function create_position_layer() {
    map.addSource("location",
    {"type": "geojson",
      "data": {
        "type": "Feature",
        "properties": { "name": "location" },
        "geometry": {
          "type": "Point",
          "coordinates": [(pos_longitude),(pos_latitude)]
        }
      }
    })

    map.addLayer("location-case", {"type": "circle", "source": "location"})
    map.setPaintProperty("location-case", "circle-radius", 10)
    map.setPaintProperty("location-case", "circle-color", "white")

    map.addLayer("location", {"type": "circle", "source": "location"})
    map.setPaintProperty("location", "circle-radius", 5)
    map.setPaintProperty("location", "circle-color", "blue")

    map.addSource("accuracy_circle", create_map_circle(pos_latitude, pos_longitude, pos_accuracy));
    map.addLayer("accuracy_layer", {"type": "fill", "source": "accuracy_circle"});
    map.setPaintProperty("accuracy_layer", "fill-color", "#87cefa")
    map.setPaintProperty("accuracy_layer", "fill-opacity", "0.25")
  }

  function position_update(latitude, longitude, accuracy, timestamp) {
    pos_latitude = latitude
    pos_longitude = longitude
    pos_accuracy = accuracy

    if (page_active) draw_location();
    console.log('position_update:',latitude, longitude, accuracy, timestamp)
  }

  function bounding_box(latitude, longitude) {
    if (latitude === undefined) latitude = map.center.latitude;
    if (longitude === undefined) longitude = map.center.longitude;
    return main_handler.bounding_box(latitude, longitude, map.height * map.metersPerPixel * 1, map.width * map.metersPerPixel * 1)
  }

  function draw_location() {
    map.updateSource("location",
    {"type": "geojson",
      "data": {
        "type": "Feature",
        "properties": { "name": "location" },
        "geometry": {
          "type": "Point",
          "coordinates": [(pos_longitude),(pos_latitude)]
        }
      }
    })
    map.updateSource("accuracy_circle", create_map_circle(pos_latitude, pos_longitude, pos_accuracy));

    if (follow_location) map.center = QtPositioning.coordinate(pos_latitude, pos_longitude)
  }

  function update_stops(stop_points) {
    var bus_stops_locations = []
    var bus_stops_names = []
    var bus_stops_letters = []
    var metro_stations_locations = []
    var metro_stations_names = []
    var train_stations_locations = []
    var train_stations_names = []
    for (var i=0; i<stop_points.length; i++) {
      
      if (stop_points[i]['stop_type'] == 2) {
        bus_stops_locations.push(QtPositioning.coordinate(stop_points[i]['lat'], stop_points[i]['lon']));
        bus_stops_names.push(main_handler.cleanup_destination(stop_points[i]['name']))
        bus_stops_letters.push(main_handler.letter_to_direction(stop_points[i]['stop_letter']))
      } else if (stop_points[i]['stop_type'] == 4 || stop_points[i]['stop_type'] == 6 || stop_points[i]['stop_type'] == 8) {
        metro_stations_locations.push(QtPositioning.coordinate(stop_points[i]['lat'], stop_points[i]['lon']));
        metro_stations_names.push(main_handler.cleanup_destination(stop_points[i]['name']))
        print('STOP:', stop_points[i]['name'], 'type:', stop_points[i]['stop_type'])
      } else {
        train_stations_locations.push(QtPositioning.coordinate(stop_points[i]['lat'], stop_points[i]['lon']));
        train_stations_names.push(main_handler.cleanup_destination(stop_points[i]['name']))
      }
    }

    map.addSourcePoints("bus_stops", bus_stops_locations, bus_stops_letters)
    map.addSourcePoints("metro_stations", metro_stations_locations, metro_stations_names)
    map.addSourcePoints("train_stations", train_stations_locations, train_stations_names)
  }

  function create_stop_layers(stop_points) {
    map.addLayer("bus_stops_layer", {"type": "circle", "source": "bus_stops"})
    map.setPaintProperty("bus_stops_layer", "circle-radius", 10)
    map.setPaintProperty("bus_stops_layer", "circle-color", "red")

    map.addLayer("bus_stops_label", {"type": "symbol", "source": "bus_stops"})
    map.setLayoutProperty("bus_stops_label", "text-field", "{name}")
    map.setLayoutProperty("bus_stops_label", "text-justify", "center")
    map.setLayoutProperty("bus_stops_label", "text-anchor", "center")
    map.setPaintProperty("bus_stops_label", "text-color", "white")

    map.addLayer("metro_stations_layer", {"type": "circle", "source": "metro_stations"})
    map.setPaintProperty("metro_stations_layer", "circle-radius", 10)
    map.setPaintProperty("metro_stations_layer", "circle-color", "blue")

    map.addLayer("metro_stations_label", {"type": "symbol", "source": "metro_stations"})
    map.setLayoutProperty("metro_stations_label", "text-field", "{name}")
    map.setLayoutProperty("metro_stations_label", "text-justify", "left")
    map.setLayoutProperty("metro_stations_label", "text-anchor", "top-left")
    map.setPaintProperty("metro_stations_label", "text-color", "white")
    map.setPaintProperty("metro_stations_label", "text-halo-color", "black")
    map.setPaintProperty("metro_stations_label", "text-halo-width", 1)

    map.addLayer("train_stations_layer", {"type": "circle", "source": "train_stations"})
    map.setPaintProperty("train_stations_layer", "circle-radius", 10)
    map.setPaintProperty("train_stations_layer", "circle-color", "lightgrey")

    map.addLayer("train_stations_label", {"type": "symbol", "source": "train_stations"})
    map.setLayoutProperty("train_stations_label", "text-field", "{name}")
    map.setLayoutProperty("train_stations_label", "text-justify", "left")
    map.setLayoutProperty("train_stations_label", "text-anchor", "top-left")
    map.setPaintProperty("train_stations_label", "text-color", "white")
    map.setPaintProperty("train_stations_label", "text-halo-color", "black")
    map.setPaintProperty("train_stations_label", "text-halo-width", 1)
  }
}