import 'package:flutter/material.dart';

class AddEquipmentPage extends StatefulWidget {
  final Map<String, String>? equipment;
  final int? nextNumber;

  const AddEquipmentPage({super.key, this.equipment, this.nextNumber});

  @override
  _AddEquipmentPageState createState() => _AddEquipmentPageState();
}

class _AddEquipmentPageState extends State<AddEquipmentPage> {
  late TextEditingController _numberController;
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _quantityController;
  late TextEditingController _purchaseDateController;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(
      text: widget.equipment?['number'] ?? widget.nextNumber.toString(),
    );
    _nameController = TextEditingController(text: widget.equipment?['name'] ?? '');
    _amountController = TextEditingController(text: widget.equipment?['amount'] ?? '');
    _quantityController = TextEditingController(text: widget.equipment?['quantity'] ?? '');
    _purchaseDateController = TextEditingController(text: widget.equipment?['purchase_date'] ?? '');
  }

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
    _purchaseDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.equipment == null ? 'Add Equipment' : 'Edit Equipment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(labelText: 'Equipment Number'),
              readOnly: widget.equipment != null,
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Equipment Name'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            TextField(
              controller: _purchaseDateController,
              decoration: const InputDecoration(labelText: 'Purchase Date'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _purchaseDateController.text = pickedDate.toIso8601String().split('T')[0];
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final equipment = {
                  'id': widget.equipment?['id'] ?? '',
                  'number': _numberController.text,
                  'name': _nameController.text,
                  'amount': _amountController.text,
                  'quantity': _quantityController.text,
                  'purchase_date': _purchaseDateController.text,
                };

                Navigator.pop(context, equipment);
              },
              child: Text(widget.equipment == null ? 'Add Equipment' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
