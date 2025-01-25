import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  final String label;
  final bool initialValue;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const CustomCheckbox({
    Key? key,
    required this.label,
    this.initialValue = false,
    required this.onChanged,
    this.activeColor = Colors.blue, // Default active color
  }) : super(key: key);

  @override
  _CustomCheckboxState createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.initialValue;
  }

  void _onCheckboxChanged(bool? value) {
    setState(() {
      isChecked = value ?? false;
    });
    widget.onChanged(isChecked);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          activeColor: widget.activeColor, // Set the color when checked
          onChanged: _onCheckboxChanged,
        ),
        Text(widget.label),
      ],
    );
  }
}
