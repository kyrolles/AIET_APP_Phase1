import 'package:flutter/material.dart';
import 'package:graduation_project/components/checkbox_with_label.dart';
import 'package:graduation_project/components/file_upload_with_progress.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/my_app_bar.dart';

class CreateAnnouncement extends StatelessWidget {
  const CreateAnnouncement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          title: 'Create Announcement',
          onpressed: () => Navigator.pop(context),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity, // Full width
                      alignment:
                          Alignment.topLeft, // Align text to the top-left
                      child: const Text(
                        '1. Company Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter Company Name',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity, // Full width
                      alignment:
                          Alignment.topLeft, // Align text to the top-left
                      child: const Text(
                        '2. Description',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
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
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20, // Add padding to make it spacious
                            horizontal: 15, // Padding on the sides
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity, // Full width
                      alignment:
                          Alignment.topLeft, // Align text to the top-left
                      child: const Text(
                        '3. Important links:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
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
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20, // Add padding to make it spacious
                            horizontal: 15, // Padding on the sides
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity, // Full width
                      alignment:
                          Alignment.topLeft, // Align text to the top-left
                      child: const Text(
                        '4. Upload Logo:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    FileUploadWidget(
                      height: 350,
                      width: double.infinity, // Full width
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity, // Full width
                      alignment:
                          Alignment.topLeft, // Align text to the top-left
                      child: const Text(
                        '5. Upload Image(Optionalfor the profile):',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    FileUploadWidget(
                      height: 350,
                      width: double.infinity, // Full width
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity, // Full width
                      alignment:
                          Alignment.topLeft, // Align text to the top-left
                      child: const Text(
                        '6. Share Announcement to Department:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
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
                    const SizedBox(
                      height: 35,
                    ),
                    KButton(
                      backgroundColor: Color.fromRGBO(6, 147, 241, 1),
                      text: 'post',
                      padding: const EdgeInsets.all(0),
                      onPressed: () {},
                    )
                  ],
                ))));
  }
}
