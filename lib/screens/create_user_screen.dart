import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/my_app_bar.dart';
import 'package:uuid/uuid.dart';
// import 'package:qr_flutter/qr_flutter.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  // Controllers for each text field
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _academicYearController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  String selectedRole = 'IT'; // Default role
  String selectedDepartment = 'General'; // Default department
  bool isLoading = false; // Loading indicator state
  bool isPasswordVisible = false; // Password visibility state

  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _idController.dispose();
    _academicYearController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  // Reset form fields
  void resetForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _phoneController.clear();
    _idController.clear();
    _academicYearController.clear();
    _birthDateController.clear();
    setState(() {
      selectedRole = 'IT';
      selectedDepartment = '';
      isPasswordVisible = false;
    });
  }

  Future<void> createAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Generate unique QR code data
        String qrData = _uuid.v4();

        // Create a SEPARATE Firebase Auth instance for creating the new user
        final FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(
          app: FirebaseAuth.instance.app,
        );

        // Create new user using the secondary auth instance
        final UserCredential userCredential =
            await secondaryAuth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (userCredential.user != null) {
          // Store additional user data and QR code in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'role': selectedRole,
            'department':
                selectedDepartment, // Updated to use selectedDepartment
            'id': _idController.text,
            'academicYear': _academicYearController.text,
            'birthDate': _birthDateController.text,
            'createdAt': FieldValue.serverTimestamp(),
            'qrCode': qrData,
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully!')),
          );

          // Reset the form after successful creation
          resetForm();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create account: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the selected role is IT, Professor, Assistant, Secretary, Training Unit, or Student Affair
    bool isRoleWithNoExtraFields = [
      'IT',
      'Professor',
      'Assistant',
      'Secretary',
      'Training Unit',
      'Student Affair'
    ].contains(selectedRole);

    return Scaffold(
      appBar: MyAppBar(
        title: 'Create User',
        onpressed: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                  value: selectedRole,
                  items: const [
                    DropdownMenuItem(
                      value: 'IT',
                      child: Text('IT'),
                    ),
                    DropdownMenuItem(
                      value: 'Professor',
                      child: Text('Professor'),
                    ),
                    DropdownMenuItem(
                      value: 'Assistant',
                      child: Text('Assistant'),
                    ),
                    DropdownMenuItem(
                      value: 'Student',
                      child: Text('Student'),
                    ),
                    DropdownMenuItem(
                      value: 'Secretary',
                      child: Text('Secretary'),
                    ),
                    DropdownMenuItem(
                      value: 'Training Unit',
                      child: Text('Training Unit'),
                    ),
                    DropdownMenuItem(
                      value: 'Student Affair',
                      child: Text('Student Affair'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _firstNameController,
                    label: 'First name',
                    hintText: 'enter First name'),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _lastNameController,
                    label: 'Last name',
                    hintText: 'enter Last name'),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'enter Email'),
                const SizedBox(height: 16),
                _buildPasswordField(controller: _passwordController),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    hintText: 'enter Phone'),
                const SizedBox(height: 16),
                // Conditionally show Department dropdown
                Visibility(
                  visible: !isRoleWithNoExtraFields,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Department',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        value: selectedDepartment,
                        items: const [
                          DropdownMenuItem(
                            value: 'General',
                            child: Text('General'),
                          ),
                          DropdownMenuItem(
                            value: 'CE',
                            child: Text('CE'),
                          ),
                          DropdownMenuItem(
                            value: 'ECE',
                            child: Text('ECE'),
                          ),
                          DropdownMenuItem(
                            value: 'IE',
                            child: Text('IE'),
                          ),
                          DropdownMenuItem(
                            value: 'EME',
                            child: Text('EME'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedDepartment = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Department is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // Conditionally show ID field
                Visibility(
                  visible: !isRoleWithNoExtraFields,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                          controller: _idController,
                          label: 'ID',
                          hintText: 'ex: 20060785'),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // Conditionally show Academic Year field
                Visibility(
                  visible: !isRoleWithNoExtraFields,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                          controller: _academicYearController,
                          label: 'Academic Year',
                          hintText: 'enter Academic Year'),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                _buildDateField(controller: _birthDateController),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create Account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isPasswordVisible,
          decoration: InputDecoration(
            hintText: 'enter Password',
            suffixIcon: IconButton(
              icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (value.length < 15) {
              return 'Password must be at least 15 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Birth Date',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '---- -- --',
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today_outlined),
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    controller.text = "${pickedDate.toLocal()}".split(' ')[0];
                  });
                }
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          readOnly: true, // Prevent manual typing
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Birth Date is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}
