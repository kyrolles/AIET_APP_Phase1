import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ExcelUploadWidget extends StatefulWidget {
  final double height;
  final double width;
  final Function(PlatformFile) onFileSelected;
  final String buttonText;

  const ExcelUploadWidget({
    Key? key,
    this.height = 150.0,
    this.width = 300.0,
    required this.onFileSelected,
    this.buttonText = "Upload Excel Sheet",
  }) : super(key: key);

  @override
  _ExcelUploadWidgetState createState() => _ExcelUploadWidgetState();
}

class _ExcelUploadWidgetState extends State<ExcelUploadWidget> {
  String? fileName;
  bool isUploaded = false;
  bool isUploading = false;

  Future<void> pickExcelFile() async {
    try {
      setState(() {
        isUploading = true;
      });
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        setState(() {
          fileName = file.name;
          isUploaded = true;
          isUploading = false;
        });
        widget.onFileSelected(file);
      } else {
        setState(() {
          isUploading = false;
        });
      }
    } catch (e) {
      print('Error picking Excel file: $e');
      setState(() {
        fileName = null;
        isUploaded = false;
        isUploading = false;
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
          onTap: isUploading ? null : pickExcelFile,
          child: Container(
            height: widget.height * 0.5,
            width: widget.width,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.upload_file,
                    size: widget.height * 0.2, 
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.buttonText,
                    style: const TextStyle(color: Colors.green, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isUploading)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        if (fileName != null && !isUploading)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.table_chart,
                color: Colors.green,
              ),
              title: Text(fileName!),
              subtitle: const Text('Excel file ready for processing'),
              trailing: isUploaded
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
} 