import 'package:flutter/material.dart';
import 'package:graduation_project/screens/invoice/it_incoive/request_model.dart';
import 'package:graduation_project/screens/invoice/it_incoive/tuition_fees_upload.dart';
import 'proof_sheet_screen.dart';
import '../../../constants.dart';

class RequestContainer extends StatelessWidget {
  const RequestContainer({super.key, required this.request});
  final Request request;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        request.type == 'Tuition Fees'
            ? showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (BuildContext context) {
                  return TuitionFeesSheet(
                    doneFunctionality: () {},
                  );
                },
              )
            : showModalBottomSheet<void>(
                backgroundColor: const Color(0XFFF1F1F2),
                context: context,
                builder: (BuildContext context) {
                  return ProofOfEnrollmentSheetScreen(
                    doneFunctionality: () {
                      Navigator.pop(context);
                    },
                    rejectedFunctionality: () {
                      Navigator.pop(context);
                    },
                    pendingFunctionality: () {
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
                Text(
                  request.studentName,
                  style: kTextStyleNormal,
                ),
                const SizedBox(width: 5),
                Container(
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Text(
                    request.studentId,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0XFFFF8504),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Text(
                    request.year,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
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
                    child: Image.asset(
                      request.type == 'Tuition Fees'
                          ? 'assets/images/9e1e8dc1064bb7ac5550ad684703fb30.png'
                          : 'assets/images/image 29 (2).png',
                    ),
                  ),
                ),
                Text(
                  request.type,
                  style: const TextStyle(fontSize: 18),
                ),
                Row(
                  children: [
                    Text(
                      request.status,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0XFF6C7072)),
                    ),
                    const SizedBox(width: 3),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: request.status == 'Pending'
                            ? Colors.yellow
                            : request.status == 'Rejected'
                                ? Colors.red
                                : request.status == 'Done'
                                    ? const Color(0xFF34C759)
                                    : kGreyLight,
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
