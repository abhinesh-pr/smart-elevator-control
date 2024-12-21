import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_elevator/screens/dashboard.dart';
import 'package:smart_elevator/utils/themes.dart';
 // Import your themes.dart file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      theme: lightTheme, // Light theme from themes.dart
      darkTheme: darkTheme, // Dark theme from themes.dart
      themeMode: ThemeMode.system, // Automatically switches between light and dark themes
      home: DashboardPage(), // Entry point of your app
    );
  }
}


