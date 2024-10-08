import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:graduation_project/components/title_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  void Function(int)? onTabChange;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            const TitleBar(
              title: 'Map',
              rightSpace: 5,
              leftSpace: 3,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: GNav(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 15.0),
                    iconSize: 18,
                    color: Colors.grey[400], // unselected icon color
                    activeColor:
                        const Color(0XFFFF7648), // selected icon and text color
                    tabActiveBorder: Border.all(color: Colors.white),
                    tabBackgroundColor: Colors.grey.shade100,
                    mainAxisAlignment: MainAxisAlignment.center,
                    tabBorderRadius: 20,
                    // onTabChange: (value) {},
                    tabs: const [
                      GButton(
                        icon: Icons.apartment,
                        text: 'A',
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Color(0XFFFF7648)),
                      ),
                      GButton(
                        icon: Icons.apartment,
                        text: 'B',
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Color(0XFFFF7648)),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: TextField(
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          //border color
                          borderSide: const BorderSide(
                              color: Color(0XFF888C94), width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          //border color when search is pressed
                          borderSide: const BorderSide(
                            color: Color(0XFF888C94),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fillColor: Colors.white, //background color
                        filled: true,
                        suffixIcon: const Icon(Icons.search),
                        suffixIconColor: const Color(0XFF888C94), //icon color
                        hintText: 'Search',
                        hintStyle: const TextStyle(
                          color:
                              Color(0XFF888C94), // text color in the textfield
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {},
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
