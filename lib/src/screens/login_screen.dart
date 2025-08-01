import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../providers/token_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  late final ApiService _apiService;
  late final TokenService _tokenService;

  // API status
  String _apiStatus = 'checking';
  bool _isCheckingApi = false;
  bool _autoLogin = false;

  @override
  void initState() {
    super.initState();
    _apiService = ref.read(apiServiceProvider);
    _tokenService = ref.read(tokenServiceProvider);
    _checkApiStatus();
    _loadAutoLogin();
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

  Future<void> _loadAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final autoLogin = prefs.getBool('autoLogin') ?? false;
    setState(() {
      _autoLogin = autoLogin;
    });
    if (autoLogin) {
      // Try auto-login if tokens are present
      final isLoggedIn = await _tokenService.isLoggedIn();
      if (isLoggedIn && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  Future<void> _setAutoLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoLogin', value);
    setState(() {
      _autoLogin = value;
    });
  }

  Future<void> login(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final success = await _apiService.login(email: email, password: password);
    if (success) {
      await _tokenService.saveUserEmail(email);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      setState(() {
        _errorMessage = 'Login failed. Check your credentials.';
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
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Sign in',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Enter email'
                            : null,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).nextFocus();
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter password' : null,
                        onFieldSubmitted: (_) => login(
                          _emailController.text,
                          _passwordController.text,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _autoLogin,
                            onChanged: (val) {
                              if (val != null) _setAutoLogin(val);
                            },
                          ),
                          const Text('Log in automatically'),
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => login(
                                    _emailController.text,
                                    _passwordController.text,
                                  ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Sign in'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/register');
                      },
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
