import 'package:flutter/material.dart';

class CreateAnnouncement extends StatelessWidget {
  const CreateAnnouncement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Announcement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        child:Padding(padding: EdgeInsets.symmetric(vertical:30,horizontal:20),
        child: Column(
          children: [
          Text('1. Company Name',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),textDirection:TextDirection.ltr,
          ),
          SizedBox(height: 20,),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter Company Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
            Text('2. Description' ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),textDirection:TextDirection.ltr,
            ),
            SizedBox(height: 20,),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text('3. Important links' ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),textDirection:TextDirection.ltr,
            ),
            SizedBox(height: 20,),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter Important links',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),


          ],
        )
      )
      )
    );

  }
}