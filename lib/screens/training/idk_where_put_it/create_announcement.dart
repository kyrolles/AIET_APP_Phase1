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
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity, // Full width
                      alignment:
                          Alignment.topLeft, // Align text to the top-left
                      child: Text(
                        '1. Company Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter Company Name',
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity, // Full width
                      alignment:
                          Alignment.topLeft, // Align text to the top-left
                      child: Text(
                        '2. Description',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity, // Make it full-width
                      child: TextField(
                        maxLines: 8, // Adjust for height
                        decoration: InputDecoration(
                          hintText: "Enter company description....",
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Rounded corners
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 20, // Add padding to make it spacious
                            horizontal: 15, // Padding on the sides
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity, // Full width
                      alignment:
                          Alignment.topLeft, // Align text to the top-left
                      child: Text(
                        '3. Important links:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity, // Make it full-width
                      child: TextField(
                        maxLines: 5, // Adjust for height
                        decoration: InputDecoration(
                          hintText: "Enter company description....",
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Rounded corners
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 20, // Add padding to make it spacious
                            horizontal: 15, // Padding on the sides
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity, // Full width
                      alignment:
                          Alignment.topLeft, // Align text to the top-left
                      child: Text(
                        '4. Upload Logo:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter Important links',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity, // Full width
                      alignment:
                          Alignment.topLeft, // Align text to the top-left
                      child: Text(
                        '5. Upload Image(Optionalfor the profile):',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter Important links',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity, // Full width
                      alignment:
                          Alignment.topLeft, // Align text to the top-left
                      child: Text(
                        '6. Share Announcement to Department:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter Important links',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ))));
  }
}
