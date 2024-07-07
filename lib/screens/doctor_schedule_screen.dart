import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class DoctorScheduleScreen extends StatefulWidget {
  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _buttonIndex = 0;

  final _scheduleWidgets = [
    UpcomingDoctorSchedule(),
    CompletedDoctorSchedule(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Text(
              "Schedule",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Color(0xFFF4F6FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _buttonIndex = 0;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                    decoration: BoxDecoration(
                      color: _buttonIndex == 0
                          ? Colors.blue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Upcoming",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _buttonIndex == 0 ? Colors.white : Colors.black38,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _buttonIndex = 1;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                    decoration: BoxDecoration(
                      color: _buttonIndex == 1
                          ? Colors.blue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Completed",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _buttonIndex == 1 ? Colors.white : Colors.black38,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Expanded(
            child: _scheduleWidgets[_buttonIndex],
          ),
        ],
      ),
    );
  }
}

class UpcomingDoctorSchedule extends StatefulWidget {
  @override
  _UpcomingDoctorScheduleState createState() => _UpcomingDoctorScheduleState();
}

class _UpcomingDoctorScheduleState extends State<UpcomingDoctorSchedule> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> _fetchAppointments() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    String? doctorId = await _getDoctorDocumentId(user.email);
    if (doctorId == null) {
      return [];
    }

    final doctorAppointmentsRef = FirebaseFirestore.instance
        .collection('Doctors')
        .doc(doctorId)
        .collection('appointments')
        .where('date', isGreaterThan: Timestamp.now());

    QuerySnapshot<Map<String, dynamic>> snapshot = await doctorAppointmentsRef.get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<String?> _getDoctorDocumentId(String? authEmail) async {
    if (authEmail == null) {
      return null;
    }

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('Doctors')
              .where('email', isEqualTo: authEmail)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      } else {
        return null;
      }
    } catch (e, stackTrace) {
      print('Error fetching doctor document ID: $e');
      print(stackTrace);
      return null;
    }
  }

  Future<void> _showRescheduleDialog(String appointmentId) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        DateTime newDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        _rescheduleAppointment(appointmentId, newDateTime);
      }
    }
  }

  Future<void> _rescheduleAppointment(String appointmentId, DateTime newDateTime) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No user is currently logged in'),
        ));
        return;
      }

      String? doctorId = await _getDoctorDocumentId(user.email);
      if (doctorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Doctor document ID not found'),
        ));
        return;
      }

      final doctorAppointmentsRef = FirebaseFirestore.instance
          .collection('Doctors')
          .doc(doctorId)
          .collection('appointments');

      await doctorAppointmentsRef.doc(appointmentId).update({
        'date': Timestamp.fromDate(newDateTime),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Appointment rescheduled successfully!'),
      ));
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to reschedule appointment: $error'),
      ));
    }
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No user is currently logged in'),
        ));
        return;
      }

      String? doctorId = await _getDoctorDocumentId(user.email);
      if (doctorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Doctor document ID not found'),
        ));
        return;
      }

      final doctorAppointmentsRef = FirebaseFirestore.instance
          .collection('Doctors')
          .doc(doctorId)
          .collection('appointments');

      await doctorAppointmentsRef.doc(appointmentId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Appointment cancelled successfully!'),
      ));
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to cancel appointment: $error'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchAppointments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error fetching appointments'));
        }
        final appointments = snapshot.data ?? [];
        if (appointments.isEmpty) {
          return Center(child: Text('No upcoming appointments'));
        }
        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            final timestamp = appointment['date'] as Timestamp;
            final dateTime = timestamp.toDate();
            final formattedDate =
                DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);

            return ListTile(
              title: Text('Date: $formattedDate'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showRescheduleDialog(appointment['id']);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _cancelAppointment(appointment['id']);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class CompletedDoctorSchedule extends StatefulWidget {
  @override
  _CompletedDoctorScheduleState createState() => _CompletedDoctorScheduleState();
}

class _CompletedDoctorScheduleState extends State<CompletedDoctorSchedule> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> _fetchAppointments() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    String? doctorId = await _getDoctorDocumentId(user.email);
    if (doctorId == null) {
      return [];
    }

    final doctorAppointmentsRef = FirebaseFirestore.instance
        .collection('Doctors')
        .doc(doctorId)
        .collection('appointments')
        .where('date', isLessThan: Timestamp.now());

    QuerySnapshot<Map<String, dynamic>> snapshot = await doctorAppointmentsRef.get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<String?> _getDoctorDocumentId(String? authEmail) async {
    if (authEmail == null) {
      return null;
    }

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('Doctors')
              .where('email', isEqualTo: authEmail)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      } else {
        return null;
      }
    } catch (e, stackTrace) {
      print('Error fetching doctor document ID: $e');
      print(stackTrace);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchAppointments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error fetching appointments'));
        }
        final appointments = snapshot.data ?? [];
        if (appointments.isEmpty) {
          return Center(child: Text('No completed appointments'));
        }
        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            final timestamp = appointment['date'] as Timestamp;
            final dateTime = timestamp.toDate();
            final formattedDate =
                DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);

            return ListTile(
              title: Text('Date: $formattedDate'),
            );
          },
        );
      },
    );
  }
}
