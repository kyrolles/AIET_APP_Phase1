import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';

// Define the enum for language selection
enum DocumentLanguage { arabic, english }

enum StampType { institute, ministry }

class CurriculumContentRequest extends StatefulWidget {
  const CurriculumContentRequest({
    super.key,
  });

  @override
  State<CurriculumContentRequest> createState() => _CurriculumContentRequest();
}

class _CurriculumContentRequest extends State<CurriculumContentRequest> {
  StampType selectedStampType =
      StampType.institute; // Default to institute stamp
  late String studentName;
  late String addressedTo;
  late String location;
  late String phoneNumber;
  DocumentLanguage selectedLanguage =
      DocumentLanguage.arabic; // Default to Arabic

  GlobalKey<FormState> formKey = GlobalKey();

  // Text controllers to clear/validate inputs when language changes
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressedToController = TextEditingController();

  // Regular expressions for checking Arabic and English text
  final RegExp arabicRegex = RegExp(r'[\u0600-\u06FF\s]+$');
  final RegExp englishRegex = RegExp(r'^[a-zA-Z\s]+$');

  @override
  void dispose() {
    nameController.dispose();
    addressedToController.dispose();
    super.dispose();
  }

  // Validate text based on selected language
  String? validateLanguageText(String? value, DocumentLanguage language) {
    if (value == null || value.isEmpty) {
      return 'Field is required';
    }

    if (language == DocumentLanguage.arabic && !arabicRegex.hasMatch(value)) {
      return 'Please enter text in Arabic';
    } else if (language == DocumentLanguage.english &&
        !englishRegex.hasMatch(value)) {
      return 'Please enter text in English';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 8.0,
            bottom: MediaQuery.of(context).viewInsets.bottom == 0
                ? 16
                : MediaQuery.of(context)
                    .viewInsets
                    .bottom, //!this line will make padding when the keyboard is shown = the height of the keyboard
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kPrimaryColor.withOpacity(0.8), kPrimaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.description, color: Colors.white, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Curriculum Content',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Name TextField with enhanced design
                TextFormField(
                  controller: nameController,
                  validator: (value) =>
                      validateLanguageText(value, selectedLanguage),
                  onChanged: (value) {
                    studentName = value;
                  },
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    labelText: 'Enter Your Name',
                    labelStyle: const TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.w500),
                    hintText: selectedLanguage == DocumentLanguage.arabic
                        ? 'يرجى الكتابة باللغة العربية'
                        : 'Please type in English',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: const Icon(Icons.person, color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: kPrimaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // Target Organization TextField with enhanced design
                TextFormField(
                  controller: addressedToController,
                  validator: (value) =>
                      validateLanguageText(value, selectedLanguage),
                  onChanged: (value) {
                    addressedTo = value;
                  },
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    labelText: "Enter the target organization",
                    labelStyle: const TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.w500),
                    hintText: selectedLanguage == DocumentLanguage.arabic
                        ? 'يرجى الكتابة باللغة العربية'
                        : 'Please type in English',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon:
                        const Icon(Icons.business, color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: kPrimaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // Address TextField with enhanced design
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Field is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    location = value;
                  },
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    labelText: 'Enter Your Address',
                    labelStyle: const TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.w500),
                    prefixIcon:
                        const Icon(Icons.location_on, color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: kPrimaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // Phone Number TextField with enhanced design
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Field is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    phoneNumber = value;
                  },
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    labelText: 'Enter Your Phone Number',
                    labelStyle: const TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.w500),
                    prefixIcon: const Icon(Icons.phone, color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: kPrimaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 20),
                // Stamp Type Selection with enhanced design
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.verified, color: kPrimaryColor),
                          SizedBox(width: 8),
                          Text(
                            'Stamp Type',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0XFF6C7072),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          stampTypeCard('Institute Stamp', StampType.institute,
                              Icons.school),
                          const SizedBox(width: 16),
                          stampTypeCard('Ministry Stamp', StampType.ministry,
                              Icons.account_balance),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Document Language Selection with enhanced design
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.language, color: kPrimaryColor),
                          SizedBox(width: 8),
                          Text(
                            'Document Language',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0XFF6C7072),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          languageSelectionCard('Arabic', 'العربية',
                              DocumentLanguage.arabic, Icons.translate),
                          const SizedBox(width: 16),
                          languageSelectionCard('English', 'English',
                              DocumentLanguage.english, Icons.language),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Enhanced submit button with loading state
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.only(top: 8),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        // Show loading indicator
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                                SizedBox(width: 16),
                                Text('Submitting request...'),
                              ],
                            ),
                            backgroundColor: Color(0xFF0693F1),
                            duration: Duration(seconds: 2),
                          ),
                        );

                        String? email =
                            FirebaseAuth.instance.currentUser!.email;

                        try {
                          final QuerySnapshot snapshot = await FirebaseFirestore
                              .instance
                              .collection('users')
                              .where('email', isEqualTo: email)
                              .get();

                          // Convert enums to strings for Firebase storage
                          String languageValue =
                              selectedLanguage == DocumentLanguage.english
                                  ? 'english'
                                  : 'arabic';
                          String stampTypeValue;

                          switch (selectedStampType) {
                            case StampType.ministry:
                              stampTypeValue = 'ministry';
                              break;
                            case StampType.institute:
                              stampTypeValue = 'institute';
                              break;
                          }

                          await FirebaseFirestore.instance
                              .collection('student_affairs_requests')
                              .add({
                            'addressed_to': addressedTo,
                            'comment': '',
                            'file_name': '',
                            'pdfBase64': '',
                            'pay_in_installments': false,
                            'status': 'No Status',
                            'student_id': snapshot.docs.first['id'],
                            'student_name': studentName,
                            'training_score': 0,
                            'type': 'Curriculum Content',
                            'year': snapshot.docs.first['academicYear'],
                            'created_at': Timestamp.now(),
                            'location': location,
                            'phone_number': phoneNumber,
                            'document_language': languageValue,
                            'stamp_type': stampTypeValue,
                            'department': snapshot.docs.first['department']
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 16),
                                  Text('Request sent successfully'),
                                ],
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.error, color: Colors.white),
                                  const SizedBox(width: 16),
                                  Text('Error: ${e.toString()}'),
                                ],
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0693F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      shadowColor: const Color(0xFF0693F1).withOpacity(0.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Submit Request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced stamp type selection card
  Expanded stampTypeCard(String label, StampType stampType, IconData icon) {
    bool isSelected = selectedStampType == stampType;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedStampType = stampType;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? kPrimaryColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? kPrimaryColor : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? kPrimaryColor : Colors.grey[800],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Enhanced language selection card
  Expanded languageSelectionCard(String label, String nativeLabel,
      DocumentLanguage language, IconData icon) {
    bool isSelected = selectedLanguage == language;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedLanguage = language;
            // Clear fields when language changes to force re-entry in correct language
            nameController.clear();
            addressedToController.clear();
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? kPrimaryColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? kPrimaryColor : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? kPrimaryColor : Colors.grey[800],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              Text(
                nativeLabel,
                style: TextStyle(
                  color: isSelected ? kPrimaryColor : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
