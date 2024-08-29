
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_app/screens/welcome_screen.dart';

import '../firebase_authentication/firebase_auth_services.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
    required this.title, // Make the title required
  });

  final String title; // Add a title property

  

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
      )),
      backgroundColor: Colors.red,
      elevation: 1,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
        ),
      ),
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(Icons.security, color: Colors.white),
            SizedBox(width: 8.0),
            Flexible(
              child: Text(
                'Campus Safety',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              // Add padding to shift the profile picture and menu left
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage('https://picsum.photos/200'),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (String item) {
                  if (item == 'Profile') {
                    // Navigate to profile page
                  } else if (item == 'Logout') {}
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'Profile',
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Colors.black),
                          SizedBox(width: 8.0),
                          Text('Profile'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'Logout',
                      child: GestureDetector(
                        onTap: () async {
                          await FirebaseAuthService().signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const WelcomeScreen()), // Replace with your target screen
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.logout, color: Colors.black),
                            SizedBox(width: 8.0),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                offset: const Offset(0, 40),
                padding: const EdgeInsets.only(
                    left:
                        8.0), // Adjust this value to move the menu down if needed
                child: const Icon(Icons.more_vert, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
      toolbarHeight: 60,
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}
