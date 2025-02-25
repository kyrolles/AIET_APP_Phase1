import 'package:flutter/material.dart';
import '../../../components/colors.dart';
import '../models/schedule_model.dart';
import '../services/firestore_service.dart';

class StudentView extends StatefulWidget {
  final String userId;
  const StudentView({super.key, required this.userId});

  @override
  _StudentViewState createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  List<ScheduleEntry> schedule = [];

  @override
  void initState() {
    super.initState();
    loadSchedule();
  }

  void loadSchedule() async {
    schedule = await FirestoreService.getStudentSchedule(widget.userId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Schedule")),
      body: ListView.builder(
        itemCount: schedule.length,
        itemBuilder: (context, index) {
          final entry = schedule[index];
          return Card(
            color: entry.type == "Lecture"
                ? AppColors.lectureColor
                : entry.type == "Lab"
                    ? AppColors.labColor
                    : AppColors.sectionColor,
            child: ListTile(
              title: Text(entry.courseName),
              subtitle: Text("${entry.startTime} - ${entry.endTime}"),
            ),
          );
        },
      ),
    );
  }
}
