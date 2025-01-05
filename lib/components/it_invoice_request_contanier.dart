import 'package:flutter/material.dart';
import 'proof_sheet_screen.dart';
import '../constants.dart';

class RequestContainer extends StatefulWidget {
  RequestContainer(
      {super.key,
      this.status = 'No Status',
      this.statusColor = const Color(0XFFE5E5E5)});
  Color? statusColor;
  String? status;

  @override
  State<RequestContainer> createState() => _RequestContainerState();
}

class _RequestContainerState extends State<RequestContainer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet<void>(
          backgroundColor: const Color(0XFFF1F1F2),
          context: context,
          builder: (BuildContext context) {
            return ProofOfEnrollmentSheetScreen(
              doneFunctionality: () {
                setState(() {
                  widget.status = "Done";
                  widget.statusColor = const Color(0XFF34C759);
                });
                Navigator.pop(context);
              },
              rejectedFunctionality: () {
                setState(() {
                  widget.status = "Rejected";
                  widget.statusColor = const Color(0XFFFF7648);
                  // Remove the item from the source list and add it to the destination list
                  // itArchive.add(requests[index]);
                  // requests.remove(requests[index]);
                });
                Navigator.pop(context);
              },
              pendingFunctionality: () {
                setState(() {
                  widget.status = "Pending";
                  widget.statusColor = const Color(0XFFFFDD29);
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
        ),
        // height: 100,
        child: Column(
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kyrolles Raafat',
                  style: kTextStyleNormal,
                ),
                const SizedBox(width: 5),
                Container(
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: const Text(
                    '20-0-60785',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0XFFFF8504),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: const Text(
                    '4th',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: Colors.black,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Image.asset('assets/images/image 29 (2).png'),
                  ),
                ),
                const Text(
                  'Proof of enrollment',
                  style: TextStyle(fontSize: 18),
                ),
                Row(
                  children: [
                    Text(
                      widget.status!,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0XFF6C7072)),
                    ),
                    const SizedBox(width: 3),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.statusColor,
                      ),
                      height: 22,
                      width: 22,
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
