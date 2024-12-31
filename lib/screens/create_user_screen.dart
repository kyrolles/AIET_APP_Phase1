import 'package:flutter/material.dart';

class CreateUserScreen extends StatelessWidget {
  const CreateUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'Create User',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Role',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Role1',
                    child: Text('Role1'),
                  ),
                  DropdownMenuItem(
                    value: 'Role2',
                    child: Text('Role2'),
                  ),
                ],
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              _buildTextField(label: 'First name', hintText: 'enter First name'),
              const SizedBox(height: 16),
              _buildTextField(label: 'Last name', hintText: 'enter Last name'),
              const SizedBox(height: 16),
              _buildTextField(label: 'Email', hintText: 'enter Email'),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 16),
              _buildTextField(label: 'Phone', hintText: 'enter Phone'),
              const SizedBox(height: 16),
              _buildTextField(label: 'Department', hintText: 'enter Department'),
              const SizedBox(height: 16),
              _buildTextField(label: 'ID', hintText: 'ex: 20060785'),
              const SizedBox(height: 16),
              _buildTextField(label: 'Academic Year', hintText: 'enter Academic Year'),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'enter Password',
            suffixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Birth Date',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: '---- -- --',
            suffixIcon: const Icon(Icons.calendar_today_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
    );
  }
}
