import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../services/firestore_service.dart';
import '../../../components/colors.dart';

class TeacherView extends StatefulWidget {
  final String teacherId;
  const TeacherView({super.key, required this.teacherId});

  @override
  _TeacherViewState createState() => _TeacherViewState();
}

class _TeacherViewState extends State<TeacherView> {
  List<ScheduleEntry> schedule = [];

  @override
  void initState() {
    super.initState();
    loadSchedule();
  }

  void loadSchedule() async {
    schedule = await FirestoreService.getTeacherSchedule(widget.teacherId);
    setState(() {});
  }

  void requestScheduleChange(ScheduleEntry entry) {
    // Open a dialog to request a schedule change
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Teaching Schedule")),
      body: ListView.builder(
        itemCount: schedule.length,
        itemBuilder: (context, index) {
          final entry = schedule[index];
          return Card(
            color: AppColors.defaultCard,
            child: ListTile(
              title: Text(entry.courseName),
              subtitle: Text("${entry.startTime} - ${entry.endTime}"),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text("Request Reschedule"),
                    onTap: () => requestScheduleChange(entry),
                  ),
                  PopupMenuItem(
                    child: const Text("Cancel Class"),
                    onTap: () {
                      // Cancelation logic
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
