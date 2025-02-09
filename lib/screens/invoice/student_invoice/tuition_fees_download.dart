import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/pdf_view.dart';
import 'package:graduation_project/components/student_container.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/models/request_model.dart';

class TuitionFeesDownload extends StatelessWidget {
  const TuitionFeesDownload({super.key, required this.request});

  final Request request;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          // Expanded(
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 16),
          //     child: Image.asset(
          //       'assets/images/invoice_preview.png',
          //       fit: BoxFit.contain,
          //     ),
          //   ),
          // ),
          StudentContainer(
            button: (BuildContext context) {
              return KButton(
                onPressed: () {
                  if (request.pdfBase64 != null) {
                    PDFViewer.open(
                      context,
                      request.pdfBase64!,
                    );
                  } else {
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
                margin: const EdgeInsets.only(top: 8, bottom: 8),
              );
            },
            title: request.fileName,
            image: 'assets/project_image/pdf.png',
          ),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: KButton(
          //     onPressed: () {},
          //     text: 'View PDF',
          //     fontSize: 21.7,
          //     textColor: Colors.white,
          //     backgroundColor: kBlue,
          //     borderColor: Colors.white,
          //   ),
          // ),
        ],
      ),
    );
  }
}
