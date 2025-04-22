import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;

class TemplateDownloader {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Download template from Firebase Storage
  Future<String?> downloadTemplateFromStorage() async {
    try {
      // Reference to the template in Firebase Storage
      final ref = _storage.ref().child('templates/student_grades_template.xlsx');
      
      // Get download URL
      final url = await ref.getDownloadURL();
      
      return url;
    } catch (e) {
      debugPrint('Error downloading template from storage: $e');
      return null;
    }
  }
  
  // Generate a new Excel template
  Future<bool> generateAndSaveTemplate() async {
    try {
      final excel = Excel.createExcel();
      
      // Remove the default sheet
      excel.sheets.remove('Sheet1');
      
      // Create Grades sheet
      final Sheet sheet = excel['Grades'];
      
      // Define header style with light gray background
      final CellStyle headerStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
      );
      
      // Add headers with the new format
      final List<String> headers = [
        'Student ID',
        'Student Name',
        'Course Code',
        '5th-week (out of 8)',
        '10th-week (out of 12)',
        'Classwork (out of 10)',
        'Lab Exam (out of 10)',
        'Final Exam (out of 60)',
        'Total Points'
      ];
      
      // Add header row
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }
      
      // Add example data rows
      _addExampleRow(sheet, 1, [
        '2023001',
        'John Smith',
        'MATH101',
        6.5,
        10.0,
        8.5,
        9.0,
        52.0,
        86.0
      ]);
      
      _addExampleRow(sheet, 2, [
        '2023001',
        'John Smith',
        'PHYS101',
        5.0,
        8.5,
        7.0,
        8.5,
        48.0,
        77.0
      ]);
      
      _addExampleRow(sheet, 3, [
        '2023002',
        'Sara Ahmed',
        'CHEM101',
        7.0,
        11.0,
        9.0,
        null,
        54.0,
        81.0
      ]);
      
      _addExampleRow(sheet, 4, [
        '2023003',
        'Mohammed Ali',
        'CS101',
        7.5,
        10.0,
        null,
        9.5,
        56.0,
        83.0
      ]);
      
      // Auto-size columns
      for (int i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 20);
      }
      
      // Get temporary directory to save file
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;
      final String filePath = path.join(tempPath, 'student_grades_template.xlsx');
      
      // Save the Excel file
      final List<int>? excelBytes = excel.encode();
      if (excelBytes == null) {
        return false;
      }
      
      final File file = File(filePath);
      await file.writeAsBytes(excelBytes);
      
      // Open the file
      final result = await OpenFile.open(filePath);
      return result.type == ResultType.done;
    } catch (e) {
      debugPrint('Error generating template: $e');
      return false;
    }
  }
  
  // Helper to add example row with proper data types
  void _addExampleRow(Sheet sheet, int rowIndex, List<dynamic> values) {
    for (int i = 0; i < values.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
      
      if (values[i] == null) {
        cell.value = TextCellValue('');
      } else if (values[i] is double) {
        cell.value = DoubleCellValue(values[i]);
      } else if (values[i] is int) {
        cell.value = IntCellValue(values[i]);
      } else {
        cell.value = TextCellValue(values[i].toString());
      }
    }
  }
  
  // Upload template to Firebase Storage
  Future<bool> uploadTemplateToStorage() async {
    try {
      // Generate template in memory
      final excel = Excel.createExcel();
      
      // Remove the default sheet
      excel.sheets.remove('Sheet1');
      
      // Create Grades sheet
      final Sheet sheet = excel['Grades'];
      
      // Define header style
      final CellStyle headerStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
      );
      
      // Add headers with the new format
      final List<String> headers = [
        'Student ID',
        'Student Name',
        'Course Code',
        '5th-week (out of 8)',
        '10th-week (out of 12)',
        'Classwork (out of 10)',
        'Lab Exam (out of 10)',
        'Final Exam (out of 60)',
        'Total Points'
      ];
      
      // Add header row
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }
      
      // Add example data rows (same as above)
      _addExampleRow(sheet, 1, [
        '2023001',
        'John Smith',
        'MATH101',
        6.5,
        10.0,
        8.5,
        9.0,
        52.0,
        86.0
      ]);
      
      // Auto-size columns
      for (int i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 20);
      }
      
      // Get temporary directory for temporary file
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;
      final String filePath = path.join(tempPath, 'student_grades_template.xlsx');
      
      // Save the Excel file temporarily
      final List<int>? excelBytes = excel.encode();
      if (excelBytes == null) {
        return false;
      }
      
      final File file = File(filePath);
      await file.writeAsBytes(excelBytes);
      
      // Upload to Firebase Storage
      final ref = _storage.ref().child('templates/student_grades_template.xlsx');
      await ref.putFile(file);
      
      // Delete temporary file
      await file.delete();
      
      return true;
    } catch (e) {
      debugPrint('Error uploading template to storage: $e');
      return false;
    }
  }
} 