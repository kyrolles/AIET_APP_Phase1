import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'map_lec_container.dart';
import '../room_details_bottom_sheet.dart';
import '../../../constants.dart';

class FloorContainer extends StatelessWidget {
  const FloorContainer({
    super.key,
    required this.floor,
    required this.selectedDate,
    this.lectures = const [], // Default to empty list
    this.sections = const [], // Default to empty list
    this.labs = const [], // Default to empty list
  });

  final String floor;
  final DateTime selectedDate;
  final List<Map<String, dynamic>>
      lectures; // List of lecture rooms with their status
  final List<Map<String, dynamic>>
      sections; // List of sections with their status
  final List<Map<String, dynamic>> labs; // List of labs with their status

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Column(
      children: [
        IntrinsicHeight(
          // This widget forces children to have the same height
          child: Row(
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
                    floor, // Floor is already a number, no need to localize
                    style: kTextStyleSize24,
                  ),
                ),
              ),
              // Vertical divider that will grow with container height
              const VerticalDivider(
                width: 20,
                thickness: 1,
                color: Colors.grey,
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
                  child: Column(
                    //* the content in the container
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Only show lectures section if there are lectures
                      if (lectures.isNotEmpty) ...[
                        //* the lectures part
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Center(
                            child: Text(
                              localizations?.lec ?? 'Lec',
                              style: const TextStyle(
                                fontFamily: 'Lexend',
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
                          spacing: 0.0,
                          runSpacing: 0.0,
                          children: lectures
                              .map((lec) => LecContainer(
                                    lec: lec['name'],
                                    isEmpty: lec['isEmpty'],
                                    onTap: () => _showRoomDetails(
                                      context,
                                      lec['name'],
                                      !(lec['isOccupied'] ??
                                          false), // Use isOccupied for empty status
                                      localizations?.lecture ?? 'Lecture',
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],

                      // Only show sections if there are sections
                      if (sections.isNotEmpty) ...[
                        //* the sections part
                        Center(
                          child: Text(
                            localizations?.section ?? 'Section',
                            style: const TextStyle(
                              fontFamily: 'Lexend',
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
                          spacing: 0.0,
                          runSpacing: 0.0,
                          children: sections
                              .map((section) => LecContainer(
                                    lec: section['name'],
                                    isEmpty: section['isEmpty'],
                                    onTap: () => _showRoomDetails(
                                      context,
                                      section['name'],
                                      !(section['isOccupied'] ??
                                          false), // Use isOccupied for empty status
                                      localizations?.section ?? 'Section',
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],

                      // Only show labs if there are labs
                      if (labs.isNotEmpty) ...[
                        //* the lab part
                        Center(
                          child: Text(
                            localizations?.lab ?? 'Lab',
                            style: const TextStyle(
                              fontFamily: 'Lexend',
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
                          spacing: 0.0,
                          runSpacing: 0.0,
                          children: labs
                              .map((lab) => LecContainer(
                                    lec: lab['name'],
                                    isEmpty: lab['isEmpty'],
                                    onTap: () => _showRoomDetails(
                                      context,
                                      lab['name'],
                                      !(lab['isOccupied'] ??
                                          false), // Use isOccupied for empty status
                                      localizations?.lab ?? 'Lab',
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        )
      ],
    );
  }

  void _showRoomDetails(
      BuildContext context, String roomName, bool isEmpty, String roomType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => RoomDetailsBottomSheet(
        roomName: roomName,
        isEmpty: isEmpty,
        roomType: roomType,
        selectedDate: selectedDate,
      ),
    );
  }
}
