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
        children: [
          // Logo header - keep outside the scrollable area
          DrawerHeader(
            child: Image.asset(
              'assets/images/smalllogo.png',
            ),
          ),

          // Make this middle section scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 25),

                  // ID section
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: ListTile(
                      leading: const Icon(Icons.person_outline, size: 30),
                      title: const Text("ID", style: kTextStyleBold),
                      onTap: () {
                        Navigator.pushNamed(context, '/id');
                      },
                    ),
                  ),

                  // All your other sections with ExpansionTiles...
                  // Admin section code...
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
                  // Academics section code...
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
                                builder: (context) =>
                                    const AcademicWebViewScreen(
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
                                builder: (context) =>
                                    const AcademicWebViewScreen(
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
                                builder: (context) =>
                                    const AcademicWebViewScreen(
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
                  // Student section code...
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: ExpansionTile(
                      leading: const Icon(
                        Icons.person_search_outlined,
                        size: 30,
                      ),
                      title: const Text(
                        "Students",
                        style: kTextStyleBold,
                      ),
                      iconColor: kBlue,
                      children: [
                        ListTile(
                          title: const Text(
                            "Announcements",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/annoucements.asp?R=4',
                                  title: 'Announcements',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Time Tables",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/timetables.asp?R=4',
                                  title: 'Time Tables',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Student Activities",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/activity.asp?R=4',
                                  title: 'Student Activities',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Industrial Training",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/training.asp?R=4',
                                  title: 'Industrial Training',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Graduation Projects",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/projects.asp?R=4',
                                  title: 'Graduation Projects',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Student Portal",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/portal.asp?R=4',
                                  title: 'Student Portal',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Alumni",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/testimonial.asp?R=4',
                                  title: 'Alumni',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: ExpansionTile(
                      leading: const Icon(
                        Icons.people_outline,
                        size: 30,
                      ),
                      title: const Text(
                        "Staff Members",
                        style: kTextStyleBold,
                      ),
                      iconColor: kBlue,
                      children: [
                        ListTile(
                          title: const Text(
                            "Academic Staff",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/academic-staff.asp?R=5',
                                  title: 'Academic Staff',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Assisting Staff",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/assisting-staff.asp?R=5',
                                  title: 'Assisting Staff',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Careers",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/careers.asp?R=5',
                                  title: 'Careers',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // About AIET section code...
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: ExpansionTile(
                      leading: const Icon(
                        Icons.info_outline,
                        size: 30,
                      ),
                      title: const Text(
                        "About AIET",
                        style: kTextStyleBold,
                      ),
                      iconColor: kBlue,
                      children: [
                        ListTile(
                          title: const Text(
                            "Welcome",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/about-welcome.asp?R=1',
                                  title: 'Welcome',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Founder",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/about-aiet.asp?R=1',
                                  title: 'Founder',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Vision & Mission",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/vision.asp?R=1',
                                  title: 'Vision & Mission',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Governance",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/organizational.asp?R=1',
                                  title: 'Governance',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Accreditations",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/Accreditations.asp?R=1',
                                  title: 'Accreditations',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Board of Directors",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/directors.asp?R=1',
                                  title: 'Board of Directors',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Q&A",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url: 'https://www.aiet.edu.eg/FAQ?R=1',
                                  title: 'Q&A',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Code of Ethics",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/CodeofEthics.asp',
                                  title: 'Code of Ethics',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Facts & Figures",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/facts-and-figures/',
                                  title: 'Facts & Figures',
                                ),
                              ),
                            );
                          },
                        ),
                        // Add more links here if needed
                      ],
                    ),
                  ),

                  // About section
                  // const Padding(
                  //   padding: EdgeInsets.only(left: 25.0),
                  //   child: ListTile(
                  //     leading: Icon(Icons.info_outline, size: 30),
                  //     title: Text("About", style: kTextStyleBold),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),

          // Logout button - keep outside the scrollable area
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25),
            child: ListTile(
              leading: const Icon(Icons.logout, size: 30),
              title: const Text("Logout", style: kTextStyleBold),
              onTap: onLogout,
            ),
          ),
        ],
      ),
    );
  }
}
