import 'package:flutter/material.dart';

class FilterWidget extends StatefulWidget {
  final Function(String? department, String? year, String? type)
      onFilterChanged;
  final List<String> statusList;
  final String? initialDepartment;
  final String? initialYear;
  final String? initialType;

  const FilterWidget({
    super.key,
    required this.onFilterChanged,
    required this.statusList,
    this.initialDepartment,
    this.initialYear,
    this.initialType,
  });

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  String? selectedType;
  String? selectedYear;
  String? selectedDepartment;

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialType ?? 'All';
    selectedYear = widget.initialYear ?? 'All';
    selectedDepartment = widget.initialDepartment ?? 'All';
  }

  String? filterValue(String? value) {
    return value == 'All' ? null : value;
  }

  void applyFilters() {
    widget.onFilterChanged(
      filterValue(selectedDepartment),
      filterValue(selectedYear),
      filterValue(selectedType),
    );
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
          dropdownColor: Colors.white, // Set dropdown menu color to white
          items: [
            'All',
            'Proof of enrollment',
            'Tuition Fees',
            'Grades Report', // Add this
            'Curriculum Content' // Add this
          ].map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedType = value;
            });
            applyFilters();
          },
        ),
        DropdownButton<String>(
          hint: const Text('Department'),
          value: selectedDepartment,
          dropdownColor: Colors.white, // Set dropdown menu color to white
          items: ['All', 'CE', 'EME', 'ECE', 'IE'].map((department) {
            return DropdownMenuItem(value: department, child: Text(department));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedDepartment = value;
            });
            applyFilters();
          },
        ),
        DropdownButton<String>(
          hint: const Text('Year'),
          value: selectedYear,
          dropdownColor: Colors.white, // Set dropdown menu color to white
          items: ['All', 'GN', '1st', '2nd', '3rd', '4th'].map((year) {
            return DropdownMenuItem(value: year, child: Text(year));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedYear = value;
            });
            applyFilters();
          },
        ),
        const Spacer(),
      ],
    );
  }
}
