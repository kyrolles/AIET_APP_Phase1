import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/models/request_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PDFService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Selected PDF file
  File? selectedPDFFile;
  String? selectedFileName;

  // Pick PDF file
  Future<bool> pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        selectedPDFFile = File(result.files.single.path!);
        selectedFileName = result.files.single.name;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error picking PDF: $e');
      return false;
    }
  }

  // Upload PDF to Firebase Storage and save reference in Firestore
  Future<String?> uploadPDFAndSaveReference(
      String collectionName, Request request) async {
    if (selectedPDFFile == null) {
      return null;
    }

    try {
      // Generate a unique file name using timestamp
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$selectedFileName';

      // Create a reference to the file location in Firebase Storage
      final Reference storageRef = _storage.ref().child('requests/$fileName');

      //?---------------------------------------------------------------
      ///? the error is in this line
      ///? and the error is :
      ///? Error getting App Check token; using placeholder token instead. Error: com.google.firebase.FirebaseException: No AppCheckProvider installed.
      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(selectedPDFFile!);
      //?---------------------------------------------------------------

      // Wait for the upload to complete
      final TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();
      // Continue with your code...

      // Create document data with the PDF URL and additional data
      // final Map<String, dynamic> documentData = {
      //   'pdfUrl': downloadURL,
      //   'fileName': selectedFileName,
      //   'uploadedAt': FieldValue.serverTimestamp(),
      //   ...additionalData,
      // };

      // Add document to Firestore
      // final DocumentReference docRef =
      //     await _firestore.collection(collectionName).add(documentData);

      late DocumentReference docRef;

      Future<void> updateDocument({
        //* Update a document in Firestore
        required String collectionPath,
        required Map<String, dynamic> searchCriteria,
        required Map<String, dynamic> newData,
      }) async {
        try {
          //* Start with the collection reference
          Query query = _firestore.collection(collectionPath);

          //* Add all search conditions
          searchCriteria.forEach((field, value) {
            query = query.where(field, isEqualTo: value);
          });

          //* Get the documents that match your criteria
          QuerySnapshot querySnapshot = await query.get();

          docRef = querySnapshot.docs.first.reference;

          //* Update the first matching document
          if (querySnapshot.docs.isNotEmpty) {
            await querySnapshot.docs.first.reference.update(newData);
          }
          log('Document updated successfully');
        } catch (e) {
          log('Error updating document: $e');
        }
      }

      // update document in Firestore
      updateDocument(
        collectionPath: 'requests',
        searchCriteria: {
          'student_id': request.studentId,
          'type': 'Tuition Fees',
          'created_at': request.createdAt,
        },
        newData: {
          'file_name': selectedFileName,
          'pdfBase64': downloadURL, //! Here is the pdf base 64
          'status': 'Done',
        },
      );

      // Reset selected file
      selectedPDFFile = null;
      selectedFileName = null;

      return docRef.id;
    } catch (e) {
      log('Error uploading PDF: $e');
      return null;
    }
  }

  // Download PDF function
  Future<String?> downloadPDF(String pdfUrl, String fileName) async {
    try {
      // Request storage permissions
      final status = await Permission.storage.request();

      if (status.isGranted) {
        // Get appropriate directory based on platform
        Directory? downloadsDirectory;
        if (Platform.isAndroid) {
          downloadsDirectory = Directory('/storage/emulated/0/Download');
        } else if (Platform.isIOS) {
          downloadsDirectory = await getApplicationDocumentsDirectory();
        }

        if (downloadsDirectory != null) {
          final String filePath = '${downloadsDirectory.path}/$fileName';

          // Download file using Dio
          final dio = Dio();
          await dio.download(pdfUrl, filePath,
              onReceiveProgress: (received, total) {
            if (total != -1) {
              // Calculate progress (you can use a stream to update UI)
              final progress = (received / total * 100).toStringAsFixed(0);
              debugPrint('Download progress: $progress%');
            }
          });

          return filePath;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      return null;
    }
  }
}
