import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../services/firestore_service.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  _AdminViewState createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  List<ScheduleEntry> schedule = [];

  @override
  void initState() {
    super.initState();
    loadSchedule();
  }

  void loadSchedule() async {
    schedule = await FirestoreService.getFullSchedule();
    setState(() {});
  }

  void reviewRequest(String requestId, bool approve) {
    FirestoreService.updateRequestStatus(requestId, approve);
    loadSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: ListView.builder(
        itemCount: schedule.length,
        itemBuilder: (context, index) {
          final entry = schedule[index];
          return Card(
            child: ListTile(
              title: Text(entry.courseName),
              subtitle: Text("Instructor: ${entry.lecturer}"),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text("Edit"),
              ),
            ),
          );
        },
      ),
    );
  }
}
