import 'package:ai_mock_interview/core/constants/app_routes.dart';
import 'package:ai_mock_interview/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isRegistering = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final AuthController controller = ref.read(authControllerProvider.notifier);
    final bool success = _isRegistering
        ? await controller.register(name: _nameController.text, email: _emailController.text, password: _passwordController.text)
        : await controller.signIn(email: _emailController.text, password: _passwordController.text);
    if (success && mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final AuthState authState = ref.watch(authControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Icon(Icons.record_voice_over_rounded, color: Theme.of(context).colorScheme.primary, size: 42),
                      const SizedBox(height: 20),
                      Text(_isRegistering ? 'Create your account' : 'Welcome back', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(_isRegistering ? 'Start practicing interviews with focused feedback.' : 'Sign in to continue your interview practice.', style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 24),
                      if (_isRegistering) ...<Widget>[
                        TextFormField(controller: _nameController, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline_rounded)), validator: (String? value) => value == null || value.trim().isEmpty ? 'Enter your name.' : null),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)), validator: (String? value) => value == null || !value.contains('@') ? 'Enter a valid email address.' : null),
                      const SizedBox(height: 16),
                      TextFormField(controller: _passwordController, obscureText: _obscurePassword, onFieldSubmitted: (_) => _submit(), decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline_rounded), suffixIcon: IconButton(onPressed: () => setState(() => _obscurePassword = !_obscurePassword), icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined))), validator: (String? value) => value == null || value.length < 8 ? 'Use at least 8 characters.' : null),
                      if (authState.errorMessage != null) ...<Widget>[const SizedBox(height: 16), Text(authState.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error))],
                      const SizedBox(height: 24),
                      SizedBox(width: double.infinity, child: FilledButton(onPressed: authState.isSubmitting ? null : _submit, child: authState.isSubmitting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_isRegistering ? 'Create account' : 'Sign in'))),
                      TextButton(onPressed: authState.isSubmitting ? null : () => setState(() => _isRegistering = !_isRegistering), child: Text(_isRegistering ? 'Already have an account? Sign in' : 'New here? Create an account')),
                      if (!_isRegistering) Align(alignment: Alignment.center, child: TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password recovery will be connected in the secure backend phase.'))), child: const Text('Forgot password?'))),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
