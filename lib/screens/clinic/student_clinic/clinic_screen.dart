import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ClinicScreen extends StatelessWidget {
  const ClinicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Clinic',
        onpressed: () {
          Navigator.pop(context);
        },
      ),
      body: const ClinicBody(),
    );
  }
}

class ClinicBody extends StatefulWidget {
  const ClinicBody({
    super.key,
  });

  @override
  State<ClinicBody> createState() => _ClinicBodyState();
}

class _ClinicBodyState extends State<ClinicBody> {
  bool isLoading = true;
  List<Map<String, dynamic>> appointments = [];
  DocumentSnapshot? lastDocument;
  bool hasMoreAppointments = true;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    fetchUserAppointments();
  }

  Future<void> fetchUserAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('clinic_appointments')
            .where('userId', isEqualTo: userId)
            .orderBy('date', descending: true)
            .limit(10)
            .get();
        
        List<Map<String, dynamic>> tempAppointments = [];
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          tempAppointments.add(data);
        }
        
        tempAppointments.sort((a, b) {
          if (a['status'] == 'pending' && b['status'] != 'pending') {
            return -1;
          }
          if (b['status'] == 'pending' && a['status'] != 'pending') {
            return 1;
          }
          return DateTime.parse(b['date']).compareTo(DateTime.parse(a['date']));
        });

        setState(() {
          appointments = tempAppointments;
          isLoading = false;
          lastDocument = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
          hasMoreAppointments = querySnapshot.docs.length >= 10;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching appointments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadMoreAppointments() async {
    if (!hasMoreAppointments || isLoadingMore || lastDocument == null) return;
    
    setState(() {
      isLoadingMore = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;
        
        final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('clinic_appointments')
            .where('userId', isEqualTo: userId)
            .orderBy('date', descending: true)
            .startAfterDocument(lastDocument!)
            .limit(10)
            .get();

        List<Map<String, dynamic>> moreAppointments = [];
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          moreAppointments.add(data);
        }

        moreAppointments.sort((a, b) {
          if (a['status'] == 'pending' && b['status'] != 'pending') {
            return -1;
          }
          if (b['status'] == 'pending' && a['status'] != 'pending') {
            return 1;
          }
          return DateTime.parse(b['date']).compareTo(DateTime.parse(a['date']));
        });

        setState(() {
          appointments.addAll(moreAppointments);
          isLoadingMore = false;
          lastDocument = querySnapshot.docs.isNotEmpty 
              ? querySnapshot.docs.last 
              : lastDocument;
          hasMoreAppointments = querySnapshot.docs.length >= 10;
        });
      }
    } catch (e) {
      print('Error loading more appointments: $e');
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green.shade800;
      case 'cancelled':
        return Colors.red.shade800;
      case 'pending':
      default:
        return Colors.orange.shade800;
    }
  }

  String getStatusText(String? status) {
    if (status == null) return 'Pending';
    if (status == 'completed') return 'Approved';
    return status.toString()[0].toUpperCase() + status.toString().substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          
          Container(
            height: 450,
            decoration: BoxDecoration(
              color: const Color(0xFF39A0FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                
                const Positioned(
                  top: 30,
                  left: 25,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  [
                      Text(
                        'Book your',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'appointments',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/project_image/illustration.svg',
                      height: 250,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
         
          KButton(
            onPressed: () {
              Navigator.pushNamed(
                  context, '/clinicStudentScreen/newAppointmentScreen')
                  .then((_) {
                fetchUserAppointments();
              });
            },
            text: 'New Appointment',
            backgroundColor: const Color(0xFF39A0FF),
          ),
          
          const SizedBox(height: 24),
          
          
          const Text(
            'Your Appointments',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : appointments.isEmpty
                  ? const Center(
                      child: Text(
                        'No appointment has been booked',
                        style: TextStyle(color: kGrey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: appointments.length + (hasMoreAppointments ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == appointments.length && hasMoreAppointments) {
                          loadMoreAppointments();
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        
                        if (index >= appointments.length) {
                          return const SizedBox.shrink();
                        }
                        
                        final appointment = appointments[index];
                        
                        DateTime appointmentDate = DateTime.parse(appointment['date']);
                        String dayNumber = DateFormat('d').format(appointmentDate);
                        String dayName = DateFormat('EEEE').format(appointmentDate);
                        String monthName = DateFormat('MMMM').format(appointmentDate);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCEAF5),
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
                                      const Text(
                                        'Date',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      
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
                                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                      
                                      const Row(
                                        children: [
                                           Icon(
                                            Icons.location_on_outlined,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                           SizedBox(width: 8),
                                           Text(
                                            'Room 2-168',
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: appointment['status'] == 'pending' 
                                                  ? Colors.orange.shade100 
                                                  : appointment['status'] == 'cancelled'
                                                      ? Colors.red.shade100
                                                      : Colors.green.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              getStatusText(appointment['status']),
                                              style: TextStyle(
                                                color: getStatusColor(appointment['status']),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (appointment['status'] == 'pending')
                                            TextButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Cancel Appointment'),
                                                    content: const Text('Are you sure you want to cancel this appointment?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('No'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          Navigator.pop(context);
                                                          await FirebaseFirestore.instance
                                                              .collection('clinic_appointments')
                                                              .doc(appointment['id'])
                                                              .update({'status': 'cancelled'});
                                                          fetchUserAppointments();
                                                        },
                                                        child: const Text('Yes'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              child: const Text('Cancel'),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}