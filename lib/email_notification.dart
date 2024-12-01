import 'package:flutter/material.dart';

class EmailNotifications extends StatelessWidget {
  final List<String> notifications; // Accept the notifications list

  const EmailNotifications({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Notifications'),
      ),
      body: notifications.isEmpty
          ? Center(
        child: Text(
          'No email notifications yet.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.email, color: Colors.blue),
            title: Text(
              notifications[index],
              style: TextStyle(fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}
