import 'package:flutter/material.dart';
import '../components/it_invoice_request_contanier.dart';
import '../components/my_app_bar.dart';
import '../constants.dart';

class ItArchiveScreen extends StatefulWidget {
  const ItArchiveScreen(
      {super.key, required this.itArchive, required this.requests});

  final List<RequestContainer> itArchive;
  final List<RequestContainer> requests;

  @override
  State<ItArchiveScreen> createState() => _ItArchiveScreenState();
}

class _ItArchiveScreenState extends State<ItArchiveScreen> {
  void updateArchiveList() {
    //!archive list
    for (var i = 0; i < widget.itArchive.length; i++) {
      if (widget.itArchive[i].status == 'Pending') {
        setState(() {
          //* add it to the requests list
          widget.requests.add(widget.itArchive[i]);
        });
      }
    }
    setState(() {
      //*Remove the item from the archive list
      widget.itArchive.removeWhere((archive) => archive.status == 'Pending');
    });
  }

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
            onpressed: () {
              // updateArchiveList();
              Navigator.pop(context);
            },
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
