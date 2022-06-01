import QtQuick 2.0
import Sailfish.Silica 1.0
import MapboxMap 1.0
import QtPositioning 5.3

Item {
  property real pos_latitude: 51.50733946347199
  property real pos_longitude: -0.12764754131318562
  property real pos_accuracy: 9999
  
  MapboxMap {
    id: map
    anchors.fill: parent

    center: QtPositioning.coordinate(pos_latitude, pos_longitude)
    zoomLevel: 14.0
    minimumZoomLevel: 0
    maximumZoomLevel: 20
    pixelRatio: 3.0

    accessToken: app.settings._default_keys.mapbox_key
    cacheDatabaseMaximalSize: 1024*1024*1024
    cacheDatabasePath: app.settings._paths.map_cache_database

    styleUrl: Theme.colorScheme === Theme.DarkOnLight ? 'mapbox://styles/mapbox/light-v10' : 'mapbox://styles/mapbox/dark-v10'
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
}