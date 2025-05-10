import 'package:flutter/material.dart';

class MultiSelectWidget extends StatefulWidget {
  final List<String> options;
  final String title;
  final Function(List<String>) onSelectionChanged;
  final List<String> initialSelection;
  final Color selectedColor;
  final Color unselectedColor;
  final Color borderColor;

  const MultiSelectWidget({
    super.key,
    required this.options,
    required this.title,
    required this.onSelectionChanged,
    this.initialSelection =
        const [], // Add initialSelection parameter with empty default
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.borderColor = Colors.black,
  });

  @override
  State<MultiSelectWidget> createState() => _MultiSelectWidgetState();
}

class _MultiSelectWidgetState extends State<MultiSelectWidget> {
  late List<String> _selectedOptions;

  @override
  void initState() {
    super.initState();
    // Initialize selected options with the provided initialSelection
    _selectedOptions = List.from(widget.initialSelection);
  }

  @override
  void didUpdateWidget(MultiSelectWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected options if initialSelection changes from outside
    if (widget.initialSelection != oldWidget.initialSelection) {
      setState(() {
        _selectedOptions = List.from(widget.initialSelection);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              )),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: widget.options.map((option) {
              final isSelected = _selectedOptions.contains(option);
              return FilterChip(
                label: Text(
                  option,
                  style: TextStyle(
                      color: isSelected ? Colors.black : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 18),
                ),
                selected: isSelected,
                showCheckmark: false, // Remove checkmark
                selectedColor: widget.selectedColor,
                backgroundColor: Colors
                    .blueGrey[100], // Light grey background when not selected
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: isSelected ? widget.borderColor : Colors.transparent,
                    width: isSelected ? 2 : 0,
                  ),
                ),
                elevation:
                    isSelected ? 3 : 0, // Add slight elevation when selected
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedOptions.add(option);
                    } else {
                      _selectedOptions.remove(option);
                    }
                    widget.onSelectionChanged(_selectedOptions);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
