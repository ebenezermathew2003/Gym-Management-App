import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PaymentPage extends StatelessWidget {
  final String memberFullname;
  final String dateOfLastPayment;
  final int amountPerMonth;
  final String selectedService;
  final int plan;
  final int totalAmount;

  const PaymentPage({
    Key? key,
    required this.memberFullname,
    required this.dateOfLastPayment,
    required this.amountPerMonth,
    required this.selectedService,
    required this.plan,
    required this.totalAmount, required int id,
  }) : super(key: key);

  BuildContext? get context => null;

  Future<void> _savePaymentDetails() async {
    // Define the URL of the PHP script
    var url = Uri.parse('http://localhost/android_gym/save_member_payment.php');

    // Prepare the data to be sent in the POST request
    var paymentData = {
      'member_fullname': memberFullname,
      'date_of_last_payment': dateOfLastPayment,
      'amount_per_month': amountPerMonth.toString(),
      'selected_service': selectedService,
      'plan': plan.toString(),
      'total_amount': totalAmount.toString(),
      'payment_completed': 'Yes',
    };

    // Send the POST request
    var response = await http.post(url, body: paymentData);

    // Check the response
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        // Show success message
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(content: Text('Payment saved successfully!')),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(content: Text('Failed to save payment: ${responseData['message']}')),
        );
      }
    } else {
      // Handle server error
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(content: Text('Server error: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[50]!, Colors.blueGrey[200]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Member\'s Full Name', memberFullname),
                  _buildDetailRow('Date of Last Payment', dateOfLastPayment),
                  _buildDetailRow('Amount per Month', '\$$amountPerMonth'),
                  _buildDetailRow('Selected Service', selectedService),
                  _buildDetailRow('Plan', '$plan months'),
                  _buildDetailRow('Total Amount', '\$$totalAmount'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _savePaymentDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: Text('Save Payment'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
}