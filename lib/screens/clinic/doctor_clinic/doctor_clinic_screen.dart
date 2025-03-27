import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorClinicScreen extends StatelessWidget {
  const DoctorClinicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Clinic',
        onpressed: () {
          Navigator.pop(context);
        },
      ),
      body: const DoctorClinicBody(),
    );
  }
}

class DoctorClinicBody extends StatefulWidget {
  const DoctorClinicBody({super.key});

  @override
  State<DoctorClinicBody> createState() => _DoctorClinicBodyState();
}

class _DoctorClinicBodyState extends State<DoctorClinicBody> {
  bool isLoading = true;
  int pendingCount = 0;
  int completedCount = 0;

  @override
  void initState() {
    super.initState();
    fetchAppointmentCounts();
  }

  Future<void> fetchAppointmentCounts() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot pendingSnapshot = await FirebaseFirestore.instance
          .collection('clinic_appointments')
          .where('status', isEqualTo: 'pending')
          .get();

      QuerySnapshot completedSnapshot = await FirebaseFirestore.instance
          .collection('clinic_appointments')
          .where('status', isEqualTo: 'completed')
          .get();

      setState(() {
        pendingCount = pendingSnapshot.docs.length;
        completedCount = completedSnapshot.docs.length;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching appointment counts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            'Clinic Management',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'lexend',
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Manage student appointments and medical requests',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 32),
          
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/doctorClinicScreen/pendingAppointmentsScreen')
                  .then((_) {
                fetchAppointmentCounts();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFDCEAF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.pending_actions,
                      color: kPrimaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pending Appointment Requests',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLoading ? 'Loading...' : '$pendingCount requests waiting for approval',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/doctorClinicScreen/completedAppointmentsScreen')
                  .then((_) {
                fetchAppointmentCounts();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFDCEAF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Appointments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLoading ? 'Loading...' : '$completedCount completed appointments',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}