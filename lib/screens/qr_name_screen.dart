import 'package:flutter/material.dart';



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomSheet(),
    );
  }
}

class BottomSheet extends StatelessWidget {
  void _showAddStudentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true, 
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, 
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Add Student",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                ),
                SizedBox(height: 20),
                Text("Name", style: TextStyle(fontWeight: FontWeight.normal)),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Enter student name",
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                Text("ID", style: TextStyle(fontWeight: FontWeight.normal)),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter student id",
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 25),
                       shape: RoundedRectangleBorder(  
                       borderRadius: BorderRadius.circular(15),
                     ),
                    ),
                    child: Text("Add", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bottom Sheet")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showAddStudentBottomSheet(context),
          child: Text("Show Add Student Form"),
        ),
      ),
    );
  }
}
