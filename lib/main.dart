import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/songo_theme.dart';

void main() {
  runApp(const SongoApp());
}

class SongoApp extends StatelessWidget {
  const SongoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Songo',
      theme: buildSongoTheme(),
      home: const HomeScreen(),
    );
  }
}
