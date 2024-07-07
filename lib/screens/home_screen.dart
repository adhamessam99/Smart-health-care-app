import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:healthcare/screens/appointment_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  String a1 = 'null', a2 = 'null', a3 = 'null', a4 = 'null', a5 = 'null';
  String b1 = 'null', b2 = 'null', b3 = 'null', b4 = 'null';

  List<String> sensorTexts = [
    "Pulse",
    "Mq",
    "Humidity",
    "Rtmp",
    "Htmp",
    "Fsr_Up",
    "Fsr_Down",
    "Fsr_Right",
    "Fsr_Left",
  ];

  List<String> sensorData = [];
  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    fetchData();
  }

  Future<void> _fetchUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
            .collection('Patients')
            .where('email', isEqualTo: user.email)
            .get();

        if (snapshot.docs.isNotEmpty) {
          setState(() {
            _userName = snapshot.docs.first['username'];
          });
        }
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  Future<void> fetchData() async {
    final channelId1 = '2390565';
    final apiKey1 = '32CK1R5KS1U488B1';
    final numResults = 2;

    final url2 = Uri.parse("https://api.thingspeak.com/channels/$channelId1/fields/2.json?api_key=$apiKey1&results=$numResults");
    final url3 = Uri.parse("https://api.thingspeak.com/channels/$channelId1/fields/3.json?api_key=$apiKey1&results=$numResults");
    final url4 = Uri.parse("https://api.thingspeak.com/channels/$channelId1/fields/4.json?api_key=$apiKey1&results=$numResults");
    final url5 = Uri.parse("https://api.thingspeak.com/channels/$channelId1/fields/5.json?api_key=$apiKey1&results=$numResults");
    final url6 = Uri.parse("https://api.thingspeak.com/channels/$channelId1/fields/6.json?api_key=$apiKey1&results=$numResults");

    final feeds2 = await fetchFieldData(url2);
    final feeds3 = await fetchFieldData(url3);
    final feeds4 = await fetchFieldData(url4);
    final feeds5 = await fetchFieldData(url5);
    final feeds6 = await fetchFieldData(url6);

    setState(() {
      a1 = feeds2.isNotEmpty ? feeds2[0]['field2'] ?? 'null' : 'null';
      a2 = feeds3.isNotEmpty ? feeds3[0]['field3'] ?? 'null' : 'null';
      a3 = feeds4.isNotEmpty ? feeds4[0]['field4'] ?? 'null' : 'null';
      a4 = feeds5.isNotEmpty ? feeds5[0]['field5'] ?? 'null' : 'null';
      a5 = feeds6.isNotEmpty ? feeds6[0]['field6'] ?? 'null' : 'null';
    });

    final channelId2 = '2392813';
    final apiKey2 = '2HV9AEXBAM9HIW87';

    final url7 = Uri.parse("https://api.thingspeak.com/channels/$channelId2/fields/1.json?api_key=$apiKey2&results=$numResults");
    final url8 = Uri.parse("https://api.thingspeak.com/channels/$channelId2/fields/2.json?api_key=$apiKey2&results=$numResults");
    final url9 = Uri.parse("https://api.thingspeak.com/channels/$channelId2/fields/3.json?api_key=$apiKey2&results=$numResults");
    final url10 = Uri.parse("https://api.thingspeak.com/channels/$channelId2/fields/4.json?api_key=$apiKey2&results=$numResults");

    final feeds7 = await fetchFieldData(url7);
    final feeds8 = await fetchFieldData(url8);
    final feeds9 = await fetchFieldData(url9);
    final feeds10 = await fetchFieldData(url10);

    setState(() {
      b1 = feeds7.isNotEmpty ? feeds7[0]['field1'] ?? 'null' : 'null';
      b2 = feeds8.isNotEmpty ? feeds8[0]['field2'] ?? 'null' : 'null';
      b3 = feeds9.isNotEmpty ? feeds9[0]['field3'] ?? 'null' : 'null';
      b4 = feeds10.isNotEmpty ? feeds10[0]['field4'] ?? 'null' : 'null';
    });

    storeDataInFirebase();

    setState(() {
      sensorData = [a1, a2, a3, a4, a5, b1, b2, b3, b4];
      _isLoading = false;
    });
  }

  Future<List<dynamic>> fetchFieldData(Uri url) async {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['feeds'] as List<dynamic>;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> storeDataInFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Patients')
          .where('email', isEqualTo: user.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String docId = snapshot.docs.first.id;

        await FirebaseFirestore.instance
            .collection('Patients')
            .doc(docId)
            .collection('readings')
            .add({
          'pulse': a1,
          'mq': a2,
          'humidity': a3,
          'rtmp': a4,
          'htmp': a5,
          'fsr_up': b1,
          'fsr_down': b2,
          'fsr_right': b3,
          'fsr_left': b4,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Hello $_userName", // Display dynamic username
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage("images/user.jpg"),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      // Your other widgets
                    ),
                    SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        "Sensor Data",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.0,
                      ),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: sensorTexts.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2.0,
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  'images/sensor.png',
                                  width: 100,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sensorTexts[index],
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    sensorData.length > index
                                        ? sensorData[index]
                                        : 'Loading...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        "Doctors",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('Doctors').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        var doctors = snapshot.data!.docs;
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          itemCount: doctors.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            var doctor = doctors[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AppointmentScreen(
                                      doctorData: {
                                        'username': doctor['username'],
                                        'specialization': doctor['specialization'],
                                        'description': doctor['description'],
                                        'rating': doctor['rating'],
                                        'reviewsCount': doctor['reviewsCount'],
                                        'reviews': doctor['reviews'],
                                        'location': doctor['location'],
                                        'price': doctor['price'],
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.all(10),
                                padding: EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CircleAvatar(
                                      radius: 35,
                                      backgroundImage: AssetImage("images/doctorimg.jpg"),
                                    ),
                                    Text(
                                      doctor['username'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      doctor['specialization'],
                                      style: TextStyle(
                                        color: Colors.black45,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        Text(
                                          doctor['rating'].toString(),
                                          style: TextStyle(
                                            color: Colors.black45,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}