import QtQuick 2.0
import org.nemomobile.dbus 2.0

Item {
  property string watch_notification_text: ''
  property int watch_notification_tts: 0
  property int watch_notification_timestamp: 0

  DBusInterface {
    id: amazfish_signal

    bus: DBus.SessionBus
    service: "uk.co.piggz.amazfish"
    path: "/application"
    iface: "uk.co.piggz.amazfish"

    signalsEnabled: true

    function buttonPressed(b_presses) {
      console.log("watch button presses:", b_presses)
      if (b_presses === app.settings.smartwatch.reload_button) app.signal_reload_data()
    }

    function send_alert(subject, text) {
      typedCall("sendAlert", [{"type": "s", "value": "MultiModal"}, {"type": "s", "value": subject}, {"type": "s", "value": text}, {"type": "b", "value": true}], 
        function(result) {
          console.log("send_alert result:", result)
        },
        function() {
          console.log("ERROR sending alert to watch")
        }
      )
    }
  }

  Component.onCompleted: {
    app.signal_a_get_predictions_fastest.connect(a_get_predictions_fastest)
  }

  Component.onDestruction: {
    app.signal_a_get_predictions_fastest.disconnect(a_get_predictions_fastest)
  }

function a_get_predictions_fastest(predictions) {
    if (!app.settings.smartwatch.fastest_train_alert) return;
    
    for (var i=0; i<predictions.length; i++) {
      const tts = Math.round(predictions[i].timeToStation / 60)
      const text_message = main_handler.cleanup_destination(predictions[i].destinationName) + ' (' + predictions[i].lineName + ')';
      const timestamp = Math.round(Date.now() / 1000)

      if (tts != watch_notification_tts || text_message != watch_notification_text || timestamp > watch_notification_timestamp + 300) {
        watch_notification_text = text_message;
        watch_notification_tts = tts;
        watch_notification_timestamp = timestamp;
        amazfish_signal.send_alert(tts + (tts === 1 ? ' Minute' : ' Minutes'), watch_notification_text);
      }
    }
  }
}
