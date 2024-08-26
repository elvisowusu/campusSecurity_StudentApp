// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationHandler {
//   static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     final FirebaseMessaging messaging = FirebaseMessaging.instance;

//     await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//       iOS: DarwinInitializationSettings(),
//     );

//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) async {
//         final String? payload = response.payload;
//         if (payload != null) {
//           print('Notification tapped with payload: $payload');
//           // Navigate to appropriate screen based on payload
//         }
//       },
//     );

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification?.android;

//       if (notification != null && android != null) {
//         flutterLocalNotificationsPlugin.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           NotificationDetails(
//             android: AndroidNotificationDetails(
//               'emergency_channel',
//               'Emergency Notifications',
//               channelDescription: 'This channel is used for important emergency notifications.',
//               icon: android.smallIcon,
//               sound: RawResourceAndroidNotificationSound('emergency_alert'),
//               priority: Priority.high,
//               importance: Importance.max,
//             ),
//           ),
//           payload: message.data['trackingId'],
//         );
//       }
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('A new onMessageOpenedApp event was published!');
//       // Handle notification tap when app is in background
//       // Navigate to appropriate screen based on message data
//     });
//   }
// }