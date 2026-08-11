import 'package:flutter/material.dart';

import 'home/home_screen.dart';
import 'theme.dart';

class InAPickleApp extends StatelessWidget {
  const InAPickleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'In a Pickle',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeScreen(),
    );
  }
}