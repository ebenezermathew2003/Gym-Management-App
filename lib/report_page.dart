import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportPage extends StatefulWidget {
  final List<Map<String, dynamic>> memberDetails;

  const ReportPage({Key? key, required this.memberDetails}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<Map<String, dynamic>> progressData = [];

  @override
  void initState() {
    super.initState();
    fetchProgressData();
  }

  Future<void> fetchProgressData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost/android_gym/fetch_report.php'));

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        final Map<String, dynamic> jsonResponse = json.decode(responseBody);

        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'];
          setState(() {
            progressData = data.cast<Map<String, dynamic>>();
          });
        } else {
          throw Exception('Failed to load progress data: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load progress data');
      }
    } catch (e) {
      print('Error fetching progress data: $e');
      // Optionally show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Report Page'),
      ),
      body: progressData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Member ID', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Current Weight', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Body Type', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Progress Notes', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: progressData.map((progress) {
              return DataRow(cells: [
                DataCell(Text(progress['member_id'].toString())),
                DataCell(Text(progress['current_weight'].toString())),
                DataCell(Text(progress['current_body_type'].toString())),
                DataCell(Text(progress['progress_notes'].toString())),
              ]);
            }).toList(),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue.shade50),
            headingTextStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            dataRowColor: MaterialStateColor.resolveWith((states) => Colors.blue.shade100),
            dataTextStyle: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
