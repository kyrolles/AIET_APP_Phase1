import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'package:graduation_project/components/checkbox_with_label.dart';
import 'package:graduation_project/components/file_upload_with_progress.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/my_app_bar.dart';

class CreateAnnouncement extends StatefulWidget {
  const CreateAnnouncement({super.key});

  @override
  State<CreateAnnouncement> createState() => _CreateAnnouncementState();
}

class _CreateAnnouncementState extends State<CreateAnnouncement> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _linksController = TextEditingController();
  String? _logoBase64;
  String? _imageBase64;
  final Map<String, bool> _selectedDepartments = {
    'Computer': false,
    'Mechatronics': false,
    'Communication & Electronics': false,
    'Industrial': false,
  };

  Future<void> _saveAnnouncement() async {
    try {
      if (_companyNameController.text.isEmpty) {
        throw 'Company name is required';
      }

      if (_logoBase64 == null) {
        throw 'Logo is required';
      }

      print('Logo base64: ${_logoBase64?.substring(0, 50)}...'); // Debug print

      await FirebaseFirestore.instance.collection('training_announcements').add({
        'companyName': _companyNameController.text,
        'description': _descriptionController.text,
        'links': _linksController.text,
        'logo': _logoBase64,
        'image': _imageBase64,
        'departments': _selectedDepartments.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement saved successfully!')),
      );
    } catch (e) {
      print('Error saving announcement: $e'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          title: 'Create Announcement',
          onpressed: () => Navigator.pop(context),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity, // Full width
                      alignment:
                          Alignment.topLeft, // Align text to the top-left
                      child: const Text(
                        '1. Company Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Company Name',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity, // Full width
                      alignment:
                          Alignment.topLeft, // Align text to the top-left
                      child: const Text(
                        '2. Description',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity, // Make it full-width
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 8, // Adjust for height
                        decoration: InputDecoration(
                          hintText: "Enter company description....",
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Rounded corners
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20, // Add padding to make it spacious
                            horizontal: 15, // Padding on the sides
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity, // Full width
                      alignment:
                          Alignment.topLeft, // Align text to the top-left
                      child: const Text(
                        '3. Important links:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity, // Make it full-width
                      child: TextField(
                        controller: _linksController,
                        maxLines: 5, // Adjust for height
                        decoration: InputDecoration(
                          hintText: "Enter company description....",
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Rounded corners
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20, // Add padding to make it spacious
                            horizontal: 15, // Padding on the sides
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity, // Full width
                      alignment:
                          Alignment.topLeft, // Align text to the top-left
                      child: const Text(
                        '4. Upload Logo:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    FileUploadWidget(
                      height: 350,
                      width: double.infinity,
                      onFileSelected: (file) async {
                        try {
                          if (file.path != null) {
                            final bytes = await File(file.path!).readAsBytes();
                            final base64String = base64Encode(bytes);
                            setState(() {
                              _logoBase64 = base64String;
                            });
                            print('Logo encoded successfully'); // Debug print
                          }
                        } catch (e) {
                          print('Error encoding logo: $e'); // Debug print
                        }
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity, // Full width
                      alignment:
                          Alignment.topLeft, // Align text to the top-left
                      child: const Text(
                        '5. Upload Image(Optionalfor the profile):',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    FileUploadWidget(
                      height: 350,
                      width: double.infinity, // Full width
                      onFileSelected: (file) async {
                        final bytes = await File(file.path!).readAsBytes();
                        setState(() {
                          _imageBase64 = base64Encode(bytes);
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity, // Full width
                      alignment:
                          Alignment.topLeft, // Align text to the top-left
                      child: const Text(
                        '6. Share Announcement to Department:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomCheckbox(
                      label: "Computer",
                      onChanged: (value) {
                        setState(() => _selectedDepartments['Computer'] = value);
                      },
                    ),
                    CustomCheckbox(
                      label: "Mechatronics",
                      onChanged: (value) {
                        setState(() => _selectedDepartments['Mechatronics'] = value);
                      },
                    ),
                    CustomCheckbox(
                      label: "Communication & Electronics",
                      onChanged: (value) {
                        setState(() => _selectedDepartments['Communication & Electronics'] = value);
                      },
                    ),
                    CustomCheckbox(
                      label: "Industrial",
                      onChanged: (value) {
                        setState(() => _selectedDepartments['Industrial'] = value);
                      },
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                    KButton(
                      backgroundColor: const Color.fromRGBO(6, 147, 241, 1),
                      text: 'post',
                      padding: const EdgeInsets.all(0),
                      onPressed: _saveAnnouncement,
                    )
                  ],
                ))));
  }
}
