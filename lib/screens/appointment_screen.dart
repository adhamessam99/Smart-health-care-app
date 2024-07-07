import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  AppointmentScreen({required this.doctorData});

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _bookAppointment() async {
  // Check if date and time are selected
  if (selectedDate == null || selectedTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Please select date and time'),
    ));
    return;
  }

  // Get current user
  final User? user = _auth.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('No user is currently logged in'),
    ));
    return;
  }

  // Retrieve the Firestore document ID associated with the logged-in user's email
  String? patientDocId = await _getPatientDocumentId(user.email);
  if (patientDocId == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Patient document ID not found'),
    ));
    return;
  }

  // Retrieve the Firestore document ID of the selected doctor based on username
  String? doctorDocId = await _getDoctorDocumentId(widget.doctorData['username']);
  if (doctorDocId == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Doctor document ID not found'),
    ));
    return;
  }

  // Retrieve patient display name from Firebase Authentication
  String? patientDisplayName = user.displayName ?? 'Unknown';

  // Reference to the patient's document and appointments subcollection
  final patientRef = FirebaseFirestore.instance.collection('Patients').doc(patientDocId);
  final patientAppointmentsRef = patientRef.collection('appointments');

  // Reference to the doctor's document and appointments subcollection
  final doctorRef = FirebaseFirestore.instance.collection('Doctors').doc(doctorDocId);
  final doctorAppointmentsRef = doctorRef.collection('appointments');

  // Create DateTime object for the appointment
  final appointmentDateTime = DateTime(
    selectedDate!.year,
    selectedDate!.month,
    selectedDate!.day,
    selectedTime!.hour,
    selectedTime!.minute,
  );

  
  bool isSlotAvailable = await _checkAppointmentAvailability(doctorDocId, appointmentDateTime);
  if (!isSlotAvailable) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('This appointment slot is already booked. Please select another time.'),
    ));
    return;
  }

  
  final appointmentData = {
    'doctorName': widget.doctorData['username'],
    'date': appointmentDateTime,
  };

  try {
    
    await patientAppointmentsRef.add(appointmentData);

    
    await doctorAppointmentsRef.add(appointmentData);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Appointment booked successfully!'),
    ));
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Failed to book appointment: $error'),
    ));
  }
}


  Future<String?> _getDoctorDocumentId(String doctorUsername) async {
    try {
      // Query Firestore to find the document ID associated with the given doctor username
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Doctors')
          .where('username', isEqualTo: doctorUsername)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id; // Return the document ID
      } else {
        print('Doctor document not found for username: $doctorUsername');
        return null; // No document found
      }
    } catch (e, stackTrace) {
      print('Error fetching doctor document ID: $e');
      print(stackTrace); // Print the stack trace for more details
      return null;
    }
  }

  Future<String?> _getPatientDocumentId(String? authEmail) async {
    if (authEmail == null) {
      print('Auth email is null.');
      return null;
    }

    try {
      // Query Firestore to find the document ID associated with the given authEmail
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Patients')
          .where('email', isEqualTo: authEmail)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id; // Return the document ID
      } else {
        print('Patient document not found for authEmail: $authEmail');
        return null; // No document found
      }
    } catch (e, stackTrace) {
      print('Error fetching patient document ID: $e');
      print(stackTrace); // Print the stack trace for more details
      return null;
    }
  }

  Future<bool> _checkAppointmentAvailability(String? doctorDocId, DateTime appointmentDateTime) async {
    try {
      // Query Firestore to check if an appointment already exists for the selected doctor and time
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Doctors')
          .doc(doctorDocId)
          .collection('appointments')
          .where('date', isEqualTo: appointmentDateTime)
          .limit(1)
          .get();

      return snapshot.docs.isEmpty; // Return true if no appointments found (slot available)
    } catch (e, stackTrace) {
      print('Error checking appointment availability: $e');
      print(stackTrace); // Print the stack trace for more details
      return false; // Consider slot as unavailable on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage("images/doctorimg.jpg"),
                        ),
                        SizedBox(height: 15),
                        Text(
                          widget.doctorData['username'],
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          widget.doctorData['specialization'],
                          style: TextStyle(
                            color: Colors.white60,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.call,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.chat_bubble_text_fill,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: MediaQuery.of(context).size.height / 1.5,
              width: double.infinity,
              padding: EdgeInsets.only(
                top: 20,
                left: 15,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "About Doctor",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 5),
                  Text(
                    widget.doctorData['description'],
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Icon(Icons.star, color: Colors.amber),
                      Text(
                        widget.doctorData['rating'].toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 5),
                      Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "See all",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Location",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFFF0EEFA),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                    title: Text(
                      widget.doctorData['location'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text("address line of the medical center"),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Select Date and Time",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: Text(selectedDate == null
                            ? 'Select Date'
                            : DateFormat.yMMMd().format(selectedDate!)),
                      ),
                      ElevatedButton(
                        onPressed: () => _selectTime(context),
                        child: Text(selectedTime == null
                            ? 'Select Time'
                            : selectedTime!.format(context)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(15),
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Consultation price",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                Text(
                  "\$${widget.doctorData['price']}",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            InkWell(
              onTap: _bookAppointment,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Book Appointment",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
