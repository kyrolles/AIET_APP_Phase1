import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/service_item.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/components/list_container.dart';

class AttendanceArchive extends StatelessWidget {
  const AttendanceArchive({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          MyAppBar(title: 'Archive', onpressed: () => Navigator.pop(context)),
      body: Column(
        children: [
          const SizedBox(
            height: 200,
            child: Center(child: Text('QR Code')),
          ),
          const ListContainer(
            title: 'Attendance List',
            listOfWidgets: [],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Student +',
                      style: TextStyle(
                          fontSize: 21.7,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Confirm',
                      style: TextStyle(
                          fontSize: 21.7,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
