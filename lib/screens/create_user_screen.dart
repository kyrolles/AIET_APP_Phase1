import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/screens/offline_feature/reusable_offline.dart';
import '../components/my_app_bar.dart';
import 'package:uuid/uuid.dart';
import '../services/results_service.dart';
import '../services/schedule_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final ResultsService _resultsService = ResultsService();
  final ScheduleService _scheduleService = ScheduleService();

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
  String selectedDepartment = 'CE'; // Changed from 'General' to 'CE'
  bool isLoading = false; // Loading indicator state
  bool isPasswordVisible = false; // Password visibility state

  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    // Set default value for academicYear
    _academicYearController.text = '1st';
  }

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
    _academicYearController.text = '1st'; // Set default value for academicYear
    _birthDateController.clear();
    setState(() {
      selectedRole = 'IT';
      selectedDepartment = 'CE';
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
          final String userId = userCredential.user!.uid;

          // Prepare user data for Firestore
          final userData = {
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'role': selectedRole,
            'createdAt': FieldValue.serverTimestamp(),
            'qrCode': qrData,
            'profileImage': '',
          };

          // Add additional fields for roles that need them
          if (selectedRole != 'Doctor') {
            userData['department'] = selectedDepartment;
            userData['id'] = _idController.text;
            userData['academicYear'] = _academicYearController.text;
            userData['birthDate'] = _birthDateController.text;

            if (selectedRole == 'Student') {
              userData['totalTrainingScore'] = 0;
            }
          }

          // Create user document in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .set(userData);

          // If user is a student, initialize their results profile
          if (selectedRole == 'Student') {
            await _resultsService.initializeStudentResults(
              userId,
              selectedDepartment,
            );
          }

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully!')),
          );

          // Reset the form after successful creation
          resetForm();
        }
      } catch (e) {
        // Log the full error
        print('Error creating account: $e');
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
    final localizations = AppLocalizations.of(context);

    // Determine if the selected role is IT, Professor, Assistant, Secretary, Training Unit, or Student Affair
    bool isRoleWithNoExtraFields = [
      'IT',
      'Professor',
      'Assistant',
      'Secretary',
      'Training Unit',
      'Student Affair',
      'Doctor' // Added Doctor to roles with no extra fields
    ].contains(selectedRole);
    return Scaffold(
      appBar: MyAppBar(
        title: localizations?.createUser ?? 'Create User',
        onpressed: () => Navigator.pop(context),
      ),
      body: ReusableOffline(
        child: Padding(
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
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    value: selectedRole,
                    items: [
                      DropdownMenuItem(
                        value: 'IT',
                        child: Text(localizations?.it ?? 'IT'),
                      ),
                      DropdownMenuItem(
                        value: 'Professor',
                        child: Text(localizations?.professor ?? 'Professor'),
                      ),
                      DropdownMenuItem(
                        value: 'Assistant',
                        child: Text(localizations?.assistant ?? 'Assistant'),
                      ),
                      DropdownMenuItem(
                        value: 'Student',
                        child: Text(localizations?.student ?? 'Student'),
                      ),
                      DropdownMenuItem(
                        value: 'Secretary',
                        child: Text(localizations?.secretary ?? 'Secretary'),
                      ),
                      DropdownMenuItem(
                        value: 'Training Unit',
                        child: Text(
                            localizations?.trainingUnit ?? 'Training Unit'),
                      ),
                      DropdownMenuItem(
                        value: 'Student Affair',
                        child: Text(
                            localizations?.studentAffair ?? 'Student Affair'),
                      ),
                      DropdownMenuItem(
                        value: 'Doctor',
                        child: Text(localizations?.doctor ?? 'Doctor'),
                      ),
                      DropdownMenuItem(
                        value: 'Admin',
                        child: Text(localizations?.admin ?? 'Admin'),
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
                      label: localizations?.firstName ?? 'First name',
                      hintText:
                          localizations?.enterFirstName ?? 'Enter first name'),
                  const SizedBox(height: 16),
                  _buildTextField(
                      controller: _lastNameController,
                      label: localizations?.lastName ?? 'Last name',
                      hintText:
                          localizations?.enterLastName ?? 'Enter last name'),
                  const SizedBox(height: 16),
                  _buildTextField(
                      controller: _emailController,
                      label: localizations?.email ?? 'Email',
                      hintText: localizations?.enterEmail ?? 'Enter email'),
                  const SizedBox(height: 16),
                  _buildPasswordField(controller: _passwordController),
                  const SizedBox(height: 16),
                  _buildTextField(
                      controller: _phoneController,
                      label: localizations?.phoneNumber ?? 'Phone',
                      hintText: localizations?.enterPhone ?? 'Enter phone'),
                  const SizedBox(height: 16),
                  // Conditionally show Department dropdown
                  Visibility(
                    visible: !isRoleWithNoExtraFields,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations?.program ?? 'Program',
                          style: const TextStyle(
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
                                value: 'General', child: Text('General')),
                            DropdownMenuItem(value: 'CE', child: Text('CE')),
                            DropdownMenuItem(value: 'ECE', child: Text('ECE')),
                            DropdownMenuItem(value: 'IE', child: Text('IE')),
                            DropdownMenuItem(value: 'EME', child: Text('EME')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedDepartment = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return localizations?.programRequired ??
                                  'Program is required';
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
                        Text(
                          'Academic Year',
                          style: const TextStyle(
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
                          value: _academicYearController.text.isEmpty
                              ? '1st'
                              : _academicYearController.text,
                          items: const [
                            DropdownMenuItem(
                                value: 'GN', child: Text('General')),
                            DropdownMenuItem(
                                value: '1st', child: Text('1st Year')),
                            DropdownMenuItem(
                                value: '2nd', child: Text('2nd Year')),
                            DropdownMenuItem(
                                value: '3rd', child: Text('3rd Year')),
                            DropdownMenuItem(
                                value: '4th', child: Text('4th Year')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _academicYearController.text = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Academic Year is required';
                            }
                            return null;
                          },
                        ),
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
                          : Text(
                              AppLocalizations.of(context)?.createAccount ??
                                  " Create Account",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),

                  // Add organize sections button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: _organizeStudentSections,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        backgroundColor: const Color(0xFF4B39EF),
                        foregroundColor: Colors.white,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.group_work),
                          SizedBox(width: 8),
                          Text('Organize Students Into Sections'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
    final localizations = AppLocalizations.of(context);

    String localizedLabel = label;
    String localizedHint = hintText;

    // Map common field labels to their localized versions
    if (label == 'Email') {
      localizedLabel = localizations?.email ?? 'Email';
      localizedHint = localizations?.emailHint ?? 'Enter your email';
    } else if (label == 'First name' || label == 'Last name') {
      localizedLabel = localizations?.name ?? 'Name';
      localizedHint = localizations?.nameHint ?? 'Enter your name';
    } else if (label == 'Phone') {
      localizedLabel = localizations?.phoneNumber ?? 'Phone Number';
      localizedHint =
          localizations?.phoneNumberHint ?? 'Enter your phone number';
    } else if (label == 'Date of Birth') {
      localizedLabel = localizations?.dateOfBirth ?? 'Date of Birth';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizedLabel,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: localizedHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return localizations?.requiredField ?? 'This field is required';
            }
            // Add email format validation
            if (label == 'Email') {
              final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegExp.hasMatch(value)) {
                return localizations?.invalidEmail ??
                    'Please enter a valid email address';
              }
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
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.password ?? 'Password',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isPasswordVisible,
          decoration: InputDecoration(
            hintText: localizations?.passwordHint ?? 'Enter Password',
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
              return localizations?.requiredField ?? 'Password is required';
            }
            if (value.length < 15) {
              return localizations?.invalidPassword ??
                  'Password must be at least 15 characters';
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
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.dateOfBirth ?? 'Birth Date',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
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
                  initialDate: DateTime.now().subtract(const Duration(
                      days: 6570)), // Set initial date to 18 years ago
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  // Calculate age
                  final age =
                      DateTime.now().difference(pickedDate).inDays / 365;
                  if (age < 18) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('User must be at least 18 years old')),
                    );
                    return;
                  }
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
          readOnly: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Birth Date is required';
            }
            // Validate age is at least 18
            final birthDate = DateTime.parse(value);
            final age = DateTime.now().difference(birthDate).inDays / 365;
            if (age < 18) {
              return 'User must be at least 18 years old';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Method for organizing students into sections - already uses the new structure logic
  Future<void> _organizeStudentSections() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Organizing students into sections...'),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Call the service method to organize students
      await _scheduleService.organizeStudentsIntoSections();

      // Close the dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All students have been organized into sections!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Close the dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error organizing sections: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
      print('Error organizing sections: $e');
    }
  }
}
