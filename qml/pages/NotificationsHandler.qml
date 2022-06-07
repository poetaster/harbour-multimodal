import QtQuick 2.0
import Nemo.Notifications 1.0
import Sailfish.Silica 1.0

Item {
  id: notifications_handler

  property string departure_notification_text: ''
  property int departure_notification_tts: 0
  property int departure_notification_timestamp: 0
  property int departure_notification_id

  Notification {
    id: error_notification
    appIcon: "harbour-multimodal"
    icon: "harbour-multimodal"
    isTransient: true
    expireTimeout: 3000
    appName: "MultiModal"

    onClosed: {
      console.log('notification closed - reason:', reason);
    }
  }

  Notification {
    id: departure_notification
    appIcon: "harbour-multimodal"
    appName: "MultiModal"
    expireTimeout: 3000
    urgency: Notification.Low
    onClosed: {
      console.log('departure notification closed - reason:', reason);
    }
  }


  Notice {
    id: error_notice
    duration: Notice.Long
    text: "Error"
  }

  Component.onCompleted: {
    app.signal_error.connect(error_handler)
    app.signal_a_get_predictions_fastest.connect(a_get_predictions_fastest)
  }

  Component.onDestruction: {
    app.signal_error.disconnect(error_handler)
    app.signal_a_get_predictions_fastest.disconnect(a_get_predictions_fastest)
  }

  function error_handler(module_id, method_id, description) {
    console.log('error_handler - source:', module_id, method_id, 'error:', description);
    error_notice.text = description
    error_notice.show()
  }

  function a_get_predictions_fastest(predictions) {
    if (!app.settings.smartwatch.fastest_train_alert) return;
    
    for (var i=0; i<predictions.length; i++) {
      const tts = Math.round(predictions[i].time_to_station / 60)
      const text_message = predictions[i].title + ' (' + predictions[i].subtitle + ')';
      const timestamp = Math.round(Date.now() / 1000)

      if (tts != departure_notification_tts || text_message != departure_notification_text || timestamp > departure_notification_timestamp + 300) {
        departure_notification_text = text_message;
        departure_notification_tts = tts;
        departure_notification_timestamp = timestamp;

        departure_notification.summary = tts + (tts === 1 ? ' Minute' : ' Minutes');
        departure_notification.subText = predictions[i].subtitle
        departure_notification.body = departure_notification_text;
        departure_notification.replacesId = departure_notification_id;
        departure_notification.icon = "/usr/share/harbour-multimodal/img/" + predictions[i].icon_name
        departure_notification.publish()
        departure_notification_id = departure_notification.replacesId
      }
    }
  }
}
