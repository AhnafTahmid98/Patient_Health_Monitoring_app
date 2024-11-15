import 'package:flutter/material.dart';
import 'main_dashboard.dart';
import 'bpm_page.dart';
import 'temperature_page.dart';
import 'stress_page.dart';
import 'continuous_health_monitoring.dart'; // Import for continuous monitoring page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/dashboard',  // Set the new initial route
      routes: {
        '/dashboard': (context) => MainDashboard(),
        '/bpm': (context) => BPMPage(),
        '/temperature': (context) => TemperaturePage(),
        '/stress': (context) => StressPage(),
        '/continuous_health_monitoring': (context) => ContinuousHealthMonitoring(),
      },
    );
  }
}
