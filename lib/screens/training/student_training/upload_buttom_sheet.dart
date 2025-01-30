import 'package:flutter/material.dart';
import 'package:graduation_project/components/file_upload_with_progress.dart';
import 'package:graduation_project/components/kbutton.dart';

class UploadButtomSheet extends StatelessWidget {
  const UploadButtomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: const SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: 32.0, left: 16.0, right: 16.0, top: 22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              Center(
                child: Text(
                  'Submit Training',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF6C7072)),
                ),
              ),
              KButton(
                text: 'Upload pdf',
                padding: EdgeInsets.all(0),
                backgroundColor: Colors.transparent,
                textColor: Colors.lightBlueAccent,
                borderColor: Colors.lightBlueAccent,
                borderWidth: 3,
                // onPressed: _pickPDF,
              ),
              FileUploadWidget(
                height: 350,
                width: double.infinity, // Full width
              ),
            ],
          ),
        ),
      ),
    );
  }
}
