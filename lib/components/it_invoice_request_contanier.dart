import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';

class RequestContainer extends StatelessWidget {
  RequestContainer(
      {super.key,
      this.status = 'No Status',
      this.statusColor = const Color(0XFFE5E5E5)});
  Color statusColor;
  String status;
  // final Function(Color)? onUpdateContainer;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  color: kPrimary,
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
                    status,
                    style:
                        const TextStyle(fontSize: 14, color: Color(0XFF6C7072)),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
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
    );
  }
}
