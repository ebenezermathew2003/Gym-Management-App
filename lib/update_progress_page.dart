import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateProgressPage extends StatefulWidget {
  final Map<String, dynamic> memberDetails;

  UpdateProgressPage({required this.memberDetails});

  @override
  _UpdateProgressPageState createState() => _UpdateProgressPageState();
}

class _UpdateProgressPageState extends State<UpdateProgressPage> {
  late TextEditingController _currentWeightController;
  late TextEditingController _currentBodyTypeController;
  late TextEditingController _progressNotesController;

  @override
  void initState() {
    super.initState();
    _currentWeightController = TextEditingController(
        text: widget.memberDetails['current_weight']?.toString() ?? '');
    _currentBodyTypeController = TextEditingController(
        text: widget.memberDetails['current_body_type'] ?? '');
    _progressNotesController = TextEditingController();
  }

  @override
  void dispose() {
    _currentWeightController.dispose();
    _currentBodyTypeController.dispose();
    _progressNotesController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    final url = 'http://localhost/android_gym/save_progress.php';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'member_id': widget.memberDetails['id'].toString(),
        'current_weight': _currentWeightController.text,
        'current_body_type': _currentBodyTypeController.text,
        'progress_notes': _progressNotesController.text,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Progress updated successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update progress: ${result['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Customer\'s Progress'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Customer\'s Progress',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Table(
              columnWidths: {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              border: TableBorder.all(color: Colors.grey),
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Member\'s Fullname:',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.memberDetails['name'] ?? '',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Health Status:',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.memberDetails['health_status'] ?? '',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Current Weight (KG):',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _currentWeightController,
                        decoration:
                        InputDecoration(border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Current Body Type:',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _currentBodyTypeController,
                        decoration:
                        InputDecoration(border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Progress Notes:',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _progressNotesController,
                        maxLines: null, // Allow multiple lines of text
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Progress Notes',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
