import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _plugin.initialize(settings);
  }

  static Future<void> send(String msg) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'alerts',
        'Alerts',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _plugin.show(0, 'Sensor Alert', msg, details);
  }
}
