// import 'dart:developer';
// import 'package:graduation_project/services/notifications/notification_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';

// @pragma('vm:entry-point')
// Future<void> hourlyServerCheck() async {
//   log("Background check started...");

//   // Mock server status (replace with real API check)
//   final bool isOnline = true; // <- Replace with actual API check

//   if (isOnline) {
//     // Show a notification
//     await NotificationService.showNotification(
//       id: 0,
//       title: "Status Update",
//       body: "You are online. Redirecting to login...",
//     );

//     // Update login status (used in main.dart)
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(
//         'isLoggedIn', false); // force logout to go to login screen
//   }
// }
