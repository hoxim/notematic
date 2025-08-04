import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  late final ApiService _apiService;

  // API status
  String _apiStatus = 'checking';
  bool _isCheckingApi = false;

  @override
  void initState() {
    super.initState();
    _apiService = ref.read(apiServiceProvider);
    _checkApiStatus();
  }

  Future<void> _checkApiStatus() async {
    if (_isCheckingApi) return;

    setState(() {
      _isCheckingApi = true;
    });

    try {
      // Health check now uses Rust FFI (apiHealth)
      // TODO: Remove these lines and replace with proper HTTP health-check or remove API check section
      setState(() {
        _apiStatus = 'up'; // Placeholder for actual health check
      });
    } catch (e) {
      setState(() {
        _apiStatus = 'down';
      });
    } finally {
      setState(() {
        _isCheckingApi = false;
      });
    }
  }

  Future<void> _register(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final success = await _apiService.register(
      email: email,
      password: password,
    );
    if (success) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } else {
      setState(() {
        _errorMessage = 'Registration failed. Try again.';
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Google login temporarily disabled.

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter email';
                      }
                      if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).nextFocus();
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _register(
                      _emailController.text,
                      _passwordController.text,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _register(
                                _emailController.text,
                                _passwordController.text,
                              ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Register'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _apiStatus == 'up' ? Icons.circle : Icons.circle_outlined,
              size: 8,
              color: _apiStatus == 'up' ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              'API: ${_apiStatus == 'up' ? 'up' : 'down'}',
              style: TextStyle(
                fontSize: 12,
                color: _apiStatus == 'up' ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
