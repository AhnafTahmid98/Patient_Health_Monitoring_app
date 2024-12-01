import 'package:flutter/material.dart';

class EmailNotifications extends StatefulWidget {
  const EmailNotifications({super.key});

  @override
  State<EmailNotifications> createState() => _EmailNotificationsState();
}

class _EmailNotificationsState extends State<EmailNotifications> {
  // List to store email notifications
  List<String> emailNotifications = [
    // Example notifications
    "Alert: BPM critical - Sent at 2024-11-30 14:20:00",
    "Alert: Temperature high - Sent at 2024-11-30 14:15:00",
  ];

  // Method to add a new notification
  void addNotification(String notification) {
    setState(() {
      emailNotifications.add(notification);
      // Keep only the last 10 notifications
      if (emailNotifications.length > 10) {
        emailNotifications.removeAt(0); // Remove the oldest notification
      }
    });
  }

  // Method to clear all notifications
  void clearNotifications() {
    setState(() {
      emailNotifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Notifications'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Clear Notifications',
            onPressed: clearNotifications,
          ),
        ],
      ),
      body: emailNotifications.isEmpty
          ? Center(
        child: Text(
          'No email notifications available.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: emailNotifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.email, color: Colors.blue),
            title: Text(emailNotifications[index]),
          );
        },
      ),
    );
  }
}
