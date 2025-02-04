import 'package:flutter/material.dart';
import 'package:graduation_project/components/custom_text_field.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/pdf_view.dart';
import 'package:graduation_project/components/student_container.dart';
import 'package:graduation_project/screens/invoice/it_incoive/request_model.dart';

class ValidateButtomSheet extends StatelessWidget {
  const ValidateButtomSheet({super.key, required this.request});
  final Request request;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              bottom: 32.0, left: 16.0, right: 16.0, top: 22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              const Center(
                child: Text(
                  'Review',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF6C7072)),
                ),
              ),
              StudentContainer(
                  onTap: null,
                  name: null,
                  status: null,
                  statusColor: null,
                  id: null,
                  year: null,
                  button: (BuildContext context) {
                    return KButton(
                        onPressed: () {
                          if (request.pdfBase64 != null) {
                            PDFViewer.open(
                              context,
                              request.pdfBase64!,
                            );
                          } else {
                            // Handle the case where pdfBase64 is null
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('PDF data is not available')),
                            );
                          }
                        },
                        text: 'view',
                        backgroundColor: const Color.fromRGBO(6, 147, 241, 1),
                        width: 115,
                        height: 50,
                        fontSize: 16.55,
                        padding: const EdgeInsets.only(bottom: 8, top: 8));
                  },
                  title: request.fileName,
                  image: 'assets/project_image/pdf.png'),
              const CustomTextField(
                label: 'Score(in Days)',
                hintText: 'Enter student Score',
                isRequired: true,
              ),
              const SizedBox(height: 8),
              const CustomTextField(
                label: 'Comment',
                hintText: 'Enter any notes (optional)',
                isRequired: false,
              ),
              const Row(
                children: [
                  Flexible(
                    child: KButton(
                      text: null,
                      svgPath: 'assets/project_image/false.svg',
                      svgHeight: 50,
                      svgWidth: 50,
                      height: 65,
                      backgroundColor: Color.fromRGBO(255, 118, 72, 1),
                    ),
                  ),
                  Flexible(
                    child: KButton(
                      text: null,
                      svgPath: 'assets/project_image/pause.svg',
                      svgHeight: 45,
                      svgWidth: 45,
                      height: 65,
                      backgroundColor: Color.fromRGBO(255, 221, 41, 1),
                    ),
                  ),
                  Flexible(
                    child: KButton(
                      text: null,
                      svgPath: 'assets/project_image/true.svg',
                      svgHeight: 50,
                      svgWidth: 50,
                      height: 65,
                      backgroundColor: Color.fromRGBO(52, 199, 89, 1),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
