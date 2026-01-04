import 'package:flutter/material.dart';
import 'package:password_generator/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  final Color customColor = const Color.fromARGB(255, 40, 4, 112);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
      ),
      // home: const Encryptor(),
      home: const Home(),
    );
  }
}
