import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/language_clases/language_constants.dart';
import 'package:graduation_project/screens/drawer/academic_webview_screen.dart';
import '../admin/schedule_management_screen.dart';
import 'package:graduation_project/language_clases/language.dart';
import 'package:graduation_project/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  final Function() onLogout;
  final String userRole;

  const AppDrawer(this.onLogout, {required this.userRole, super.key});
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

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
                      title: Text(localizations?.id ?? "ID",
                          style: kTextStyleBold),
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
                        title: Text(
                          localizations?.scheduleManagement ??
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
                      title: Text(
                        localizations?.academics ?? "Academics",
                        style: kTextStyleBold,
                      ),
                      iconColor: kBlue,
                      children: [
                        ListTile(
                          title: Text(
                            localizations?.studyPrograms ?? "Study Programs",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/programms.asp?R=3',
                                  title: localizations?.programs ?? 'Programs',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            localizations?.programs ?? "Programs",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/department.asp?R=3',
                                  title: localizations?.programs ?? 'Programs',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            localizations?.academicCalendar ??
                                "Academic Calendar",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/calendar.asp?R=3',
                                  title: localizations?.academicCalendar ??
                                      'Academic Calendar',
                                ),
                              ),
                            );
                          },
                        ),

                        // Add more links here if needed
                      ],
                    ),
                  ), // Student section code...
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: ExpansionTile(
                      leading: const Icon(
                        Icons.person_search_outlined,
                        size: 30,
                      ),
                      title: Text(
                        localizations?.students ?? "Students",
                        style: kTextStyleBold,
                      ),
                      iconColor: kBlue,
                      children: [
                        ListTile(
                          title: Text(
                            localizations?.announcements ?? "Announcements",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/annoucements.asp?R=4',
                                  title: localizations?.announcements ??
                                      'Announcements',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            localizations?.timeTables ?? "Time Tables",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/timetables.asp?R=4',
                                  title: localizations?.timeTables ??
                                      'Time Tables',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            localizations?.studentActivities ??
                                "Student Activities",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/activity.asp?R=4',
                                  title: localizations?.studentActivities ??
                                      'Student Activities',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            localizations?.industrialTraining ??
                                "Industrial Training",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/training.asp?R=4',
                                  title: localizations?.industrialTraining ??
                                      'Industrial Training',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            localizations?.graduationProjects ??
                                "Graduation Projects",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/projects.asp?R=4',
                                  title: localizations?.graduationProjects ??
                                      'Graduation Projects',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            localizations?.studentPortal ?? "Student Portal",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/portal.asp?R=4',
                                  title: localizations?.studentPortal ??
                                      'Student Portal',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            localizations?.alumni ?? "Alumni",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/testimonial.asp?R=4',
                                  title: localizations?.alumni ?? 'Alumni',
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
                      title: Text(
                        localizations?.staffMembers ?? "Staff Members",
                        style: kTextStyleBold,
                      ),
                      iconColor: kBlue,
                      children: [
                        ListTile(
                          title: Text(
                            localizations?.academicStaff ?? "Academic Staff",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/academic-staff.asp?R=5',
                                  title: localizations?.academicStaff ??
                                      'Academic Staff',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            localizations?.assistingStaff ?? "Assisting Staff",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/assisting-staff.asp?R=5',
                                  title: localizations?.assistingStaff ??
                                      'Assisting Staff',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            localizations?.careers ?? "Careers",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/careers.asp?R=5',
                                  title: localizations?.careers ?? 'Careers',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ), // About AIET section code...
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: ExpansionTile(
                      leading: const Icon(
                        Icons.info_outline,
                        size: 30,
                      ),
                      title: Text(
                        localizations?.aboutAIET ?? "About AIET",
                        style: kTextStyleBold,
                      ),
                      iconColor: kBlue,
                      children: [
                        ListTile(
                          title: Text(
                            localizations?.welcome ?? "Welcome",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/about-welcome.asp?R=1',
                                  title: localizations?.welcome ?? 'Welcome',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            localizations?.founder ?? "Founder",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/about-aiet.asp?R=1',
                                  title: localizations?.founder ?? 'Founder',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            localizations?.visionMission ?? "Vision & Mission",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/vision.asp?R=1',
                                  title: localizations?.visionMission ??
                                      'Vision & Mission',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            localizations?.governance ?? "Governance",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/organizational.asp?R=1',
                                  title:
                                      localizations?.governance ?? 'Governance',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            localizations?.accreditations ?? "Accreditations",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/Accreditations.asp?R=1',
                                  title: localizations?.accreditations ??
                                      'Accreditations',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            localizations?.boardOfDirectors ??
                                "Board of Directors",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/directors.asp?R=1',
                                  title: localizations?.boardOfDirectors ??
                                      'Board of Directors',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            localizations?.qAndA ?? "Q&A",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url: 'https://www.aiet.edu.eg/FAQ?R=1',
                                  title: localizations?.qAndA ?? 'Q&A',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            localizations?.codeOfEthics ?? "Code of Ethics",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/pages/CodeofEthics.asp',
                                  title: localizations?.codeOfEthics ??
                                      'Code of Ethics',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            localizations?.factsAndFigures ?? "Facts & Figures",
                            style: kTextStyleNormal,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicWebViewScreen(
                                  url:
                                      'https://www.aiet.edu.eg/facts-and-figures/',
                                  title: localizations?.factsAndFigures ??
                                      'Facts & Figures',
                                ),
                              ),
                            );
                          },
                        ),
                        // Add more links here if needed
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: ExpansionTile(
                      leading: const Icon(
                        Icons.settings,
                        size: 30,
                      ),
                      title: Text(
                        AppLocalizations.of(context)?.settings ?? "Settings",
                        style: kTextStyleBold,
                      ),
                      iconColor: kBlue,
                      children: [
                        DropdownButton<Language>(
                          underline: const SizedBox(),
                          hint: Row(
                            children: [
                              const Icon(
                                Icons.language,
                                size: 30,
                              ),
                              const SizedBox(width: 8),
                              Text(translation(context).changeLanguage),
                            ],
                          ),
                          onChanged: (Language? language) async {
                            if (language != null) {
                              Locale _locale =
                                  await setLocale(language.languageCode);
                              MyApp.setLocale(context, _locale);
                            }
                          },
                          items: Language.languageList()
                              .map<DropdownMenuItem<Language>>(
                                (e) => DropdownMenuItem<Language>(
                                  value: e,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Text(
                                        e.flag,
                                        style: const TextStyle(fontSize: 30),
                                      ),
                                      Text(e.name)
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),

                        // Add more links here if needed
                      ],
                    ),
                  ),
                  // Add some space between sections
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
          ), // Logout button - keep outside the scrollable area
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25),
            child: ListTile(
              leading: const Icon(Icons.logout, size: 30),
              title: Text(localizations?.logout ?? "Logout",
                  style: kTextStyleBold),
              onTap: onLogout,
            ),
          ),
        ],
      ),
    );
  }
}
