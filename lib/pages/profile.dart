import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.black),
        child: const Icon(
          Icons.person,
          color: Colors.white,
          size: 70,
        ),
      ),
    );
  }
}// profilepage class end 
