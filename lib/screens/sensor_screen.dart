import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SensorScreen extends StatelessWidget {
  final String patientUsername;

  SensorScreen({required this.patientUsername});

  List<String> sensorTexts = [
    "pulse",
    "mq",
    "humidity",
    "rtmp",
    "htmp",
    "fsr_up",
    "fsr_down", 
    "fsr_right", 
    "fsr_left", 
  ];

  Future<List<String>> _fetchSensorData() async {
    List<String> sensorData = List.filled(sensorTexts.length, "No Data");

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Patients')
          .where('username', isEqualTo: patientUsername)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> doc = snapshot.docs.first;

        QuerySnapshot<Map<String, dynamic>> readingsSnapshot = await FirebaseFirestore.instance
            .collection('Patients')
            .doc(doc.id)
            .collection('readings')
            .orderBy('timestamp', descending: true) // Assuming there is a timestamp field
            .limit(1)
            .get();

        if (readingsSnapshot.docs.isNotEmpty) {
          DocumentSnapshot<Map<String, dynamic>> latestReading = readingsSnapshot.docs.first;
          Map<String, dynamic> readingsData = latestReading.data()!;
          for (var i = 0; i < sensorTexts.length; i++) {
            String sensorName = sensorTexts[i];
            sensorData[i] = readingsData[sensorName]?.toString() ?? "No Data";
          }
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    }

    return sensorData;
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
                          backgroundImage: AssetImage("images/user.jpg"),
                        ),
                        SizedBox(height: 15),
                        Text(
                          patientUsername,
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
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
              child: FutureBuilder<List<String>>(
                future: _fetchSensorData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error fetching readings'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No readings available'));
                  }

                  List<String> sensorData = snapshot.data!;
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        SizedBox(height: 10),
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
                                        sensorData[index],
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
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
