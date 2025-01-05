import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  //required TextEditingController controller;
  final String label;
  final String hintText;
  final bool isRequired; // Optional parameter with a default value of false

  const CustomTextField({
    super.key,
    //this.controller,
    required this.label,
    required this.hintText,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black, // Static black color for the label
          ),
        ),
        // const SizedBox(height: 8),
        TextFormField(
          //controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          validator: (value) {
            // Validate only if the field is required
            if (isRequired && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}
