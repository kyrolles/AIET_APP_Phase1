import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';

class BuildingA extends StatelessWidget {
  const BuildingA({
    super.key,
  });

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
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                boxShadow: kShadow,
                color: kPrimary,
                borderRadius: BorderRadius.circular(13.0),
              ),
              child: const Center(
                  child: Text(
                '0',
                style: kTextStyleNumber,
              )),
            ),
            const SizedBox(
              height: 420,
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
                  children: [
                    Text(
                      'Lec',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        // fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: kGrey,
                      ),
                    ),
                    Divider(
                      indent: 10,
                      endIndent: 10,
                      color: kGrey,
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: kMapColor,
                              borderRadius: BorderRadius.circular(5)),
                          margin: const EdgeInsets.only(left: 8),
                          height: 40,
                          width: 60,
                          child: const Center(
                            child: Text(
                              'M1',
                              style: kTextStyleBold,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: kMapColor,
                              borderRadius: BorderRadius.circular(5)),
                          margin: const EdgeInsets.only(left: 8),
                          height: 40,
                          width: 60,
                          child: const Center(
                            child: Text(
                              'M2',
                              style: kTextStyleBold,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: kMapColor,
                              borderRadius: BorderRadius.circular(5)),
                          margin: const EdgeInsets.only(left: 8),
                          height: 40,
                          width: 60,
                          child: const Center(
                            child: Text(
                              'M3',
                              style: kTextStyleBold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Section',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        // fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: kGrey,
                      ),
                    ),
                    Divider(
                      indent: 10,
                      endIndent: 10,
                      color: kGrey,
                    ),
                    Text(
                      'Lab',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        // fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: kGrey,
                      ),
                    ),
                    Divider(
                      indent: 10,
                      endIndent: 10,
                      color: kGrey,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
