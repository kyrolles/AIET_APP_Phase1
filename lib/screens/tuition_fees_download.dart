import 'package:flutter/material.dart';

class TuitionFeesDownload extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700 ,color: Color(0xFF6C7072)),

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
            child: ElevatedButton(
              onPressed: () {

              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 70), backgroundColor: Color(0xFF0693F1),
              ),
              child: const Text(
                'Download as PDF',
              style: TextStyle(fontSize: 21.7, fontWeight: FontWeight.w700 ,color: Color(0xFFFFFFFF)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
