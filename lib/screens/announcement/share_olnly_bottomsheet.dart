import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/multiselect_widget.dart';
import 'package:graduation_project/constants.dart';

class SharingOptionsBottomSheet extends StatefulWidget {
  final List<String> initialSelectedYears;
  final List<String> initialSelectedDepartments;
  final Function(List<String>, List<String>) onApply;

  const SharingOptionsBottomSheet({
    Key? key,
    required this.initialSelectedYears,
    required this.initialSelectedDepartments,
    required this.onApply,
  }) : super(key: key);

  @override
  State<SharingOptionsBottomSheet> createState() =>
      _SharingOptionsBottomSheetState();
}

class _SharingOptionsBottomSheetState extends State<SharingOptionsBottomSheet> {
  late List<String> _selectedYears;
  late List<String> _selectedDepartments;

  @override
  void initState() {
    super.initState();
    _selectedYears = List.from(widget.initialSelectedYears);
    _selectedDepartments = List.from(widget.initialSelectedDepartments);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Share Only To',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0XFF6C7072),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Years MultiSelect
          MultiSelectWidget(
            options: const ['GN', '1st', '2nd', '3rd', '4th'],
            title: 'Select Years',
            initialSelection: _selectedYears,
            onSelectionChanged: (selectedYears) {
              setState(() {
                _selectedYears = selectedYears;
              });
            },
          ),
          const SizedBox(height: 8),
          // Programs MultiSelect
          MultiSelectWidget(
            options: const ['CE', 'ECE', 'EME', 'IE'],
            title: 'Select Programs',
            initialSelection: _selectedDepartments,
            onSelectionChanged: (selectedDepartments) {
              setState(() {
                _selectedDepartments = selectedDepartments;
              });
            },
          ),
          const SizedBox(height: 24),
          KButton(
            text: 'Apply',
            backgroundColor: kBlue,
            onPressed: () {
              widget.onApply(_selectedYears, _selectedDepartments);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
