import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/home/home_bloc.dart';
import 'package:handle_hero/bloc/home/home_event.dart';
import 'package:handle_hero/ui/auth/auth_screens.dart';
import 'package:handle_hero/ui/home/home_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _syncedProfileUid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user != null) {
          if (_syncedProfileUid != user.uid) {
            _syncedProfileUid = user.uid;
            _syncProfile(user);
          }
          context.read<HomeBloc>().add(HomeStarted(user.uid));
          return HomePage(
            userEmail: user.email ?? '',
            userName: user.displayName ?? '',
            userId: user.uid,
            onLogout: () => _auth.signOut(),
          );
        }
        return LoginScreen(
          onLogin: _login,
          onOpenRegistration: _openRegistration,
        );
      },
    );
  }

  Future<void> _openRegistration() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => RegistrationScreen(onRegister: _register),
      ),
    );
    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully. Please log in.'),
        ),
      );
    }
  }

  Future<String?> _login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (error) {
      return switch (error.code) {
        'invalid-email' => 'Please enter a valid email address.',
        'user-not-found' || 'wrong-password' || 'invalid-credential' =>
          'Email or password is incorrect.',
        'network-request-failed' => 'Check your internet connection and try again.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        _ => 'Could not log in (${error.code}).',
      };
    }
  }

  Future<String?> _register(String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.reload();
      final user = _auth.currentUser;
      if (user != null) await _syncProfile(user);
      await _auth.signOut();
      return null;
    } on FirebaseAuthException catch (error) {
      return switch (error.code) {
        'email-already-in-use' => 'This email already has an account.',
        'invalid-email' => 'Please enter a valid email address.',
        'weak-password' => 'Choose a stronger password.',
        'operation-not-allowed' =>
          'Email and password sign-up is disabled in Firebase Authentication.',
        'network-request-failed' => 'Check your internet connection and try again.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        _ => 'Could not create account (${error.code}).',
      };
    }
  }

  Future<void> _syncProfile(User user) async {
    try {
      final reference = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final snapshot = await reference.get();
      await reference.set({
        'id': user.uid,
        'name': user.displayName ?? '',
        if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (error) {
      debugPrint('Could not sync Firebase profile: ${error.code}');
    }
  }
}
