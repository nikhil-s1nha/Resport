import 'package:flutter/material.dart';

class GetScreen extends StatelessWidget {
  const GetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Equipment'),
      ),
      body: Center(
        child: Text('List of Equipment Goes Here'),
      ),
    );
  }
}