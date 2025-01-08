import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:resportcode/screens/profile_screen.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/get_screen.dart';
import 'screens/give_screen.dart';
import 'screens/sign_up_screen.dart';
import 'package:firebase_database/firebase_database.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseDatabase.instance.setPersistenceEnabled(false);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resport',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(), // Default screen
        '/give': (context) => const GiveScreen(),
        '/get': (context) => const GetScreen(),
        '/sign-up': (context) => const SignUpScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}