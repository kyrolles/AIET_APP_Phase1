import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseCheckbox extends StatefulWidget {
  final String collectionPath;
  final Map<String, dynamic> searchCriteria;
  final String fieldName;
  final bool initialValue;

  const FirebaseCheckbox({
    super.key,
    required this.collectionPath,
    required this.searchCriteria,
    required this.fieldName,
    this.initialValue = false,
  });

  @override
  State<FirebaseCheckbox> createState() => _FirebaseCheckboxState();
}

class _FirebaseCheckboxState extends State<FirebaseCheckbox> {
  late bool _isChecked;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;
  }

  Future<void> _updateCheckboxState(bool newValue) async {
    setState(() => _isLoading = true);

    try {
      // Get reference to Firestore
      final firestore = FirebaseFirestore.instance;
      Query query = firestore.collection(widget.collectionPath);

      // Add search conditions
      widget.searchCriteria.forEach((field, value) {
        query = query.where(field, isEqualTo: value);
      });

      // Get matching document
      final querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        // Update the first matching document
        await querySnapshot.docs.first.reference.update({
          widget.fieldName: newValue,
          // 'lastUpdated': FieldValue.serverTimestamp(),
        });

        setState(() => _isChecked = newValue);
      }
    } catch (e) {
      log('Error updating checkbox: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Checkbox(
            value: _isChecked,
            onChanged: (bool? value) {
              if (value != null) {
                _updateCheckboxState(value);
              }
            },
          );
  }
}
