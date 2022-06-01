import QtQuick 2.0
import Nemo.Notifications 1.0
import Sailfish.Silica 1.0

Item {
  id: notifications_handler

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

  Notice {
    id: error_notice
    duration: Notice.Long
    text: "Error"
  }

  Component.onCompleted: {
    app.signal_error.connect(error_handler)
  }

  Component.onDestruction: {
    app.signal_error.disconnect(error_handler)
  }

  function error_handler(module_id, method_id, description) {
    console.log('error_handler - source:', module_id, method_id, 'error:', description);
    error_notice.text = description
    error_notice.show()
  }
}
