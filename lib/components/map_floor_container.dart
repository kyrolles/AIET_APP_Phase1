import 'package:flutter/material.dart';
import 'map_lec_container.dart';
import '../constants.dart';

class FloorContainer extends StatelessWidget {
  const FloorContainer({super.key, required this.floor});
  final String floor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //* the blue Box with the floor number
            Container(
              margin: const EdgeInsets.only(left: 15, right: 5),
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                boxShadow: kShadow,
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Text(
                  floor,
                  style: kTextStyleSize24,
                ),
              ),
            ),
            const SizedBox(
              height: 325,
              child: VerticalDivider(),
            ),
            //* The big container with all the lec & sec & lab
            Expanded(
              child: Container(
                //* the specifications of the container
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white, //* Background color of the container
                  border: Border.all(
                    color: kGrey, //* Border color
                    width: 2.0, //* Border width
                  ),
                  borderRadius:
                      BorderRadius.circular(10), //* Optional: Rounded corners
                ),
                child: const Column(
                  //* the content in the container
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //* the lectures part
                    Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Center(
                        child: Text(
                          'Lec',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            // fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: kGrey,
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      indent: 10,
                      endIndent: 10,
                      color: kGreyLight,
                      height: 0,
                    ),
                    Wrap(
                      //! Wrap: This widget arranges its children in a horizontal or vertical wrap. When the space is not enough for the next child, it moves it to the next "line."
                      spacing: 0.0, //* Space between components horizontally
                      runSpacing: 0.0, //* Space between components vertically
                      children: [
                        LecContainer(
                          lec: 'M1',
                          isEmpty: kOrange,
                        ),
                        LecContainer(
                          lec: 'M2',
                          isEmpty: kGreyLight,
                        ),
                        LecContainer(
                          lec: 'M3',
                          isEmpty: kGreyLight,
                        ),
                      ],
                    ),
                    //* the sections part
                    Center(
                      child: Text(
                        'Section',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          // fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: kGrey,
                        ),
                      ),
                    ),
                    Divider(
                      indent: 10,
                      endIndent: 10,
                      color: kGreyLight,
                      height: 0,
                    ),
                    Wrap(
                      spacing: 0.0, //* Space between components horizontally
                      runSpacing: 0.0, //* Space between components vertically
                      children: [
                        LecContainer(
                          lec: 'CR1',
                          isEmpty: kGreyLight,
                        ),
                        LecContainer(
                          lec: 'CR2',
                          isEmpty: kOrange,
                        ),
                        LecContainer(
                          lec: 'CR3',
                          isEmpty: kOrange,
                        ),
                        LecContainer(
                          lec: 'CR4',
                          isEmpty: kOrange,
                        ),
                        LecContainer(
                          lec: 'DH',
                          isEmpty: kGreyLight,
                        ),
                      ],
                    ),
                    //* the lab part
                    Center(
                      child: Text(
                        'Lab',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          // fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: kGrey,
                        ),
                      ),
                    ),
                    Divider(
                      indent: 10,
                      endIndent: 10,
                      color: kGreyLight,
                      height: 0,
                    ),
                    Wrap(
                      spacing: 0.0, //* Space between components horizontally
                      runSpacing: 0.0, //* Space between components vertically
                      children: [
                        LecContainer(
                          lec: 'B1',
                          isEmpty: kGreyLight,
                        ),
                        LecContainer(
                          lec: 'B2',
                          isEmpty: kGreyLight,
                        ),
                        LecContainer(
                          lec: 'B3',
                          isEmpty: kGreyLight,
                        ),
                        LecContainer(
                          lec: 'B23',
                          isEmpty: kGreyLight,
                        ),
                        LecContainer(
                          lec: 'B24',
                          isEmpty: kGreyLight,
                        ),
                        LecContainer(
                          lec: 'B31',
                          isEmpty: kOrange,
                        ),
                        LecContainer(
                          lec: 'B21',
                          isEmpty: kOrange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 15,
        )
      ],
    );
  }
}
