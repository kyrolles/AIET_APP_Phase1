import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FileUploadWidget extends StatefulWidget {
  final double height;
  final double width;

  const FileUploadWidget({
    Key? key,
    this.height = 150.0, // Default height
    this.width = 300.0, // Default width
  }) : super(key: key);

  @override
  _FileUploadWidgetState createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  double progress = 0.0;
  String? fileName;
  String? downloadUrl;

  Future<void> pickAndUploadFile() async {
    // Pick a file
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final file = result.files.single;

      // Update file name
      setState(() {
        fileName = file.name;
      });

      // Upload to Firebase Storage
      final storageRef =
          FirebaseStorage.instance.ref().child("uploads/${file.name}");
      final uploadTask = storageRef.putFile(
        File(filePath),
        SettableMetadata(contentType: file.extension),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((taskSnapshot) {
        setState(() {
          progress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
        });
      });

      // Get download URL after successful upload
      final snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();

      setState(() {
        downloadUrl = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upload Button
          GestureDetector(
            onTap: pickAndUploadFile,
            child: Container(
              height: widget.height * 0.5, // Adjust height proportionally
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_upload,
                        size: widget.height * 0.2, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      "Upload Logo",
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16),

          // File Added Section
          if (fileName != null)
            Text(
              "File added: $fileName",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          SizedBox(height: 16),

          // Progress Indicator
          if (fileName != null)
            ListTile(
              leading: Icon(Icons.insert_drive_file, color: Colors.blue),
              title: Text(fileName!),
              subtitle: LinearProgressIndicator(value: progress),
              trailing: progress == 1.0
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : Text("${(progress * 100).toInt()}%"),
            ),
        ],
      ),
    );
  }
}
