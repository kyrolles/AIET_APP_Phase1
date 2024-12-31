import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart'; // For PDF file picking
import 'dart:io';
import 'dart:convert';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/constants.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  _AnnouncementScreenState createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  File? _pdfFile;
  final ImagePicker _picker = ImagePicker();

  // Helper function to format the timestamp
  String _formatTimestamp(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final month = _getMonthName(dateTime.month);
    return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period · $month ${dateTime.day}, ${dateTime.year}';
  }

  // Helper function to get the month name
  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Function to pick a PDF file
  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Allow only PDF files
    );

    if (result != null) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
      });
    }
  }

  // Function to convert file to Base64
  Future<String?> _fileToBase64(File? file) async {
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> postAnnouncement() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title and description')),
      );
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? userName;
        String email = user.email!;

        // Check staffs collection first
        QuerySnapshot staffDocs = await FirebaseFirestore.instance
            .collection('staffs')
            .where('email', isEqualTo: email)
            .get();

        if (staffDocs.docs.isNotEmpty) {
          var nameField = staffDocs.docs.first.get('name');
          userName =
              nameField is List ? nameField.join(' ') : nameField.toString();
        }

        if (userName == null) {
          // If not found in staffs, check teaching_staff
          QuerySnapshot teacherDocs = await FirebaseFirestore.instance
              .collection('teaching_staff')
              .where('email', isEqualTo: email)
              .get();

          if (teacherDocs.docs.isNotEmpty) {
            var nameField = teacherDocs.docs.first.get('name');
            userName =
                nameField is List ? nameField.join(' ') : nameField.toString();
          }
        }

        if (userName != null) {
          // Get the current date and time
          DateTime now = DateTime.now();
          // Format the timestamp
          String formattedTimestamp = _formatTimestamp(now);

          // Convert the image and PDF to Base64
          String? imageBase64 = await _fileToBase64(_image);
          String? pdfBase64 = await _fileToBase64(_pdfFile);

          // Get the PDF file name
          String? pdfFileName = _pdfFile?.path.split('/').last;

          await FirebaseFirestore.instance.collection('announcements').add({
            'title': _titleController.text.trim(),
            'text': _descriptionController.text.trim(),
            'timestamp': formattedTimestamp,
            'author': userName,
            'email': email,
            'imageBase64': imageBase64, // Save the Base64 string (can be null)
            'pdfBase64': pdfBase64, // Save the PDF Base64 string (can be null)
            'pdfFileName': pdfFileName, // Save the PDF file name (can be null)
          });

          _titleController.clear();
          _descriptionController.clear();
          setState(() {
            _image = null;
            _pdfFile = null;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text('Announcement posted successfully!'),
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Only staff members can post announcements')),
          );
        }
      }
    } catch (e) {
      print('Error posting announcement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error posting announcement: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: DecoratedBox(
          decoration: const BoxDecoration(boxShadow: kShadow),
          child: MyAppBar(
            title: 'Services',
            actions: [
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: postAnnouncement,
              ),
            ],
            onpressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Title input field
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _titleController,
                textDirection: _isArabic(_titleController.text)
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Enter announcement title',
                  hintTextDirection: _isArabic(_titleController.text)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            // Description input field
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _descriptionController,
                maxLines: 5,
                textDirection: _isArabic(_descriptionController.text)
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Write your announcement here...',
                  hintTextDirection: _isArabic(_descriptionController.text)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            // Image upload button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _pickImage,
                child: const Text(
                  'Upload Image',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
            // PDF upload button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _pickPDF,
                child: const Text(
                  'Upload PDF',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
            // Display the selected image
            if (_image != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.file(
                  _image!,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            // Display the selected PDF file name
            if (_pdfFile != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Selected PDF: ${_pdfFile!.path.split('/').last}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper function to check if the text is in Arabic
  bool _isArabic(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }
}