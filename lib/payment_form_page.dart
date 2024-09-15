// payment_form_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'payment_page.dart';

class PaymentFormPage extends StatefulWidget {
  final String service;

  const PaymentFormPage({
    Key? key,
    required this.service,
    required String memberFullname,
  }) : super(key: key);

  @override
  _PaymentFormPageState createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends State<PaymentFormPage> {
  String memberFullname = '';
  String? dateOfLastPayment;
  int? amountPerMonth;
  int? plan;
  int? totalAmount;
  String status = 'Active';
  List<String> memberNames = [];
  String selectedService = '';
  List<String> serviceOptions = ['Fitness', 'Muscle', 'Leg'];
  List<int> planOptions = List.generate(12, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    _fetchMemberNames();
  }

  Future<void> _fetchMemberNames() async {
    final response =
    await http.get(Uri.parse('http://localhost/android_gym/get_members.php'));
    if (response.statusCode == 200) {
      dynamic jsonResponse = json.decode(response.body);
      if (jsonResponse is List) {
        setState(() {
          memberNames =
              jsonResponse.map((member) => member['name']).toList().cast<String>();
          if (memberNames.isNotEmpty) {
            memberFullname = memberNames.first;
          }
        });
      }
    }
  }

  Future<void> _savePaymentData() async {
    var paymentData = {
      'member_fullname': memberFullname,
      'date_of_last_payment': dateOfLastPayment ?? '',
      'amount_per_month': amountPerMonth.toString(),
      'selected_service': selectedService,
      'plan': plan.toString(),
      'total_amount': totalAmount.toString(),
      'payment_completed': 'Yes',
    };

    var url = Uri.parse('http://localhost/android_gym/save_payment.php');
    var response = await http.post(url, body: paymentData);

    if (response.statusCode == 200) {
      // Handle success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment saved successfully!')),
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save payment.')),
      );
    }
  }

  void _showAlert() {
    if (amountPerMonth != null && plan != null) {
      setState(() {
        totalAmount = amountPerMonth! * plan!;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            memberFullname: memberFullname,
            dateOfLastPayment: dateOfLastPayment ?? '',
            amountPerMonth: amountPerMonth!,
            selectedService: selectedService,
            plan: plan!,
            totalAmount: totalAmount!, id: 0,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Alert'),
            content: Text('Please fill in all required fields.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Form'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alvas Gym Management',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  SizedBox(height: 8),
                  Text('Shobhavana Campus, Mijar', style: TextStyle(color: Colors.grey[700])),
                  Text('Tel: 000-000-0000', style: TextStyle(color: Colors.grey[700])),
                  Text('Email: support@alvas.org.in.com', style: TextStyle(color: Colors.grey[700])),
                  SizedBox(height: 16),
                  Spacer(),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Form',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  const SizedBox(height: 16),
                  Table(
                    border: TableBorder.all(color: Colors.grey),
                    children: [
                      TableRow(children: [
                        const TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Member\'s Fullname:'),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<String>(
                              value: memberFullname,
                              items: memberNames.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                if (value != null) {
                                  setState(() {
                                    memberFullname = value;
                                  });
                                }
                              },
                              hint: const Text('Select Member'),
                            ),
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        const TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Date of Last Payment:'),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  dateOfLastPayment = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Enter date of last payment (e.g., dd/MM/yyyy)',
                                hintStyle: TextStyle(color: Colors.green.shade500),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        const TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Amount:'),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  amountPerMonth = int.tryParse(value);
                                  if (amountPerMonth != null && plan != null) {
                                    totalAmount = amountPerMonth! * plan!;
                                  }
                                });
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Enter amount',
                                hintStyle: TextStyle(color: Colors.green.shade500),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        const TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Service:'),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<String>(
                              value: selectedService.isNotEmpty ? selectedService : null,
                              items: serviceOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                if (value != null) {
                                  setState(() {
                                    selectedService = value;
                                  });
                                }
                              },
                              hint: const Text('Select Service'),
                            ),
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        const TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Plan:'),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<int>(
                              value: plan != null ? plan : null,
                              items: planOptions.map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value months'),
                                );
                              }).toList(),
                              onChanged: (int? value) {
                                if (value != null) {
                                  setState(() {
                                    plan = value;
                                    if (amountPerMonth != null && plan != null) {
                                      totalAmount = amountPerMonth! * plan!;
                                    }
                                  });
                                }
                              },
                              hint: const Text('Select Plan'),
                            ),
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        const TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Total Amount:'),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(totalAmount != null ? '$totalAmount' : ''),
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        const TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Status:'),
                          ),
                        ),
                        const TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Paid'),
                          ),
                        ),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (amountPerMonth != null && plan != null) {
                            totalAmount = amountPerMonth! * plan!;
                            _savePaymentData();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                        child: const Text('Save Payment'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _showAlert,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                        child: const Text('Show Alert'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}