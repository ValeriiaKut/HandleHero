import 'package:flutter/material.dart';
import 'package:handle_hero/ui/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme:  ThemeData(useMaterial3: true,
      ).copyWith(
        textTheme: Typography().black.apply(fontFamily: 'PressStart2P')
      ),
      home:  const HomePage(),
    );
  }
}

