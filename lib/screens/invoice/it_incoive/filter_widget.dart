import 'package:flutter/material.dart';

class FilterWidget extends StatefulWidget {
  final Function(String? dapertment, String? year, String? type)
      onFilterChanged;

  const FilterWidget({super.key, required this.onFilterChanged});

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  String? selectedType = 'All';
  String? selectedYear = 'All';
  String? selectedDepartment = 'All';

  String? filterValue(String? value) {
    return value == 'All' ? null : value;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Spacer(),
        DropdownButton<String>(
          hint: const Text('Type'),
          value: selectedType,
          items: ['All', 'Proof of enrollment', 'Tuition Fees'].map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedType = value;
            });
            widget.onFilterChanged(
              filterValue(selectedDepartment),
              filterValue(selectedYear),
              filterValue(selectedType),
            );
          },
        ),
        DropdownButton<String>(
          hint: const Text('Department'),
          value: selectedDepartment,
          items: ['All', 'CE', 'EME', 'ECE', 'IE'].map((department) {
            return DropdownMenuItem(value: department, child: Text(department));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedDepartment = value;
            });
            widget.onFilterChanged(
              filterValue(selectedDepartment),
              filterValue(selectedYear),
              filterValue(selectedType),
            );
          },
        ),
        DropdownButton<String>(
          hint: const Text('Year'),
          value: selectedYear,
          items: ['All', 'GN', '1st', '2nd', '3rd', '4th'].map((year) {
            return DropdownMenuItem(value: year, child: Text(year));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedYear = value;
            });
            widget.onFilterChanged(
              filterValue(selectedDepartment),
              filterValue(selectedYear),
              filterValue(selectedType),
            );
          },
        ),
        const Spacer(),
      ],
    );
  }
}
