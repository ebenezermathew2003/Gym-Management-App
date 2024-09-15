import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageMembersPage extends StatefulWidget {
  const ManageMembersPage({super.key});

  List<String>? get memberNames => null;

  @override
  _ManageMembersPageState createState() => _ManageMembersPageState();
}

class _ManageMembersPageState extends State<ManageMembersPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _healthStatusController = TextEditingController();
  final TextEditingController _planController = TextEditingController();
  List<Member> _members = [];

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    final response = await http.get(Uri.parse('http://localhost/android_gym/get_members.php'));
    if (response.statusCode == 200) {
      setState(() {
        _members = (json.decode(response.body) as List)
            .map((data) => Member.fromJson(data))
            .toList();
      });
    } else {
      // Handle error
      print('Failed to fetch members');
    }
  }

  Future<void> _submitData() async {
    final response = await http.post(
      Uri.parse('http://localhost/android_gym/save_member.php'),
      body: {
        'name': _nameController.text,
        'age': _ageController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'health_status': _healthStatusController.text,
        'plan': _planController.text,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        _fetchMembers();
        _clearFormFields();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add member: ${jsonResponse['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add member')),
      );
    }
  }

  Future<void> _deleteMember(int id) async {
    final response = await http.post(
      Uri.parse('http://localhost/android_gym/delete_member.php'),
      body: {'id': id.toString()},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        _fetchMembers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete member: ${jsonResponse['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete member')),
      );
    }
  }

  Future<void> _editMember(int id) async {
    final response = await http.post(
      Uri.parse('https://localhost/android_gym/edit_member.php'),
      body: {
        'id': id.toString(),
        'name': _nameController.text,
        'age': _ageController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'health_status': _healthStatusController.text,
        'plan': _planController.text,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        _fetchMembers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update member: ${jsonResponse['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update member')),
      );
    }
  }

  void _showEditMemberDialog(Member member) {
    _nameController.text = member.name;
    _ageController.text = member.age.toString();
    _emailController.text = member.email;
    _phoneController.text = member.phone;
    _healthStatusController.text = member.healthStatus;
    _planController.text = member.plan;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Member'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an age';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _healthStatusController,
                  decoration: const InputDecoration(labelText: 'Health Status'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter health status';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _planController,
                  decoration: const InputDecoration(labelText: 'Plan'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a plan';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _editMember(member.id);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Member'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an age';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _healthStatusController,
                  decoration: const InputDecoration(labelText: 'Health Status'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter health status';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _planController,
                  decoration: const InputDecoration(labelText: 'Plan'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a plan';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _submitData();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _clearFormFields() {
    _nameController.clear();
    _ageController.clear();
    _emailController.clear();
    _phoneController.clear();
    _healthStatusController.clear();
    _planController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Members'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _showAddMemberDialog,
                child: const Text('Add Member'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  textStyle: const TextStyle(fontSize: 16),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Age', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Health Status', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Plan', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _members
                    .map(
                      (member) => DataRow(
                    cells: [
                      DataCell(Text(member.name)),
                      DataCell(Text(member.age.toString())),
                      DataCell(Text(member.email)),
                      DataCell(Text(member.phone)),
                      DataCell(Text(member.healthStatus)),
                      DataCell(Text(member.plan)),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditMemberDialog(member),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMember(member.id),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Member {
  final int id;
  final String name;
  final int age;
  final String email;
  final String phone;
  final String healthStatus;
  final String plan;

  Member({
    required this.id,
    required this.name,
    required this.age,
    required this.email,
    required this.phone,
    required this.healthStatus,
    required this.plan,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: int.parse(json['id']),
      name: json['name'],
      age: int.parse(json['age']),
      email: json['email'],
      phone: json['phone'],
      healthStatus: json['health_status'],
      plan: json['plan'],
    );
  }
}
