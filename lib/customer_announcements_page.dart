import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomerAnnouncementsPage extends StatefulWidget {
  const CustomerAnnouncementsPage({Key? key}) : super(key: key);

  @override
  _CustomerAnnouncementsPageState createState() => _CustomerAnnouncementsPageState();
}

class _CustomerAnnouncementsPageState extends State<CustomerAnnouncementsPage> {
  List<Announcement> announcements = [];

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    final url = Uri.parse('http://localhost/android_gym/get_announcements.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        announcements = data.map((json) => Announcement.fromJson(json)).toList();
      });
    } else {
      // Handle error - display an error message or retry logic
      print('Failed to load announcements');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Announcements'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Announcement')),
                ],
                rows: announcements.map((announcement) {
                  return DataRow(
                    cells: [
                      DataCell(Text(announcement.id.toString())),
                      DataCell(Text(announcement.date)),
                      DataCell(Text(announcement.message)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Announcement {
  final int id;
  final String date;
  final String message;

  Announcement({required this.id, required this.date, required this.message});

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: int.parse(json['id']),
      date: json['date'],
      message: json['message'],
    );
  }
}
