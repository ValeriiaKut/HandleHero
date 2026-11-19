import 'package:flutter/material.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/treasure_ui.dart';

typedef LoginCallback = bool Function(String email, String password);
typedef RegistrationCallback = bool Function(String email, String password);

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onOpenRegistration,
  });

  final LoginCallback onLogin;
  final VoidCallback onOpenRegistration;

  @override
  Widget build(BuildContext context) => _AuthForm(
    isRegistration: false,
    onSubmit: onLogin,
    onOpenOtherScreen: onOpenRegistration,
  );
}

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({
    super.key,
    required this.onRegister,
  });

  final RegistrationCallback onRegister;

  @override
  Widget build(BuildContext context) => _AuthForm(
    isRegistration: true,
    onSubmit: onRegister,
    onOpenOtherScreen: () => Navigator.pop(context),
  );
}

class _AuthForm extends StatefulWidget {
  const _AuthForm({
    required this.isRegistration,
    required this.onSubmit,
    required this.onOpenOtherScreen,
  });

  final bool isRegistration;
  final bool Function(String email, String password) onSubmit;
  final VoidCallback onOpenOtherScreen;

  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isRegistration ? 'Create account' : 'Log in';
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(MyImages.backStone, fit: BoxFit.cover),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: TreasureWindow(
                    title: title,
                    backgroundColor: const Color(0xFF34382D),
                    titleBackgroundColor: const Color(0xFF617347),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _inputField(
                            label: 'EMAIL',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 14),
                          _inputField(
                            label: 'PASSWORD',
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            textInputAction: widget.isRegistration
                                ? TextInputAction.next
                                : TextInputAction.done,
                            autofillHints: [
                              widget.isRegistration
                                  ? AutofillHints.newPassword
                                  : AutofillHints.password,
                            ],
                            validator: _validatePassword,
                            suffix: IconButton(
                              tooltip: _showPassword
                                  ? 'Hide password'
                                  : 'Show password',
                              onPressed: () => setState(
                                () => _showPassword = !_showPassword,
                              ),
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFFD1C27E),
                              ),
                            ),
                          ),
                          if (widget.isRegistration) ...[
                            const SizedBox(height: 14),
                            _inputField(
                              label: 'CONFIRM PASSWORD',
                              controller: _confirmPasswordController,
                              obscureText: !_showConfirmPassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                              validator: (value) =>
                                  value == _passwordController.text
                                  ? null
                                  : 'Passwords do not match',
                              suffix: IconButton(
                                tooltip: _showConfirmPassword
                                    ? 'Hide password'
                                    : 'Show password',
                                onPressed: () => setState(
                                  () => _showConfirmPassword =
                                      !_showConfirmPassword,
                                ),
                                icon: Icon(
                                  _showConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFFD1C27E),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: TreasureButton(
                              label: widget.isRegistration
                                  ? 'CREATE ACCOUNT'
                                  : 'LOG IN',
                              labelColor: Colors.black,
                              labelShadow: false,
                              onPressed: _submit,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextButton(
                            onPressed: widget.onOpenOtherScreen,
                            child: Text(
                              widget.isRegistration
                                  ? 'Already have an account? Log in'
                                  : 'New here? Create an account',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFE3D9AA),
                                fontSize: 9,
                                height: 1.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required TextInputAction textInputAction,
    required List<String> autofillHints,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: 'Roboto',
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFE3D9AA), fontSize: 9),
        errorStyle: const TextStyle(color: Color(0xFFD99982), fontSize: 10),
        filled: true,
        fillColor: const Color(0xFF34382D),
        suffixIcon: suffix,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF7C806C), width: 3),
          borderRadius: BorderRadius.zero,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD1C27E), width: 3),
          borderRadius: BorderRadius.zero,
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB45D4D), width: 3),
          borderRadius: BorderRadius.zero,
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB45D4D), width: 3),
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').length < 6) return 'Use at least 6 characters';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final success = widget.onSubmit(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isRegistration
                ? 'This email is already registered.'
                : 'Email or password is incorrect. Register first if needed.',
          ),
        ),
      );
      return;
    }
    if (widget.isRegistration) Navigator.pop(context);
  }
}
