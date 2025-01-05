import 'package:flutter/material.dart';

import '../constants.dart';

class ListContainer extends StatelessWidget {
  const ListContainer({
    super.key,
    required this.title,
    required this.listOfWidgets,
    this.emptyMessage,
  });

  final String title;
  final List<Widget> listOfWidgets;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
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
              child: Text(
                title,
                style: kTextStyleBold,
              ),
            ),
            Expanded(
              child: listOfWidgets.isEmpty
                  ? Center(
                      child: Text(
                        emptyMessage ?? 'No items found',
                        style: const TextStyle(color: kGrey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: listOfWidgets.length,
                      itemBuilder: (context, index) {
                        return listOfWidgets[index];
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
