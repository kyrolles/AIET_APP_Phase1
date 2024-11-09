import 'package:flutter/material.dart';

class TuitionFeesSheet extends StatelessWidget {
  const TuitionFeesSheet({super.key, required this.doneFunctionality});
  final Function() doneFunctionality;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tuition fees',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload, size: 50, color: Colors.grey),
                const SizedBox(height: 10),
                const Text(
                  'Select a file or drag and drop here',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const Text(
                  'JPG, PNG or PDF, file size no more than 10MB',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.blueAccent),
                  ),
                  child: const Text('SELECT FILE'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'File added',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.insert_drive_file, color: Colors.blueAccent),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Passport.png'),
                    Text(
                      '5.7MB',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: doneFunctionality,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF34C759),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Done',
                style: TextStyle(
                    fontSize: 21.7,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFFFFF))),
          ),
        ],
      ),
    );
  }
}
