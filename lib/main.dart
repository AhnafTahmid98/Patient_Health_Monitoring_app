import 'package:flutter/material.dart';
import 'main_dashboard.dart';
import 'bpm_page.dart';
import 'temperature_page.dart';
import 'stress_page.dart';
import 'continuous_health_monitoring.dart';
import 'email_notification.dart'; // Import the EmailNotifications widget

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/dashboard',
      routes: {
        '/dashboard': (context) => MainDashboard(),
        '/bpm': (context) => BPMPage(),
        '/temperature': (context) => TemperaturePage(),
        '/stress': (context) => StressPage(),
        '/continuous_health_monitoring': (context) => ContinuousHealthMonitoring(),
      },
      onGenerateRoute: (settings) {
        // Handle dynamic navigation for EmailNotifications
        if (settings.name == '/email_notifications') {
          return MaterialPageRoute(
            builder: (context) => EmailNotifications(notifications: emailNotifications),
          );
        }
        return null; // Return null for unknown routes
      },
    );
  }
}
