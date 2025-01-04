import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomSheetExample(),
    );
  }
}

class BottomSheetExample extends StatelessWidget {
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enter Student Name & ID",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF978ECB),
                  shape: RoundedRectangleBorder(  
                       borderRadius: BorderRadius.circular(15),
                     ),
                  minimumSize: Size(double.infinity, 55),
                ),
                child: Text("Manual", style: TextStyle(color: Color(0xFFFFFFFF))),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0ED290),
                  shape: RoundedRectangleBorder(  
                       borderRadius: BorderRadius.circular(15),
                     ),
                  minimumSize: Size(double.infinity, 55),
                ),
                child: Text("Using Stu QR Code", style: TextStyle(color: Color(0xFFFFFFFF))),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bottom Sheet Example")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showBottomSheet(context),
          child: Text("Show Bottom Sheet"),
        ),
      ),
    );
  }
}
