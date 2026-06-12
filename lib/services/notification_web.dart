import 'dart:html';

Future<bool> requestNotificationPermission() async {
  final status = await Notification.requestPermission();
  return status == 'granted';
}

void showBrowserNotification(String title, String body) {
  Notification(title, body: body);
}
