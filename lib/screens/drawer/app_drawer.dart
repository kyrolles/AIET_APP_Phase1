import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';
import '../admin/schedule_management_screen.dart';

class AppDrawer extends StatelessWidget {
  final Function() onLogout;
  final String userRole;

  const AppDrawer(this.onLogout, {required this.userRole, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: kbabyblue,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              //logo
              DrawerHeader(
                child: Image.asset(
                  'assets/images/smalllogo.png',
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              //otherpages
              //firstpage
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: const Icon(
                    Icons.person_outline,
                    size: 30,
                  ),
                  title: const Text(
                    "ID",
                    style: kTextStyleBold,
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/id');
                  },
                ),
              ),
              
              // Admin-only menu items
              if (userRole == 'Admin') ...[
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: const Icon(
                      Icons.schedule,
                      size: 30,
                    ),
                    title: const Text(
                      "Schedule Management",
                      style: kTextStyleBold,
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close drawer first
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScheduleManagementScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
              
              // Attendance option removed
              const Padding(
                padding: EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    size: 30,
                  ),
                  title: Text(
                    "About",
                    style: kTextStyleBold,
                  ),
                ),
              ),
            ],
          ),
          //logout
          //thirdpage
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25),
            child: ListTile(
              leading: const Icon(
                Icons.logout,
                size: 30,
              ),
              title: const Text(
                "Logout",
                style: kTextStyleBold,
              ),
              onTap: onLogout,
            ),
          ),
        ],
      ),
    );
  }
}
