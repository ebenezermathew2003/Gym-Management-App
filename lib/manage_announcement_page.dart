import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'announcements_page.dart';

class ManageAnnouncementsPage extends StatefulWidget {
  final List<Announcement> announcements;

  ManageAnnouncementsPage({required this.announcements});

  @override
  _ManageAnnouncementsPageState createState() => _ManageAnnouncementsPageState();
}

class _ManageAnnouncementsPageState extends State<ManageAnnouncementsPage> {
  Future<void> _deleteAnnouncement(int index) async {
    final response = await http.post(
      Uri.parse('http://localhost/android_gym/delete_announcement.php'),
      body: {
        'id': widget.announcements[index].id.toString(),
      },
    );

    // Debugging: Print response status and body
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      setState(() {
        widget.announcements.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted announcement at index $index'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              // Add undo functionality if needed
            },
          ),
        ),
      );
    } else {
      throw Exception('Failed to delete announcement');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Your Announcements'),
      ),
      body: ListView.builder(
        itemCount: widget.announcements.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(widget.announcements[index].message),
              subtitle: Text('Published on ${widget.announcements[index].date}'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteAnnouncement(index);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
