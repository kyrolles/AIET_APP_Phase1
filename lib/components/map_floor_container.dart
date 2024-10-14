import 'package:flutter/material.dart';
import 'package:graduation_project/components/map_lec_container.dart';
import 'package:graduation_project/constants.dart';

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
            //the blue contianer
            Container(
              margin: const EdgeInsets.only(left: 15, right: 5),
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                boxShadow: kShadow,
                color: kPrimary,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                  child: Text(
                floor,
                style: kTextStyleNumber,
              )),
            ),
            const SizedBox(
              height: 325,
              child: VerticalDivider(),
            ),
            //The big container with all the lec & sec & lab
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white, // Background color of the container
                  border: Border.all(
                    color: kGrey, // Border color
                    width: 2.0, // Border width
                  ),
                  borderRadius:
                      BorderRadius.circular(10), // Optional: Rounded corners
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
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
                      spacing: 0.0, // Space between components horizontally
                      runSpacing: 0.0, // Space between components vertically
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
                      spacing: 0.0, // Space between components horizontally
                      runSpacing: 0.0, // Space between components vertically
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
                      spacing: 0.0, // Space between components horizontally
                      runSpacing: 0.0, // Space between components vertically
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
