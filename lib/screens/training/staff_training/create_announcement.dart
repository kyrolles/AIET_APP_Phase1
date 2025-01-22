import 'package:flutter/material.dart';
import 'package:graduation_project/components/checkbox_with_label.dart';
import 'package:graduation_project/components/file_upload_with_progress.dart';

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
                    FileUploadWidget(
                      height: 350,
                      width: double.infinity, // Full width
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
                    FileUploadWidget(
                      height: 350,
                      width: double.infinity, // Full width
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
                    CustomCheckbox(
                      label: "Computer",
                      onChanged: (value) {
                        print("Computer selected: $value");
                      },
                    ),
                    CustomCheckbox(
                      label: "Mechatronics",
                      onChanged: (value) {
                        print("Mechatronics selected: $value");
                      },
                    ),
                    CustomCheckbox(
                      label: "Communication & Electronics",
                      onChanged: (value) {
                        print("Communication & Electronics selected: $value");
                      },
                    ),
                    CustomCheckbox(
                      label: "Industrial",
                      onChanged: (value) {
                        print("Industrial selected: $value");
                      },
                    ),
                  ],
                ))));
  }
}
