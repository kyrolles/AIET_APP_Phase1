import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project/screens/offline_feature/reusable_offline.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key});

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  String fullName = '';
  String age = '';
  DateTime selectedDate = DateTime.now();
  String? selectedTime;
  String selectedGender = 'Male';
  final TextEditingController _problemController = TextEditingController();
  final List<String> timeSlots = [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '01:00PM',
    '01:30PM',
    '02:00PM',
    '02:30 PM',
    '03:00PM',
    '03:30 PM',
    '04:00PM',
    '04:30 PM',
  ];
  Map<String, List<String>> bookedTimeSlots = {};
  bool isLoading = true;
  String userId = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchBookedAppointments();
  }

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userId = user.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            fullName = '${userDoc['firstName']} ${userDoc['lastName']}';

            if (userDoc['birthDate'] != null &&
                userDoc['birthDate'].isNotEmpty) {
              try {
                final birthDate = DateTime.parse(userDoc['birthDate']);
                final now = DateTime.now();
                int age = now.year - birthDate.year;
                if (now.month < birthDate.month ||
                    (now.month == birthDate.month && now.day < birthDate.day)) {
                  age--;
                }
                this.age = age.toString();
              } catch (e) {
                this.age = '';
              }
            }
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  bool isTimeSlotBooked(String time) {
    final dateString = DateFormat('yyyy-MM-dd').format(selectedDate);
    return bookedTimeSlots.containsKey(dateString) &&
        bookedTimeSlots[dateString]!.contains(time);
  }

  Future<void> _fetchBookedAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final now = DateTime.now();
      final thirtyDaysLater = now.add(const Duration(days: 30));

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('clinic_appointments')
          .where('date',
              isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(now))
          .where('date',
              isLessThanOrEqualTo:
                  DateFormat('yyyy-MM-dd').format(thirtyDaysLater))
          .get();

      Map<String, List<String>> tempBookedSlots = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final date = data['date'] as String;
        final time = data['time'] as String;
        final status = data['status'] as String;

        if (status != 'cancelled') {
          if (tempBookedSlots.containsKey(date)) {
            tempBookedSlots[date]!.add(time);
          } else {
            tempBookedSlots[date] = [time];
          }
        }
      }

      setState(() {
        bookedTimeSlots = tempBookedSlots;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching booked appointments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> _saveAppointment() async {
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(selectedDate);

      if (isTimeSlotBooked(selectedTime!)) {
        return false;
      }

      await FirebaseFirestore.instance.collection('clinic_appointments').add({
        'userId': userId,
        'patientName': fullName,
        'age': age,
        'gender': selectedGender,
        'problem': _problemController.text.trim(),
        'date': dateString,
        'time': selectedTime,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error saving appointment: $e');
      return false;
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: MyAppBar(
        title: 'New Appointment',
        onpressed: () {
          Navigator.pop(context);
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ReusableOffline(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${DateFormat('MMMM').format(selectedDate)}, ${selectedDate.year}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 7,
                          itemBuilder: (context, index) {
                            final date =
                                DateTime.now().add(Duration(days: index));
                            final isSelected = selectedDate.day == date.day &&
                                selectedDate.month == date.month &&
                                selectedDate.year == date.year;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDate = date;
                                  if (selectedTime != null &&
                                      isTimeSlotBooked(selectedTime!)) {
                                    selectedTime = null;
                                  }
                                });
                              },
                              child: Container(
                                width: 50,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('E').format(date)[0],
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Available Time',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: timeSlots.length,
                        itemBuilder: (context, index) {
                          final time = timeSlots[index];
                          final isSelected = selectedTime == time;
                          final isBooked = isTimeSlotBooked(time);

                          return GestureDetector(
                            onTap: isBooked
                                ? null
                                : () {
                                    setState(() {
                                      selectedTime = time;
                                    });
                                  },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isBooked
                                    ? Colors.grey.shade400
                                    : isSelected
                                        ? Colors.blue
                                        : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                time,
                                style: TextStyle(
                                  color: isBooked
                                      ? Colors.grey.shade700
                                      : isSelected
                                          ? Colors.white
                                          : Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Patient Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        localizations?.fullName ?? 'Full name',
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        width: double.infinity,
                        child: Text(fullName),
                      ),
                      const SizedBox(height: 15),
                      Text(localizations?.age ?? 'Age'),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(age),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(localizations?.gender ?? 'Gender'),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedGender = 'Male';
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: selectedGender == 'Male'
                                      ? Colors.blue
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedGender == 'Male'
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  localizations?.male ?? 'Male',
                                  style: TextStyle(
                                    color: selectedGender == 'Male'
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedGender = 'Female';
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: selectedGender == 'Female'
                                      ? Colors.blue
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedGender == 'Female'
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  localizations?.female ?? 'Female',
                                  style: TextStyle(
                                    color: selectedGender == 'Female'
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(localizations?.writeYourProblem ??
                          'Write your problem'),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _problemController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: localizations?.writeYourProblem ??
                              'Write your problem',
                          filled: true,
                          fillColor: Colors.blue.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (selectedTime == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        localizations?.pleaseSelectTimeSlot ??
                                            'Please select a time slot')),
                              );
                              return;
                            }

                            if (_problemController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        localizations?.pleaseDescribeProblem ??
                                            'Please describe your problem')),
                              );
                              return;
                            }

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                  child: CircularProgressIndicator()),
                            );

                            final success = await _saveAppointment();

                            Navigator.pop(context);

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(localizations
                                            ?.appointmentSetSuccessfully ??
                                        'Appointment set successfully')),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(localizations
                                            ?.timeSlotAlreadyBooked ??
                                        'This time slot is already booked. Please select another time.')),
                              );
                              _fetchBookedAppointments();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Set Appointment',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
