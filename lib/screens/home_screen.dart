import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Resport",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
            )
        ),
        backgroundColor: const Color(0xFF1F402D), // Olive green color //const to reduce loop time
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/give');
                },
                child: const Text('GIVE'),
              )
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: 100,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/get');
                },
                child: const Text('GET'),
              )
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: 120,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/sign-up');
                  },
                  child: const Text('SIGN UP')),
            ),
            const SizedBox(height: 40),
            Container(
              width: 350,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: const Color(0xFF2a573d),
                  borderRadius: BorderRadius.circular(4)
              ),
              child: const Text(
                'ALL FUNDS DIRECTED TO SMZO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )
              )
            )
          ],
        )
    ),
    );
  }
}