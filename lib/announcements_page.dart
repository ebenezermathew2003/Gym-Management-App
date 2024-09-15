// announcements_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'manage_announcement_page.dart';
import 'dart:convert';

class AnnouncementsPage extends StatefulWidget {
  @override
  _AnnouncementsPageState createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  List<Announcement> announcements = [];

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    final response = await http.get(Uri.parse('http://localhost/android_gym/get_announcements.php'));

    if (response.statusCode == 200) {
      setState(() {
        announcements = (json.decode(response.body) as List)
            .map((data) => Announcement.fromJson(data))
            .toList();
      });
    } else {
      throw Exception('Failed to load announcements');
    }
  }

  Future<void> _addAnnouncement(String date, String message) async {
    final response = await http.post(
      Uri.parse('http://localhost/android_gym/add_announcement.php'),
      body: {
        'date': date,
        'message': message,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        announcements.add(Announcement(date: date, message: message));
      });
    } else {
      throw Exception('Failed to add announcement');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcement'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageAnnouncementsPage(announcements: announcements),
                  ),
                );
              },
              child: Text('Manage Your Announcements'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, // Background color
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Make Announcements',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter your announcement here...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Applied Date:', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      hintText: 'DD/MM/YYYY',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle publish announcement action
                  String message = _messageController.text;
                  String date = _dateController.text;
                  if (message.isNotEmpty && date.isNotEmpty) {
                    _addAnnouncement(date, message);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Announcement published successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Clear fields after publishing
                    _messageController.clear();
                    _dateController.clear();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fill in all fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text('Publish Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Background color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Announcement {
  String date;
  String message;

  Announcement({required this.date, required this.message});

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      date: json['date'],
      message: json['message'],
    );
  }

  get id => null;

  get isAdmin => null;
}