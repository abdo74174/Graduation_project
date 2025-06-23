import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/screens/product_page.dart';
import 'package:graduation_project/services/stateMangment/cubit/user_cubit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUri, // e.g., https://10.0.2.2:7273
    connectTimeout: Duration(seconds: 15),
    receiveTimeout: Duration(seconds: 15),
  ));
  final BuildContext context;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  NotificationService(this.context) {
    if (kDebugMode) {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          print('Bypassing SSL for $host:$port');
          return true;
        };
        return client;
      };
    }
  }

  Future<void> initNotifications() async {
    try {
      await _initLogging();
      print('Logging initialized successfully');

      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: true,
        sound: true,
      );
      print('Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('Notification permissions denied, re-requesting...');
        settings = await _messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: true,
          sound: true,
        );
        print(
            'Re-requested permission status: ${settings.authorizationStatus}');
      }

      await _initLocalNotifications();
      print('Local notifications initialized successfully');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        String? token;
        int retryCount = 0;
        const maxRetries = 5;
        while (token == null && retryCount < maxRetries) {
          try {
            token = await _messaging.getToken();
            if (token != null) {
              print('Device Token: $token');
              break;
            }
            print(
                'Attempt ${retryCount + 1}: Device token is null, retrying...');
            await Future.delayed(Duration(seconds: 3 * (retryCount + 1)));
            retryCount++;
          } catch (e, stackTrace) {
            print(
                'Attempt ${retryCount + 1}: Error fetching token: $e\n$stackTrace');
            retryCount++;
            await Future.delayed(Duration(seconds: 3 * (retryCount + 1)));
          }
        }

        if (token != null) {
          await _registerToken(token);
        } else {
          print(
              'Error: Failed to obtain device token after $maxRetries retries');
          if (navigatorKey.currentState?.mounted ?? false) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
              SnackBar(
                  content: Text('Failed to initialize notifications'.tr())),
            );
          }
        }
      } else {
        print('Notifications not authorized by user');
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print(
            'Foreground Message Received: ${message.messageId}, Title: ${message.notification?.title}, Body: ${message.notification?.body}, Data: ${message.data}');
        if (message.notification != null) {
          try {
            await _showLocalNotification(message);
            if (navigatorKey.currentState?.mounted ?? false) {
              ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                SnackBar(
                  content: Text(
                      "${message.notification?.title ?? 'Notification'}: ${message.notification?.body ?? 'New message'}"),
                  action: SnackBarAction(
                    label: 'View'.tr(),
                    onPressed: () async {
                      try {
                        await _handleNotificationClick(message);
                      } catch (e, stackTrace) {
                        print(
                            'Error handling notification click: $e\n$stackTrace');
                      }
                    },
                  ),
                ),
              );
            } else {
              print('Error: Navigator context not mounted for SnackBar');
            }
          } catch (e, stackTrace) {
            print('Error processing foreground message: $e\n$stackTrace');
          }
        } else {
          print('Foreground message has no notification payload');
        }
      });

      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) async {
        print(
            'Notification Opened: ${message.messageId}, Data: ${message.data}');
        try {
          await _handleNotificationClick(message);
        } catch (e, stackTrace) {
          print('Error handling notification open: $e\n$stackTrace');
        }
      });

      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        print(
            'Initial Message: ${initialMessage.messageId}, Data: ${initialMessage.data}');
        try {
          await _handleNotificationClick(initialMessage);
        } catch (e, stackTrace) {
          print('Error handling initial message: $e\n$stackTrace');
        }
      }

      _messaging.onTokenRefresh.listen((newToken) async {
        print('Token Refreshed: $newToken');
        await _registerToken(newToken);
      });
    } catch (e, stackTrace) {
      print('Error initializing notifications: $e\n$stackTrace');
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      final userId = context.read<UserCubit>().state.userId;
      if (userId == null) {
        print(
            'Error: No user ID available in UserCubit, cannot register token');
        return;
      }
      print('Registering token for userId: $userId');
      final response = await _dio.post(
        "notification/register",
        data: {
          "token": token,
          "userId": int.parse(userId),
        },
      );
      print(
          'Token registration response: ${response.statusCode} ${response.data}');
    } catch (e, stackTrace) {
      print('Error sending token to server: $e\n$stackTrace');
    }
  }

  Future<void> _initLocalNotifications() async {
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications',
        importance: Importance.max,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@drawable/notification_icon');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
          print('Local Notification Tapped: ${response.payload}');
          if (response.payload != null) {
            try {
              await _navigateToProduct(response.payload!);
            } catch (e, stackTrace) {
              print(
                  'Error navigating from local notification: $e\n$stackTrace');
            }
          } else {
            print('Error: Notification payload is null');
          }
        },
      );
      print('Local notifications initialized successfully');
    } catch (e, stackTrace) {
      print('Error initializing local notifications: $e\n$stackTrace');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.messageId.hashCode,
        message.notification?.title ?? 'Notification',
        message.notification?.body ?? 'New message received',
        notificationDetails,
        payload: message.data['product_id'],
      );
      print('Local notification shown: ${message.notification?.title}');
    } catch (e, stackTrace) {
      print('Error showing local notification: $e\n$stackTrace');
    }
  }

  Future<void> _handleNotificationClick(RemoteMessage message) async {
    final productId = message.data['product_id'];
    if (productId != null) {
      try {
        await _navigateToProduct(productId);
      } catch (e, stackTrace) {
        print('Error navigating from notification: $e\n$stackTrace');
      }
    } else {
      print('Error: No product_id in notification data');
    }
  }

  Future<void> _navigateToProduct(String productId) async {
    print('Navigating to product: $productId');
    try {
      final response = await _dio.get("product/$productId");
      print('Product fetch response: ${response.statusCode} ${response.data}');
      final productData = response.data;
      final product = ProductModel.fromJson(productData);
      if (navigatorKey.currentState?.mounted ?? false) {
        navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => ProductPage(product: product),
          ),
        );
        print('Navigation successful to ProductPage for product: $productId');
      } else {
        print('Error: Navigator context not mounted for navigation');
      }
    } catch (e, stackTrace) {
      print('Error fetching product: $e\n$stackTrace');
      if (navigatorKey.currentState?.mounted ?? false) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
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
        print('Log file created at: ${logFile.path}');
      }
    } catch (e, stackTrace) {
      print('Error initializing logging: $e\n$stackTrace');
    }
  }

  Future<void> _log(String message) async {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $message';
    print(logMessage);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/notification_logs.txt');
      await logFile.writeAsString('$logMessage\n', mode: FileMode.append);
    } catch (e, stackTrace) {
      print('Error writing log: $e\n$stackTrace');
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    final directory = await getApplicationDocumentsDirectory();
    final logFile = File('${directory.path}/notification_logs.txt');
    final timestamp = DateTime.now().toIso8601String();
    final logMessage =
        '[$timestamp] Background Message: ${message.messageId}, Data: ${message.data}';
    print(logMessage);
    await logFile.writeAsString('$logMessage\n', mode: FileMode.append);
  } catch (e, stackTrace) {
    print('Error in background message handler: $e\n$stackTrace');
  }
}
