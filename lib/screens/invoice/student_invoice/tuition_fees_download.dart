import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/constants.dart';

class TuitionFeesDownload extends StatelessWidget {
  const TuitionFeesDownload({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    'Tuition Fees',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6C7072)),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Image.asset(
                'assets/images/invoice_preview.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: KButton(
              onPressed: () {},
              text: 'Download as PDF',
              fontSize: 21.7,
              textColor: Colors.white,
              backgroundColor: kBlue,
              borderColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
