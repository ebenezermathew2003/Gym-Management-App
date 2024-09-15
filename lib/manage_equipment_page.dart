import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_equipment_page.dart';

class GymEquipmentPage extends StatefulWidget {
  const GymEquipmentPage({super.key});

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

  Future<void> _addEquipment(Map<String, String> newEquipment) async {
    final response = await http.post(
      Uri.parse('http://localhost/android_gym/add_equipment.php'),
      body: newEquipment,
    );

    if (response.statusCode == 200) {
      _fetchEquipment();
    } else {
      print('Failed to add equipment');
    }
  }

  Future<void> _updateEquipment(Map<String, String> updatedEquipment) async {
    final response = await http.post(
      Uri.parse('http://localhost/android_gym/update_equipment.php'),
      body: updatedEquipment,
    );

    if (response.statusCode == 200) {
      _fetchEquipment();
    } else {
      print('Failed to update equipment');
    }
  }

  Future<void> _deleteEquipment(String id) async {
    final response = await http.post(
      Uri.parse('http://localhost/android_gym/delete_equipment.php'),
      body: {'id': id},
    );

    if (response.statusCode == 200) {
      _fetchEquipment();
    } else {
      print('Failed to delete equipment');
    }
  }

  Widget tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Equipment'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://tse2.mm.bing.net/th?id=OIP.0DVsC9KVPADx0WkjeLGxAQHaE8&pid=Api&P=0&h=220',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5), // Adjusted opacity for better readability
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Table(
                      border: TableBorder.all(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        width: 1,
                      ),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.blueAccent),
                          children: [
                            tableCell('Number'),
                            tableCell('Name'),
                            tableCell('Amount'),
                            tableCell('Quantity'),
                            tableCell('Purchase Date'),
                            tableCell('Actions'),
                          ],
                        ),
                        ...equipmentList.map<TableRow>((equipment) {
                          return _buildEquipmentRow(
                            equipment['id'].toString(),
                            equipment['number'].toString(),
                            equipment['name'].toString(),
                            equipment['amount'].toString(),
                            equipment['quantity'].toString(),
                            equipment['purchase_date'].toString(),
                            equipment['id'].toString(),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final newEquipment = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEquipmentPage(
                          nextNumber: equipmentList.length + 1,
                        ),
                      ),
                    );

                    if (newEquipment != null) {
                      _addEquipment(newEquipment);
                    }
                  },
                  child: const Text('Add Equipment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildEquipmentRow(
      String id,
      String number,
      String name,
      String amount,
      String quantity,
      String purchaseDate,
      String equipmentId,
      ) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2)),
      children: [
        tableCell(number),
        tableCell(name),
        tableCell(amount),
        tableCell(quantity),
        tableCell(purchaseDate),
        TableCell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () async {
                  final updatedEquipment = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEquipmentPage(
                        equipment: {
                          'id': id,
                          'number': number,
                          'name': name,
                          'amount': amount,
                          'quantity': quantity,
                          'purchase_date': purchaseDate,
                        },
                      ),
                    ),
                  );

                  if (updatedEquipment != null) {
                    _updateEquipment(updatedEquipment);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () {
                  _deleteEquipment(id);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
