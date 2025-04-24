import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/screens/drawer/academic_webview_screen.dart';
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
                          builder: (context) =>
                              const ScheduleManagementScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ExpansionTile(
                  leading: const Icon(
                    Icons.school_outlined,
                    size: 30,
                  ),
                  title: const Text(
                    "Academics",
                    style: kTextStyleBold,
                  ),
                  iconColor: kBlue,
                  children: [
                    ListTile(
                      title: const Text(
                        "Study Programms",
                        style: kTextStyleNormal,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AcademicWebViewScreen(
                              url:
                                  'https://www.aiet.edu.eg/pages/programms.asp?R=3',
                              title: 'Programs',
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text(
                        "Departments",
                        style: kTextStyleNormal,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AcademicWebViewScreen(
                              url:
                                  'https://www.aiet.edu.eg/pages/department.asp?R=3',
                              title: 'Departments',
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text(
                        "Academic Calendar",
                        style: kTextStyleNormal,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AcademicWebViewScreen(
                              url:
                                  'https://www.aiet.edu.eg/pages/calendar.asp?R=3',
                              title: 'Academic Calendar',
                            ),
                          ),
                        );
                      },
                    ),
                    // Add more links here if needed
                  ],
                ),
              ),

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
