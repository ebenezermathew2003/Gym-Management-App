import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GymEquipmentPage extends StatefulWidget {
  final bool isAdmin;

  const GymEquipmentPage({super.key, this.isAdmin = false});

  @override
  _GymEquipmentPageState createState() => _GymEquipmentPageState();
}

class _GymEquipmentPageState extends State<GymEquipmentPage> {
  List<dynamic> equipmentList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEquipment();
  }

  Future<void> _fetchEquipment() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost/android_gym/get_equipment.php'));

      if (response.statusCode == 200) {
        setState(() {
          equipmentList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load equipment');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Equipment'),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DataTable(
                columnSpacing: 20.0,
                headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.grey.shade200),
                columns: [
                  DataColumn(
                    label: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: const Text(
                        'Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: const Text(
                        'Amount',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: const Text(
                        'Quantity',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (widget.isAdmin)
                    DataColumn(
                      label: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: const Text(
                          'Actions',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
                rows: equipmentList
                    .map((equipment) => DataRow(
                  cells: [
                    DataCell(Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(equipment['name']),
                    )),
                    DataCell(Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(equipment['amount'].toString()),
                    )),
                    DataCell(Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(equipment['quantity'].toString()),
                    )),
                    if (widget.isAdmin)
                      DataCell(Container(
                        padding: const EdgeInsets.all(10.0),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // Handle edit action
                          },
                        ),
                      )),
                  ],
                  color: MaterialStateColor.resolveWith((states) {
                    return states.contains(MaterialState.selected)
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.white;
                  }),
                ))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
