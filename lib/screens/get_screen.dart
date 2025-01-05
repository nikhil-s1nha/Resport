import 'package:flutter/material.dart';

class GetScreen extends StatelessWidget {
  const GetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Get",
            style: TextStyle(
              color: Colors.white,
            )),
      ),
      body: Center(
        child: Text('List of Equipment Goes Here'),
      ),
    );
  }
}