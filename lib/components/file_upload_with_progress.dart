import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadWidget extends StatefulWidget {
  final double height;
  final double width;
  final Function(PlatformFile)? onFileSelected;
  final List<String> allowedExtensions; // New attribute for file types
  final String buttonText; // New attribute for custom button text

  const FileUploadWidget({
    Key? key,
    this.height = 150.0,
    this.width = 300.0,
    this.onFileSelected,
    this.allowedExtensions = const [
      'pdf',
      'jpg',
      'jpeg',
      'png'
    ], // Default value
    this.buttonText = "Upload File", // Default value
  }) : super(key: key);

  @override
  _FileUploadWidgetState createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  String? fileName;
  bool isUploaded = false;

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        setState(() {
          fileName = file.name;
          isUploaded = true;
        });
        if (widget.onFileSelected != null) {
          widget.onFileSelected!(file);
        }
      }
    } catch (e) {
      print('Error picking file: $e');
      setState(() {
        fileName = null;
        isUploaded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: pickFile,
          child: Container(
            height: widget.height * 0.5,
            width: widget.width,
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
                  const SizedBox(height: 8),
                  Text(
                    widget.buttonText,
                    style: const TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (fileName != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                fileName?.toLowerCase().endsWith('.pdf') ?? false
                    ? Icons.picture_as_pdf
                    : Icons.insert_drive_file,
                color: Colors.blue,
              ),
              title: Text(fileName!),
              trailing: isUploaded
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
