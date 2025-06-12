import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/models/request_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RequestsButtomSheet extends StatelessWidget {
  const RequestsButtomSheet({super.key, required this.request});
  final Request request;
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
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
              Center(
                child: Text(
                  localizations?.info ?? 'Info',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF6C7072)),
                ),
              ),
              Text(
                localizations?.trainingDays(request.trainingScore.toString()) ??
                    'This training has taken ${request.trainingScore} Days of your record',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              if (request.comment.isNotEmpty) ...[
                const Divider(
                    color: kLightGrey, indent: 10, endIndent: 10, height: 10),
                Center(
                  child: Text(
                    localizations?.comment ?? 'Comment',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF6C7072)),
                  ),
                ),
                Text(
                  request.comment,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
