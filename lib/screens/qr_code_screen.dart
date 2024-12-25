import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graduation_project/constants.dart';

class QrcodeScreen extends StatelessWidget {
  const QrcodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          //! Background image
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/ID.svg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          //! Back arrow button
          Positioned(
            top: 40, // Adjust as needed for padding from top
            left: 16, // Adjust as needed for padding from left
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 100),
                const Text(
                  'ID',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          //! Foreground content
          Center(
            child: Column(
              children: [
                const SizedBox(height: 100),
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 58,
                    backgroundImage:
                        AssetImage('assets/images/1704502172296.jfif'),
                  ),
                ),
                const SizedBox(height: 50),
                const Text(
                  'Ahmed Mohamed',
                  style: kTextStyleSize24,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Computer Science',
                  style: kTextStyleBold,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                //! QR Code
                qrCodeFunction(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget qrCodeFunction() {
    return const Center(child: Text('Add QR Code here'));
  }
}
