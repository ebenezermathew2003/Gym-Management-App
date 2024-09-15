// member_status_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MemberStatusPage extends StatefulWidget {
  @override
  _MemberStatusPageState createState() => _MemberStatusPageState();
}

class _MemberStatusPageState extends State<MemberStatusPage> {
  List<dynamic> memberStatusList = []; // List to store member status details

  @override
  void initState() {
    super.initState();
    _fetchMemberStatus(); // Fetch member status when the page initializes
  }

  Future<void> _fetchMemberStatus() async {
    final response = await http.get(Uri.parse('http://localhost/android_gym/get_member_status.php'));
    if (response.statusCode == 200) {
      dynamic jsonResponse = json.decode(response.body);
      print('JSON Response: $jsonResponse'); // Debug print to see the structure of jsonResponse

      if (jsonResponse is List) {
        setState(() {
          memberStatusList = jsonResponse;
        });
      } else {
        print('Expected a list but received: $jsonResponse');
      }
    } else {
      // Handle error
      print('Failed to fetch member status. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Status'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Member Status',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: memberStatusList.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5, // Shadow effect for the card
                    margin: const EdgeInsets.symmetric(vertical: 8.0), // Margin between cards
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16), // Padding inside the card
                      title: Text(
                        'Member: ${memberStatusList[index]['member_fullname']}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Last Payment: ${memberStatusList[index]['date_of_last_payment']}'),
                            Text('Amount: \$${memberStatusList[index]['amount_per_month']}'),
                            Text('Service: ${memberStatusList[index]['selected_service']}'),
                            Text('Plan: ${memberStatusList[index]['plan']} months'),
                            Text('Total Amount: \$${memberStatusList[index]['total_amount']}'),
                            Text('Payment Completed: ${memberStatusList[index]['payment_completed']}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MemberStatusPage(),
  ));
}
