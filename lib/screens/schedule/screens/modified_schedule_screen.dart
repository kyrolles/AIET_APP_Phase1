import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../services/firestore_service.dart';

class ModifiedScheduleScreen extends StatefulWidget {
  const ModifiedScheduleScreen({super.key});

  @override
  _ModifiedScheduleScreenState createState() => _ModifiedScheduleScreenState();
}

class _ModifiedScheduleScreenState extends State<ModifiedScheduleScreen> {
  List<ScheduleChangeRequest> requests = [];

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  void loadRequests() async {
    requests = await FirestoreService.getPendingRequests();
    setState(() {});
  }

  void approveRequest(String requestId) {
    FirestoreService.updateRequestStatus(requestId, true);
    loadRequests();
  }

  void rejectRequest(String requestId) {
    FirestoreService.updateRequestStatus(requestId, false);
    loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule Requests")),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return Card(
            child: ListTile(
              title: Text(request.courseName),
              subtitle: Text("Requested by ${request.teacherId}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => approveRequest(request.requestId),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => rejectRequest(request.requestId),
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
