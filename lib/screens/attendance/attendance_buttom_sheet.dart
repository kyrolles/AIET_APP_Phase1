import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';

class Period {
  String number;
  bool isSelected;
  Color color;

  Period({
    required this.number,
    required this.isSelected,
    this.color = Colors.red,
  });
}

class AttendanceButtomSheet extends StatefulWidget {
  AttendanceButtomSheet({super.key});

  List<Period> periods = [
    Period(number: 'P1', isSelected: false, color: const Color(0xFFEB8991)),
    Period(number: 'P2', isSelected: false, color: const Color(0xFF978ECB)),
    Period(number: 'P3', isSelected: false, color: const Color(0xFF0ED290)),
    Period(number: 'P4', isSelected: false, color: const Color(0xFFFFDD29)),
  ];
  @override
  State<AttendanceButtomSheet> createState() => _AttendanceButtomSheetState();
}

class _AttendanceButtomSheetState extends State<AttendanceButtomSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              bottom: 32.0, left: 16.0, right: 16.0, top: 22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  'QR Code',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF6C7072)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Subject Code'),
              const TextField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter the subject code',
                  labelStyle: TextStyle(color: kGrey),
                ),
              ),
              const SizedBox(height: 10),
              const Text('Period'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var period in widget.periods)
                    PeriodButton(
                      period: period,
                      ontap: () {
                        setState(() {
                          for (var p in widget.periods) {
                            p.isSelected = false;
                          }
                          period.isSelected = true;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              MyButton(
                text: 'Generate QR Code',
                onPressed: () {
                  Navigator.pushNamed(context, '/attendance/archive');
                },
                height: 50,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PeriodButton extends StatelessWidget {
  const PeriodButton({
    super.key,
    required this.period,
    this.ontap,
  });

  final Period period;
  final Function()? ontap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: period.isSelected
          ? Container(
              height: 60,
              width: 80,
              decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(14))),
              child: Center(
                child: Container(
                  height: 56,
                  width: 76,
                  decoration: BoxDecoration(
                      color: period.color,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12))),
                  child: Center(
                    child: unPressedSmallButton(),
                  ),
                ),
              ),
            )
          : unPressedSmallButton(),
    );
  }

  Widget unPressedSmallButton() {
    return Container(
      height: 50,
      width: 70,
      decoration: BoxDecoration(
          color: period.color,
          borderRadius: const BorderRadius.all(Radius.circular(12))),
      child: Center(
        child: Text(
          period.number,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    this.onPressed,
    required this.text,
    this.color,
    this.textColor,
    required this.height,
    required this.width,
  });

  final Function()? onPressed;
  final String text;
  final Color? color;
  final Color? textColor;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? kPrimaryColor,
        minimumSize: Size(width, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 21.7,
              fontWeight: FontWeight.w700,
              color: textColor ?? Colors.white)),
    );
  }
}
