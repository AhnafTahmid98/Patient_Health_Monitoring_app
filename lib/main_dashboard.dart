import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Clock, Date, and Day Widget
            Center(
              child: StreamBuilder<DateTime>(
                stream: Stream.periodic(Duration(seconds: 1), (_) => DateTime.now()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Text("Loading...");
                  final now = snapshot.data!;
                  final time = DateFormat('HH:mm:ss').format(now);
                  final date = DateFormat('yyyy-MM-dd').format(now);
                  final day = DateFormat('EEEE').format(now);

                  return Column(
                    children: [
                      Text(
                        time,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                      ),
                      Text(
                        "$day, $date",
                        style: TextStyle(fontSize: 18, color: Colors.blueGrey[700]),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20),

            // Dashboard Cards
            DashboardCard(
              key: Key('bpmCard'),
              title: 'BPM Monitor',
              color: Color(0xFF4DD0E1), // Teal color for BPM Monitor
              iconPath: 'assets/images/bpm.png',
              onTap: () => Navigator.pushNamed(context, '/bpm'),
            ),
            SizedBox(height: 16),
            DashboardCard(
              key: Key('temperatureCard'),
              title: 'Temperature Monitor',
              color: Color(0xFFFFD54F), // Yellow color for Temperature Monitor
              iconPath: 'assets/images/temperature.png',
              onTap: () => Navigator.pushNamed(context, '/temperature'),
            ),
            SizedBox(height: 16),
            DashboardCard(
              key: Key('stressCard'),
              title: 'Stress Level Monitor',
              color: Color(0xFFE57373), // Red color for Stress Level Monitor
              iconPath: 'assets/images/stress.png',
              onTap: () => Navigator.pushNamed(context, '/stress'),
            ),
            SizedBox(height: 16),
            DashboardCard(
              key: Key('continuousHealthCard'),
              title: 'Continuous Health Monitor',
              color: Color(0xFFF06292), // Pink color for Continuous Health Monitor
              iconPath: 'assets/images/medical_condition.png',
              onTap: () => Navigator.pushNamed(context, '/continuous_health_monitoring'),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final Color color;
  final String iconPath;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.color,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Image.asset(iconPath, width: 50, height: 50),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
