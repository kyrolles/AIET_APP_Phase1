import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';

class AppDrawer extends StatelessWidget {
  final Future<void> Function() _logout;

  const AppDrawer(this._logout, {super.key});

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
              //secondpage
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
              onTap: () {
                _logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}
