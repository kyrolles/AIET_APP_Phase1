import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class StorageService {
  late final FirebaseStorage _storage;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isInitialized = false;

  StorageService() {
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    try {
      // Initialize with the correct bucket from google-services.json
      _storage = FirebaseStorage.instanceFor(
        bucket: 'aiet-application-7d58d.firebasestorage.app',
      );
      
      log('Firebase Storage initialized with bucket: ${_storage.bucket}');
      _isInitialized = true;
    } catch (e) {
      log('Failed to initialize Firebase Storage: $e');
      _isInitialized = false;
    }
  }

  Future<bool> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initializeStorage();
    }
    return _isInitialized;
  }

  /// Gets the current user's UID or throws error if not logged in
  String _getCurrentUserUid() {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw 'User not logged in';
    }
    return user.uid;
  }

  /// Uploads a file to Firebase Storage
  Future<String> uploadFile({
    required File file,
    required String studentUid,
    String? customFileName,
  }) async {
    try {
      await _ensureInitialized();
      
      if (studentUid.isEmpty) {
        throw 'Student UID cannot be empty';
      }
      
      final String fileName = customFileName ?? path.basename(file.path);
      
      // Create reference with explicit path structure
      final Reference fileRef = _storage
          .ref()
          .child('student_files')
          .child(studentUid)
          .child(fileName);
      
      log('Uploading file to: ${fileRef.fullPath}');
      
      // Upload file and await completion
      final TaskSnapshot uploadSnapshot = await fileRef.putFile(file);
      log('Upload completed with state: ${uploadSnapshot.state}');
      
      // Get download URL from the same reference
      if (uploadSnapshot.state == TaskState.success) {
        final String downloadUrl = await fileRef.getDownloadURL();
        log('File uploaded successfully. Download URL: $downloadUrl');
        return downloadUrl;
      } else {
        throw 'Upload completed but with unexpected state: ${uploadSnapshot.state}';
      }
    } catch (e) {
      log('Upload failed with error: $e');
      throw 'Failed to upload file: $e';
    }
  }

  /// Downloads a file from Firebase Storage
  Future<File> downloadFile({
    required String fileUrl,
    required String fileName,
  }) async {
    try {
      await _ensureInitialized();
      
      if (fileUrl.isEmpty) {
        throw 'File URL cannot be empty';
      }
      
      // Get the document directory for saving the file
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/$fileName';
      
      log('Downloading file from: $fileUrl to $filePath');
      
      // Create reference from URL and download
      final Reference ref = _storage.refFromURL(fileUrl);
      final File file = File(filePath);
      await ref.writeToFile(file);
      
      log('File downloaded successfully');
      return file;
    } catch (e) {
      log('Download failed: $e');
      throw 'Failed to download file: $e';
    }
  }

  /// Lists all files for a specific student
  Future<List<Reference>> listFiles(String studentUid) async {
    try {
      await _ensureInitialized();
      
      if (studentUid.isEmpty) {
        throw 'Student UID cannot be empty';
      }
      
      final String folderPath = 'student_files/$studentUid';
      log('Listing files in: $folderPath');
      
      final ListResult result = await _storage.ref(folderPath).listAll();
      log('Found ${result.items.length} files for student $studentUid');
      
      return result.items;
    } catch (e) {
      log('Failed to list files: $e');
      throw 'Failed to list files: $e';
    }
  }

  /// Gets the download URL for a file
  Future<String> getDownloadUrl(String filePath) async {
    try {
      await _ensureInitialized();
      
      log('Getting download URL for: $filePath');
      final String url = await _storage.ref(filePath).getDownloadURL();
      
      return url;
    } catch (e) {
      log('Failed to get download URL: $e');
      throw 'Failed to get download URL: $e';
    }
  }

  /// Deletes a file from storage
  Future<void> deleteFile(String filePath) async {
    try {
      await _ensureInitialized();
      
      log('Deleting file at: $filePath');
      await _storage.ref(filePath).delete();
      log('File deleted successfully');
    } catch (e) {
      log('Failed to delete file: $e');
      throw 'Failed to delete file: $e';
    }
  }
} 