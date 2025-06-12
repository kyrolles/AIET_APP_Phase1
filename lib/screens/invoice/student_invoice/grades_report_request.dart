import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';

// Define the enum for language selection
enum DocumentLanguage { arabic, english }

enum StampType { institute, ministry }

const List<String> countries = [
  'Afghanistan',
  'Albania',
  'Algeria',
  'Andorra',
  'Angola',
  'Antigua and Barbuda',
  'Argentina',
  'Armenia',
  'Australia',
  'Austria',
  'Azerbaijan',
  'Bahamas',
  'Bahrain',
  'Bangladesh',
  'Barbados',
  'Belarus',
  'Belgium',
  'Belize',
  'Benin',
  'Bhutan',
  'Bolivia',
  'Bosnia and Herzegovina',
  'Botswana',
  'Brazil',
  'Brunei',
  'Bulgaria',
  'Burkina Faso',
  'Burundi',
  'Cambodia',
  'Cameroon',
  'Canada',
  'Cape Verde',
  'Central African Republic',
  'Chad',
  'Chile',
  'China',
  'Colombia',
  'Comoros',
  'Congo',
  'Costa Rica',
  'Croatia',
  'Cuba',
  'Cyprus',
  'Czech Republic',
  'Denmark',
  'Djibouti',
  'Dominica',
  'Dominican Republic',
  'East Timor',
  'Ecuador',
  'Egypt',
  'El Salvador',
  'Equatorial Guinea',
  'Eritrea',
  'Estonia',
  'Ethiopia',
  'Fiji',
  'Finland',
  'France',
  'Gabon',
  'Gambia',
  'Georgia',
  'Germany',
  'Ghana',
  'Greece',
  'Grenada',
  'Guatemala',
  'Guinea',
  'Guinea-Bissau',
  'Guyana',
  'Haiti',
  'Honduras',
  'Hungary',
  'Iceland',
  'India',
  'Indonesia',
  'Iran',
  'Iraq',
  'Ireland',
  'Italy',
  'Ivory Coast',
  'Jamaica',
  'Japan',
  'Jordan',
  'Kazakhstan',
  'Kenya',
  'Kiribati',
  'Kuwait',
  'Kyrgyzstan',
  'Laos',
  'Latvia',
  'Lebanon',
  'Lesotho',
  'Liberia',
  'Libya',
  'Liechtenstein',
  'Lithuania',
  'Luxembourg',
  'Madagascar',
  'Malawi',
  'Malaysia',
  'Maldives',
  'Mali',
  'Malta',
  'Marshall Islands',
  'Mauritania',
  'Mauritius',
  'Mexico',
  'Micronesia',
  'Moldova',
  'Monaco',
  'Mongolia',
  'Montenegro',
  'Morocco',
  'Mozambique',
  'Myanmar',
  'Namibia',
  'Nauru',
  'Nepal',
  'Netherlands',
  'New Zealand',
  'Nicaragua',
  'Niger',
  'Nigeria',
  'North Korea',
  'North Macedonia',
  'Norway',
  'Oman',
  'Pakistan',
  'Palau',
  'Palestine',
  'Panama',
  'Papua New Guinea',
  'Paraguay',
  'Peru',
  'Philippines',
  'Poland',
  'Portugal',
  'Qatar',
  'Romania',
  'Russia',
  'Rwanda',
  'Saint Kitts and Nevis',
  'Saint Lucia',
  'Saint Vincent and the Grenadines',
  'Samoa',
  'San Marino',
  'Sao Tome and Principe',
  'Saudi Arabia',
  'Senegal',
  'Serbia',
  'Seychelles',
  'Sierra Leone',
  'Singapore',
  'Slovakia',
  'Slovenia',
  'Solomon Islands',
  'Somalia',
  'South Africa',
  'South Korea',
  'South Sudan',
  'Spain',
  'Sri Lanka',
  'Sudan',
  'Suriname',
  'Swaziland',
  'Sweden',
  'Switzerland',
  'Syria',
  'Taiwan',
  'Tajikistan',
  'Tanzania',
  'Thailand',
  'Togo',
  'Tonga',
  'Trinidad and Tobago',
  'Tunisia',
  'Turkey',
  'Turkmenistan',
  'Tuvalu',
  'Uganda',
  'Ukraine',
  'United Arab Emirates',
  'United Kingdom',
  'United States',
  'Uruguay',
  'Uzbekistan',
  'Vanuatu',
  'Vatican City',
  'Venezuela',
  'Vietnam',
  'Yemen',
  'Zambia',
  'Zimbabwe'
];

class GradesReportRequest extends StatefulWidget {
  const GradesReportRequest({
    super.key,
  });

  @override
  State<GradesReportRequest> createState() => _GradesReportRequest();
}

class _GradesReportRequest extends State<GradesReportRequest> {
  StampType selectedStampType =
      StampType.institute; // Default to institute stamp
  late String studentName;
  late String addressedTo;
  late String location;
  late String phoneNumber;
  DocumentLanguage selectedLanguage =
      DocumentLanguage.arabic; // Default to Arabic
  late String locationOfBirth;
  late String theCause;
  String? selectedCountry; // Add this line

  GlobalKey<FormState> formKey = GlobalKey();

  // Text controllers to clear/validate inputs when language changes
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressedToController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController causeController =
      TextEditingController(); // Add this line

  // Regular expressions for checking Arabic and English text
  final RegExp arabicRegex = RegExp(r'[\u0600-\u06FF\s]+$');
  final RegExp englishRegex = RegExp(r'^[a-zA-Z\s]+$');

  @override
  void dispose() {
    nameController.dispose();
    addressedToController.dispose();
    addressController.dispose();
    phoneController.dispose();
    causeController.dispose(); // Add this line
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

  // Enhanced text field builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required FormFieldValidator<String> validator,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text, // Add this line
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 16),
      keyboardType: keyboardType, // Add this line
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        labelText: label,
        labelStyle:
            const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w500),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: kPrimaryColor),
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
          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  // Enhanced selection section builder
  Widget _buildSelectionSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
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
          Row(
            children: [
              Icon(icon, color: kPrimaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0XFF6C7072),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // Enhanced language card builder
  Widget _buildLanguageCard({
    required DocumentLanguage language,
    required String label,
    required String nativeLabel,
  }) {
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
                Icons.language,
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

  // Enhanced stamp card builder
  Widget _buildStampCard({
    required StampType stampType,
    required String label,
    required IconData icon,
  }) {
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

  // Replace the Location of Birth TextField with this dropdown
  Widget _buildCountryDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCountry,
      isExpanded: true, // Add this to prevent overflow
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        labelText: 'Country of Birth',
        labelStyle: const TextStyle(
          color: kPrimaryColor,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(
          Icons.public_outlined,
          color: kPrimaryColor,
        ),
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
          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      icon: const Icon(Icons.arrow_drop_down, color: kPrimaryColor),
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      dropdownColor: Colors.white,
      menuMaxHeight: 300, // Add this to make the dropdown scrollable
      items: countries.map((String country) {
        return DropdownMenuItem<String>(
          value: country,
          child: Text(
            country,
            overflow: TextOverflow.ellipsis, // Add this to handle long text
          ),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a country';
        }
        return null;
      },
      onChanged: (String? newValue) {
        setState(() {
          selectedCountry = newValue;
          locationOfBirth = newValue ?? '';
        });
      },
    );
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
                : MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 24),

                // Modern Input Fields Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[200]!,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Title
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF6C7072),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name TextField
                      _buildTextField(
                        controller: nameController,
                        label: 'Full Name',
                        hint: selectedLanguage == DocumentLanguage.arabic
                            ? 'يرجى الكتابة باللغة العربية'
                            : 'Please type in English',
                        icon: Icons.person_outline,
                        validator: (value) =>
                            validateLanguageText(value, selectedLanguage),
                        onChanged: (value) => studentName = value,
                      ),

                      const SizedBox(height: 16),

                      // Target Organization TextField
                      _buildTextField(
                        controller: addressedToController,
                        label: 'Organization Name',
                        hint: selectedLanguage == DocumentLanguage.arabic
                            ? 'يرجى الكتابة باللغة العربية'
                            : 'Please type in English',
                        icon: Icons.business_outlined,
                        validator: (value) =>
                            validateLanguageText(value, selectedLanguage),
                        onChanged: (value) => addressedTo = value,
                      ),

                      const SizedBox(height: 16),

                      // Address TextField
                      _buildTextField(
                        controller: addressController, // Use the controller
                        label: 'Address',
                        hint: 'Enter your address',
                        icon: Icons.location_on_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Field is required';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            location = value; // Update in setState
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Phone Number TextField
                      _buildTextField(
                        controller: phoneController, // Use the controller
                        label: 'Phone Number',
                        hint: 'Enter your phone number',
                        icon: Icons.phone_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Field is required';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            phoneNumber = value; // Update in setState
                          });
                        },
                        keyboardType: TextInputType.number, // Add this line
                      ),

                      const SizedBox(height: 16),

                      // Location of Birth Dropdown
                      _buildCountryDropdown(),

                      const SizedBox(height: 16),

                      // The Cause TextField
                      _buildTextField(
                        controller: causeController, // Add the controller
                        label: 'The Cause',
                        hint: 'Enter the cause',
                        icon: Icons.description_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Field is required';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            theCause =
                                value; // Update in setState for consistency
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Modern Language and Stamp Selection
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue[50]!,
                        Colors.blue[100]!.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[200]!,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Document Language Selection
                      _buildSelectionSection(
                        title: 'Document Language',
                        icon: Icons.translate_outlined,
                        child: Row(
                          children: [
                            _buildLanguageCard(
                              language: DocumentLanguage.arabic,
                              label: 'Arabic',
                              nativeLabel: 'العربية',
                            ),
                            const SizedBox(width: 12),
                            _buildLanguageCard(
                              language: DocumentLanguage.english,
                              label: 'English',
                              nativeLabel: 'English',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Stamp Type Selection
                      _buildSelectionSection(
                        title: 'Stamp Type',
                        icon: Icons.verified_outlined,
                        child: Row(
                          children: [
                            _buildStampCard(
                              stampType: StampType.institute,
                              label: 'Institute',
                              icon: Icons.school_outlined,
                            ),
                            const SizedBox(width: 12),
                            _buildStampCard(
                              stampType: StampType.ministry,
                              label: 'Ministry',
                              icon: Icons.account_balance_outlined,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Modern Submit Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        kPrimaryColor,
                        kPrimaryColor.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Submit Request',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Submit form method
  void _submitForm() async {
    if (formKey.currentState!.validate()) {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(width: 16),
              Text('Submitting request...'),
            ],
          ),
          backgroundColor: Color(0xFF0693F1),
          duration: Duration(seconds: 2),
        ),
      );

      String? email = FirebaseAuth.instance.currentUser!.email;

      try {
        final QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        // Convert enums to strings for Firebase storage
        String languageValue =
            selectedLanguage == DocumentLanguage.english ? 'english' : 'arabic';
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
          'pay_in_installments': false,
          'status': 'No Status',
          'student_id': snapshot.docs.first['id'],
          'student_name': studentName,
          'type': 'Grades Report',
          'year': snapshot.docs.first['academicYear'],
          'created_at': Timestamp.now(),
          'location': location,
          'phone_number': phoneNumber,
          'document_language': languageValue,
          'stamp_type': stampTypeValue,
          'department': snapshot.docs.first['department'],
          'birth_date': snapshot.docs.first['birthDate'],
          'the_cause': theCause,
          'location_of_birth': locationOfBirth,
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
  }
}
