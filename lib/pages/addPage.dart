import 'package:flutter/material.dart';

class addPointPage extends StatelessWidget {
  const addPointPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.black),
        child: const Icon(
          Icons.add,
          size: 70,
          color: Colors.white,
        ),
      ),
    );
  }
} // addPoint class end
