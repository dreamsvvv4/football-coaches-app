import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  void _submit() async {
    setState(() => _loading = true);
    final request = LoginRequest(
      emailOrUsername: _usernameController.text.trim(),
      password: _passwordController.text,
      rememberMe: true,
    );
    final response = await AuthService.instance.login(request);
    setState(() => _loading = false);
    if (response) {
      if (!mounted) return;
      // Navegar a home
      Navigator.pushReplacementNamed(context, '/');
    } else {
      setState(() => _errorMessage = 'Login fallido. Verifica usuario y contraseña.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Usuario'),
              keyboardType: TextInputType.text,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading ? const CircularProgressIndicator() : const Text('Entrar'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('Crear nueva cuenta'),
            )
          ],
        ),
      ),
    );
  }
}
