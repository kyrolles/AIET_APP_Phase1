import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/constants.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(String?) onYearSelected;
  final String? currentYear;

  const FilterBottomSheet({
    Key? key,
    required this.onYearSelected,
    this.currentYear,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? selectedYear;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.currentYear;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              bottom: 12.0, left: 16.0, right: 16.0, top: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  'Filter By Year',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0XFF6C7072),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // Year options INSIDE the Column children array
              RadioListTile<String?>(
                radioScaleFactor: 1.2,
                visualDensity: const VisualDensity(
                  horizontal: VisualDensity.minimumDensity,
                ),
                title: Text('All Years',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: selectedYear == null ? kBlue : Colors.black)),
                value: null,
                groupValue: selectedYear,
                activeColor: kBlue,
                // selectedTileColor: kbabyblue.withOpacity(0.2),
                contentPadding: const EdgeInsets.symmetric(horizontal: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: selectedYear == null
                      ? BorderSide(color: kBlue, width: 1)
                      : BorderSide.none,
                ),
                dense: false,
                onChanged: (value) {
                  setState(() {
                    selectedYear = value;
                  });
                },
              ),

              RadioListTile<String>(
                radioScaleFactor: 1.2,
                visualDensity: const VisualDensity(
                  vertical: VisualDensity.minimumDensity,
                  horizontal: VisualDensity.minimumDensity,
                ),
                title: Text('GN',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: selectedYear == 'GN' ? kBlue : Colors.black)),
                value: 'GN',
                groupValue: selectedYear,
                activeColor: kBlue,
                selectedTileColor: kbabyblue.withOpacity(0.2),
                contentPadding: const EdgeInsets.symmetric(horizontal: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: selectedYear == 'GN'
                      ? BorderSide(color: kBlue, width: 1)
                      : BorderSide.none,
                ),
                dense: false,
                onChanged: (value) {
                  setState(() {
                    selectedYear = value;
                  });
                },
              ),

              RadioListTile<String>(
                radioScaleFactor: 1.2,
                visualDensity: const VisualDensity(
                  vertical: VisualDensity.minimumDensity,
                  horizontal: VisualDensity.minimumDensity,
                ),
                title: Text('1st',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: selectedYear == '1st' ? kBlue : Colors.black)),
                value: '1st',
                groupValue: selectedYear,
                activeColor: kBlue,
                selectedTileColor: kbabyblue.withOpacity(0.2),
                contentPadding: const EdgeInsets.symmetric(horizontal: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: selectedYear == '1st'
                      ? BorderSide(color: kBlue, width: 1)
                      : BorderSide.none,
                ),
                dense: false,
                onChanged: (value) {
                  setState(() {
                    selectedYear = value;
                  });
                },
              ),

              RadioListTile<String>(
                radioScaleFactor: 1.2,
                visualDensity: const VisualDensity(
                  vertical: VisualDensity.minimumDensity,
                  horizontal: VisualDensity.minimumDensity,
                ),
                title: Text('2nd',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: selectedYear == '2nd' ? kBlue : Colors.black)),
                value: '2nd',
                groupValue: selectedYear,
                activeColor: kBlue,
                selectedTileColor: kbabyblue.withOpacity(0.2),
                contentPadding: const EdgeInsets.symmetric(horizontal: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: selectedYear == '2nd'
                      ? const BorderSide(color: kBlue, width: 1)
                      : BorderSide.none,
                ),
                dense: false,
                onChanged: (value) {
                  setState(() {
                    selectedYear = value;
                  });
                },
              ),

              RadioListTile<String>(
                radioScaleFactor: 1.2,
                visualDensity: const VisualDensity(
                  vertical: VisualDensity.minimumDensity,
                  horizontal: VisualDensity.minimumDensity,
                ),
                title: Text('3rd',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: selectedYear == '3rd' ? kBlue : Colors.black)),
                value: '3rd',
                groupValue: selectedYear,
                activeColor: kBlue,
                selectedTileColor: kbabyblue.withOpacity(0.2),
                contentPadding: const EdgeInsets.symmetric(horizontal: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: selectedYear == '3rd'
                      ? const BorderSide(color: kBlue, width: 1)
                      : BorderSide.none,
                ),
                dense: false,
                onChanged: (value) {
                  setState(() {
                    selectedYear = value;
                  });
                },
              ),

              RadioListTile<String>(
                radioScaleFactor: 1.2,
                visualDensity: const VisualDensity(
                  vertical: VisualDensity.minimumDensity,
                  horizontal: VisualDensity.minimumDensity,
                ),
                title: Text('4th',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: selectedYear == '4th' ? kBlue : Colors.black)),
                value: '4th',
                groupValue: selectedYear,
                activeColor: kBlue,
                selectedTileColor: kbabyblue.withOpacity(0.2),
                contentPadding: const EdgeInsets.symmetric(horizontal: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: selectedYear == '4th'
                      ? BorderSide(color: kBlue, width: 1)
                      : BorderSide.none,
                ),
                dense: false,
                onChanged: (value) {
                  setState(() {
                    selectedYear = value;
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              KButton(
                text: 'Apply',
                backgroundColor: kBlue,
                onPressed: () {
                  widget.onYearSelected(selectedYear);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
