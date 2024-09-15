import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'update_progress_page.dart'; // Import the new page

class ManageCustomerProgressPage extends StatefulWidget {
  @override
  _ManageCustomerProgressPageState createState() =>
      _ManageCustomerProgressPageState();
}

class _ManageCustomerProgressPageState
    extends State<ManageCustomerProgressPage> {
  List<Map<String, dynamic>> memberDetails = [];

  @override
  void initState() {
    super.initState();
    _fetchMemberDetails();
  }

  Future<void> _fetchMemberDetails() async {
    final response =
    await http.get(Uri.parse('http://localhost/android_gym/get_members.php'));
    if (response.statusCode == 200) {
      dynamic jsonResponse = json.decode(response.body);
      setState(() {
        memberDetails = List<Map<String, dynamic>>.from(jsonResponse);
      });
    } else {
      print('Failed to fetch member details. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Customer Progress'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Member Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16.0,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  columns: [
                    DataColumn(label: Text('Sl. No.')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Health Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: memberDetails.asMap().entries.map((entry) {
                    int index = entry.key + 1;
                    Map<String, dynamic> member = entry.value;
                    return DataRow(cells: [
                      DataCell(Text('$index')),
                      DataCell(Text(member['name'] ?? '')),
                      DataCell(Text(member['health_status'] ?? '')),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateProgressPage(
                                  memberDetails: member,
                                ),
                              ),
                            );
                          },
                          child: Text('Update Progress'),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ManageCustomerProgressPage(),
  ));
}
