import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:student_app/Dashboard/Case%20Analysis/map.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // creating instance for firebaseMessaging to allow fcm
  //creating an instance for the FlutterLocalNotification plugin
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Function to handle notification tap and navigate to MapArea
  static Future<void> onDidReceiveNotification(
      NotificationResponse notificationResponse) async {
    // Check if the notification was tapped
    if (notificationResponse.notificationResponseType ==
        NotificationResponseType.selectedNotification) {
      // Navigate to MapArea
      Get.to(() => const MapPage());
    }
  }

  //initializing the notification plugin
  static Future<void> init() async {
    //defining android initialization settings
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    //ios initialization settings
    const DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings();

    //combining android and ios initialization settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    //initializing the plugin with the specified settings
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );

    //initializing notification permission for android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // method to show an instant notification when a button is clicked
  static Future<void> showInstantNotification(String title, String body) async {
    //now to notification details
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails("channel_Id", "channel_Name",
            importance: Importance.high, priority: Priority.high),
        iOS: DarwinNotificationDetails());
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
  }

  // method to show a scheduled notification when a button is clicked
  static Future<void> showScheduledNotification(
      String title, String body, DateTime scheduledDate) async {
    //now to notification details
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails("channel_Id", "channel_Name",
            importance: Importance.high, priority: Priority.high),
        iOS: DarwinNotificationDetails());
    await flutterLocalNotificationsPlugin.zonedSchedule(0, title, body,
        tz.TZDateTime.from(scheduledDate, tz.local), platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime);
  }
}
