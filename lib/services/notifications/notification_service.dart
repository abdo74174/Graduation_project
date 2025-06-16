import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/screens/product_page.dart';
import 'package:path_provider/path_provider.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final Dio _dio = Dio();
  final BuildContext context;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationService(this.context);

  Future<void> initNotifications() async {
    // Initialize logging
    await _initLogging();

    // Request permission for notifications
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await _log(
        'Notification permission requested: ${settings.authorizationStatus}');

    // Initialize local notifications
    await _initLocalNotifications();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _messaging.getToken();
      await _log('Device Token: $token');

      if (token != null) {
        try {
          final userId = 14; // Fallback to 14 if no user ID
          await _dio.post(
            "${baseUri}notification/register",
            data: {
              "token": token,
              "userId": userId,
            },
          );
          await _log('Token sent to server successfully');
        } catch (e) {
          await _log('Error sending token: $e');
        }
      }
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _log(
          'Foreground Message Received: ${message.notification?.title}, Body: ${message.notification?.body}, Data: ${message.data}');
      if (message.notification != null) {
        // Show local notification
        await _showLocalNotification(message);
        // Show SnackBar
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "${message.notification?.title}: ${message.notification?.body}"),
              action: SnackBarAction(
                label: 'View',
                onPressed: () {
                  _handleNotificationNavigation(message);
                },
              ),
            ),
          );
        }
      }
    });

    // Handle background/terminated notifications when tapped
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await _log(
          'Notification Opened: ${message.messageId}, Data: ${message.data}');
      _handleNotificationNavigation(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Check if app was opened via notification
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      await _log(
          'Initial Message: ${initialMessage.messageId}, Data: ${initialMessage.data}');
      _handleNotificationNavigation(initialMessage);
    }

    // Log token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      await _log('Token Refreshed: $newToken');
      try {
        final userId = 14;
        await _dio.post(
          "${baseUri}notification/register",
          data: {
            "token": newToken,
            "userId": userId,
          },
        );
        await _log('New token sent to server successfully');
      } catch (e) {
        await _log('Error sending new token: $e');
      }
    });
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/notification_icon');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        await _log('Local Notification Tapped: ${response.payload}');
        if (response.payload != null) {
          final productId = response.payload;
          await _navigateToProduct(productId!);
        }
      },
    );
    await _log('Local notifications initialized');
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.messageId.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: message.data['product_id'],
    );
    await _log('Local notification shown: ${message.notification?.title}');
  }

  Future<void> _handleNotificationNavigation(RemoteMessage message) async {
    final productId = message.data['product_id'];
    if (productId != null) {
      await _navigateToProduct(productId);
    }
  }

  Future<void> _navigateToProduct(String productId) async {
    await _log('Navigating to product: $productId');
    try {
      final response = await _dio.get("${baseUri}product/$productId");
      final productData = response.data;
      final product = ProductModel.fromJson(productData);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPage(product: product),
          ),
        );
        await _log('Navigation successful to ProductPage');
      }
    } catch (e) {
      await _log('Error fetching product: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load product: $e'.tr())),
        );
      }
    }
  }

  Future<void> _initLogging() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/notification_logs.txt');
      if (!await logFile.exists()) {
        await logFile.create();
      }
    } catch (e) {
      print('Error initializing logging: $e');
    }
  }

  Future<void> _log(String message) async {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $message\n';
    print(logMessage);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/notification_logs.txt');
      await logFile.writeAsString(logMessage, mode: FileMode.append);
    } catch (e) {
      print('Error writing log: $e');
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final directory = await getApplicationDocumentsDirectory();
  final logFile = File('${directory.path}/notification_logs.txt');
  final timestamp = DateTime.now().toIso8601String();
  await logFile.writeAsString(
      '[$timestamp] Background Message: ${message.messageId}, Data: ${message.data}\n',
      mode: FileMode.append);
}
