import 'package:flutter/material.dart';
import 'package:handle_hero/ui/auth/auth_screens.dart';
import 'package:handle_hero/ui/home/home_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final Map<String, String> _sessionAccounts = {};
  String? _signedInEmail;

  @override
  Widget build(BuildContext context) {
    final email = _signedInEmail;
    if (email != null) {
      return HomePage(
        userEmail: email,
        onLogout: () => setState(() => _signedInEmail = null),
      );
    }

    return LoginScreen(
      onLogin: (email, password) {
        final normalizedEmail = email.trim().toLowerCase();
        if (_sessionAccounts[normalizedEmail] != password) return false;
        setState(() => _signedInEmail = normalizedEmail);
        return true;
      },
      onOpenRegistration: _openRegistration,
    );
  }

  Future<void> _openRegistration() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => RegistrationScreen(onRegister: _register),
      ),
    );
  }

  bool _register(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    if (_sessionAccounts.containsKey(normalizedEmail)) return false;
    _sessionAccounts[normalizedEmail] = password;
    return true;
  }
}
