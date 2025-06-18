import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:graduation_project/constants.dart';

class PendingAppointmentsScreen extends StatefulWidget {
  const PendingAppointmentsScreen({super.key});

  @override
  State<PendingAppointmentsScreen> createState() =>
      _PendingAppointmentsScreenState();
}

class _PendingAppointmentsScreenState extends State<PendingAppointmentsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> appointments = [];

  @override
  void initState() {
    super.initState();
    fetchPendingAppointments();
  }

  Future<void> fetchPendingAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get all pending appointments
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('clinic_appointments')
          .where('status', isEqualTo: 'pending')
          .get();

      print(
          'Found ${querySnapshot.docs.length} pending appointments'); // Debug print

      List<Map<String, dynamic>> tempAppointments = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        tempAppointments.add(data);
      }

      setState(() {
        appointments = tempAppointments;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching pending appointments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('clinic_appointments')
          .doc(appointmentId)
          .update({'status': status});

      // Refresh the list
      fetchPendingAppointments();
    } catch (e) {
      print('Error updating appointment status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: MyAppBar(
        title: localizations?.pendingAppointments ?? 'Pending Appointments',
        onpressed: () {
          Navigator.pop(context);
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : appointments.isEmpty
              ? Center(
                  child: Text(localizations?.noPendingAppointments ??
                      'No pending appointments'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];

                    // Parse date for formatting
                    DateTime appointmentDate =
                        DateTime.parse(appointment['date']);
                    String dayNumber = DateFormat('d').format(appointmentDate);
                    String dayName = DateFormat('EEEE').format(appointmentDate);
                    String monthName =
                        DateFormat('MMMM').format(appointmentDate);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFFDCEAF5), // Light blue background
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Time',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  appointment['time'],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (context) => Container(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Patient: ${appointment['patientName'] ?? appointment['name'] ?? "Unknown"}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Problem Details:',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          appointment['problem'] ??
                                              'No details provided',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Close'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Date header
                                    const Text(
                                      'Date',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Day number and name
                                    Row(
                                      children: [
                                        Text(
                                          dayNumber,
                                          style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dayName,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              monthName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Patient information
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.person_outline,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Patient: ${appointment['patientName'] ?? appointment['name'] ?? "Unknown"}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.medical_services_outlined,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Problem: ${appointment['problem']}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Action buttons
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // Approve button
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              updateAppointmentStatus(
                                                  appointment['id'],
                                                  'completed');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: kPrimaryColor,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                            ),
                                            child: const Text('Approve'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Reject button
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              updateAppointmentStatus(
                                                  appointment['id'],
                                                  'cancelled');
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.red,
                                              side: const BorderSide(
                                                  color: Colors.red),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                            ),
                                            child: const Text('Reject'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
