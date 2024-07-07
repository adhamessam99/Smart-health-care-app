import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:healthcare/screens/doc_home_page.dart';
import 'package:healthcare/screens/doctor_schedule_screen.dart';
import 'package:healthcare/screens/messages_screen.dart';
import 'package:healthcare/screens/doctor_settings_screen.dart';
import 'package:healthcare/screens/settings_screen.dart';

class NavBar extends StatefulWidget {
  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;
  final _screens = [
    
    DocScreen(),
    MessagesScreen(),
    DoctorScheduleScreen(),
    DoctorSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        height: 80,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.black26,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled), label: "Doc"),
            BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.chat_bubble_text_fill,
                ),
                label: "Messages"),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined), label: "Schedule"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings"),
          ],
        ),
      ),
    );
  }
}
