import 'package:flutter/material.dart';
import 'package:graduation_project/components/it_invoice_request_contanier.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/screens/it_invoice_screen.dart';

class ItArchiveScreen extends StatefulWidget {
  const ItArchiveScreen({super.key, required this.itArchive});

  final List<RequestContainer> itArchive;

  @override
  State<ItArchiveScreen> createState() => _ItArchiveScreenState();
}

class _ItArchiveScreenState extends State<ItArchiveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(kToolbarHeight), // Standard AppBar height
        child: DecoratedBox(
          decoration: const BoxDecoration(boxShadow: kShadow),
          child: MyAppBar(
            title: 'Archive',
            onpressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Container(
        // height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: const Color(0XFFFAFAFA),
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(15.0),
              child: const Text(
                'Requests',
                style: kTextStyleBold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.itArchive.length,
                itemBuilder: (context, index) {
                  return widget.itArchive[index];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
