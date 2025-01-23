import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/list_container.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/student_container.dart';
import 'package:graduation_project/screens/training/staff_training/validate_buttom_sheet.dart';

class ValidateScreen extends StatelessWidget {
  ValidateScreen({super.key});

  final List<Widget> studentreques = [
    StudentContainer(
        onTap: (BuildContext context) {
          showModalBottomSheet(
            backgroundColor: const Color.fromRGBO(250, 250, 250, 0.93),
            context: context,
            scrollControlDisabledMaxHeightRatio: 0.8,
            builder: (BuildContext context) {
              return const ValidateButtomSheet();
            },
          );
        },
        name: 'Kyrolles Raafat',
        status: 'pending',
        statusColor: Colors.yellow,
        id: '20-0-60785',
        year: '4th',
        title: 'EGSA.pdf',
        image: 'assets/project_image/pdf.png'),
    StudentContainer(
        onTap: (BuildContext context) {
          showModalBottomSheet(
            backgroundColor: const Color.fromRGBO(250, 250, 250, 0.93),
            context: context,
            scrollControlDisabledMaxHeightRatio: 0.8,
            builder: (BuildContext context) {
              return const ValidateButtomSheet();
            },
          );
        },
        name: 'Mahmoud Abdelnaserrrrrrrrr',
        status: 'pending',
        statusColor: Colors.yellow,
        id: '20-0-60785',
        year: '4th',
        title: 'EGSA.pdf',
        image: 'assets/project_image/pdf.png'),
    StudentContainer(
        onTap: (BuildContext context) {
          showModalBottomSheet(
            backgroundColor: const Color.fromRGBO(250, 250, 250, 0.93),
            context: context,
            scrollControlDisabledMaxHeightRatio: 0.8,
            builder: (BuildContext context) {
              return const ValidateButtomSheet();
            },
          );
        },
        name: 'Youssef Abdelfatah',
        status: 'Done',
        statusColor: Colors.green,
        id: '20-0-60785',
        year: '4th',
        title: 'EGSA.pdf',
        image: 'assets/project_image/pdf.png'),
    StudentContainer(
        onTap: (BuildContext context) {
          showModalBottomSheet(
            backgroundColor: const Color.fromRGBO(250, 250, 250, 0.93),
            context: context,
            scrollControlDisabledMaxHeightRatio: 0.8,
            builder: (BuildContext context) {
              return const ValidateButtomSheet();
            },
          );
        },
        name: 'Youssef Abdelfatah',
        status: 'Rejected',
        statusColor: Colors.red,
        id: '20-0-60785',
        year: '4th',
        title: 'EGSA.pdf',
        image: 'assets/project_image/pdf.png'),
    StudentContainer(
        onTap: (BuildContext context) {
          showModalBottomSheet(
            backgroundColor: const Color.fromRGBO(250, 250, 250, 0.93),
            context: context,
            scrollControlDisabledMaxHeightRatio: 0.8,
            builder: (BuildContext context) {
              return const ValidateButtomSheet();
            },
          );
        },
        name: 'Ahmed Tarek',
        status: 'No status',
        statusColor: const Color.fromRGBO(229, 229, 229, 1),
        id: '20-0-60785',
        year: '4th',
        title: 'EGSA.pdf',
        image: 'assets/project_image/pdf.png'),
    // StudentContainer(
    //     onTap: null,
    //     name: null,
    //     status: null,
    //     statusColor: null,
    //     id: null,
    //     year: null,
    //     button: (BuildContext context) {
    //       return const KButton(
    //         text: 'Download',
    //         backgroundColor: Colors.blue,
    //       );
    //     },
    //     title: 'EGSA.pdf',
    //     image: 'assets/project_image/pdf.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Validate',
        onpressed: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          ListContainer(
            title: 'Requests',
            listOfWidgets: studentreques,
            emptyMessage: 'No Requests',
          ),
          KButton(
            text: 'Archive',
            // width: 345,
            height: 62,
            svgPath: 'assets/project_image/Pin.svg',
            onPressed: () {
              Navigator.pushNamed(
                  context, '/staffStudentTraining/validate/archive');
            },
          ),
          // const SizedBox(
          //   height: 10,
          // )
        ],
      ),
    );
  }
}
