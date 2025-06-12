import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/screens/drawer/uplod_image_buttom_sheet.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:convert';

class QrcodeScreen extends StatefulWidget {
  const QrcodeScreen({super.key});

  @override
  State<QrcodeScreen> createState() => _QrcodeScreenState();
}

class _QrcodeScreenState extends State<QrcodeScreen> {
  bool _isGeneratingQR = false;

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> userData = {
          ...doc.data()!,
          'uid': user.uid,
        };

        // Check if we need to generate and store a new QR code
        String studentId = userData['id']?.toString() ?? '';
        if (studentId.isNotEmpty &&
            (userData['qrCode'] == null || userData['qrCode'] != studentId)) {
          if (!_isGeneratingQR) {
            _isGeneratingQR = true;
            // Generate and store the QR code
            await _generateAndStoreQRCode(user.uid, studentId);
            _isGeneratingQR = false;
            // Refresh the data
            return _getUserData();
          }
        }

        return userData;
      }
    }
    return null;
  }

  Future<void> _generateAndStoreQRCode(String uid, String studentId) async {
    try {
      if (studentId.isEmpty) {
        throw 'Student ID is empty';
      }

      // Store the student ID as the QR code data
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'qrCode': studentId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR Code updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating QR code: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/ID.svg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      localizations?.id ?? 'ID',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          Center(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final localizations = AppLocalizations.of(context);
                final userData = snapshot.data;
                final firstName = userData?['firstName'] ??
                    (localizations?.loading ?? "Loading...");
                final lastName = userData?['lastName'] ??
                    (localizations?.loading ?? "Loading...");
                final name = "$firstName $lastName";
                final department = userData?['department'] ??
                    (localizations?.loading ?? "Loading...");
                final studentId =
                    userData?['id'] ?? (localizations?.loading ?? "Loading...");
                final year =
                    "${userData?['academicYear'] ?? (localizations?.loading ?? 'Loading...')}";
                final imageBase64 = userData?['profileImage'];

                return Column(
                  children: [
                    const SizedBox(height: 100),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          backgroundColor:
                              const Color.fromRGBO(250, 250, 250, 1),
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (BuildContext context) {
                            return const UploadProfileImageBottomSheet();
                          },
                        );
                      },
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 78,
                          backgroundColor: Colors.grey[200],
                          child: imageBase64 != null
                              ? ClipOval(
                                  child: Image.memory(
                                    base64Decode(imageBase64),
                                    fit: BoxFit.cover,
                                    width: 156,
                                    height: 156,
                                    errorBuilder: (context, error, stackTrace) {
                                      debugPrint(
                                          'Error displaying image: $error');
                                      return const Icon(Icons.person, size: 50);
                                    },
                                  ),
                                )
                              : const Icon(Icons.person, size: 50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      department,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 30,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            studentId,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 19),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0XFFFF8504),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            year,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 19),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        // Make sure we always have valid data for the QR code
                        data: (userData?['qrCode'] ?? studentId)
                                .toString()
                                .isNotEmpty
                            ? (userData?['qrCode'] ?? studentId).toString()
                            : (localizations?.noIdAvailable ??
                                "No ID available"),
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
