import 'package:flutter/material.dart';
import 'package:graduation_project/screens/invoice/it_incoive/request_model.dart';
import 'proof_sheet_screen.dart';
import '../../../constants.dart';

class RequestContainer extends StatefulWidget {
  const RequestContainer({super.key, required this.request});
  final Request request;

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
                Navigator.pop(context);
              },
              rejectedFunctionality: () {
                setState(() {});
                Navigator.pop(context);
              },
              pendingFunctionality: () {
                setState(() {});
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
                      widget.request.status,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0XFF6C7072)),
                    ),
                    const SizedBox(width: 3),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.request.status == 'Pending'
                            ? Colors.yellow
                            : widget.request.status == 'Rejected'
                                ? Colors.red
                                : widget.request.status == 'Done'
                                    ? Colors.green
                                    : Colors.blueGrey,
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
