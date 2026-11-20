import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:handle_hero/bloc/home/home_bloc.dart';
import 'package:handle_hero/bloc/level/level_bloc.dart';
import 'package:handle_hero/ui/auth/auth_gate.dart';
import 'package:handle_hero/firebase_options.dart';
import 'package:handle_hero/utils/my_images.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeBloc()),
        BlocProvider(create: (_) => LevelBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
        ).copyWith(
          textTheme: Typography().black.apply(fontFamily: 'PressStart2P'),
        ),
        home: const _StartupScreen(),
      ),
    );
  }
}

class _StartupScreen extends StatefulWidget {
  const _StartupScreen();

  @override
  State<_StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<_StartupScreen> {
  bool _showSplash = defaultTargetPlatform == TargetPlatform.android;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    if (_showSplash) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      _splashTimer = Timer(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        setState(() => _showSplash = false);
      });
    }
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showSplash) return const AuthGate();
    return const Scaffold(
      body: SizedBox.expand(
        child: Image(image: AssetImage(MyImages.splashScreen), fit: BoxFit.cover),
      ),
    );
  }
}
