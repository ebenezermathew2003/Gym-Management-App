import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gym/member_login_page.dart';
import 'package:gym/gym_equipment_page.dart';
import 'package:gym/customer_announcements_page.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key, this.announcements = const []});

  final List announcements;

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  // Function to fetch payment details for a specific member
  Future<Map<String, dynamic>> _fetchPaymentDetails(String memberFullname) async {
    final response = await http.get(Uri.parse('http://localhost/android_gym/fetch_payment_details.php?member_fullname=$memberFullname'));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      // Parse JSON object
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load payment details');
    }
  }

  void _showPaymentAlert(BuildContext context, String memberFullname) async {
    try {
      final paymentDetails = await _fetchPaymentDetails(memberFullname);
      // Debug print the payment details
      print(paymentDetails);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Payment Information'),
            content: paymentDetails.isNotEmpty
                ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Member\'s Full Name', paymentDetails['member_fullname'] ?? 'N/A'),
                _buildDetailRow('ID', paymentDetails['id'] ?? 'N/A'),
                _buildDetailRow('Date of Last Payment', paymentDetails['date_of_last_payment'] ?? 'N/A'),
                _buildDetailRow('Amount per Month', paymentDetails['amount_per_month'] != null ? '\$${paymentDetails['amount_per_month']}' : 'N/A'),
                _buildDetailRow('Selected Service', paymentDetails['selected_service'] ?? 'N/A'),
                _buildDetailRow('Plan', paymentDetails['plan'] != null ? '${paymentDetails['plan']} months' : 'N/A'),
                _buildDetailRow('Total Amount', paymentDetails['total_amount'] != null ? '\$${paymentDetails['total_amount']}' : 'N/A'),
                _buildDetailRow('Payment Completed', paymentDetails['payment_completed'] != null ? '${paymentDetails['payment_completed']}' : 'N/A'),
                _buildDetailRow('Created At', paymentDetails['created_at'] ?? 'N/A'),
              ],
            )
                : const Text('No payment details available'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Handle errors here, possibly show an error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load payment details.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey[700],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Home Page'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.blue.shade200],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.payment, color: Colors.blue),
                title: const Text('Payment'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  _showPaymentAlert(context, 'John Doe'); // Replace 'John Doe' with the actual member's name
                },
              ),
              ListTile(
                leading: const Icon(Icons.announcement, color: Colors.blue),
                title: const Text('Announcement'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomerAnnouncementsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.fitness_center, color: Colors.blue),
                title: const Text('Gym Equipment'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GymEquipmentPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MemberLoginPage()),
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Text(
            'Welcome to Customer Home Page',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
