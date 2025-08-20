import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../services/api_service.dart';
import '../services/google_auth_service.dart';
import '../providers/logger_provider.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart'
    as gpi;

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  late final ApiService _apiService;
  late final GoogleAuthService _googleAuthService;

  // API status (placeholder)
  String _apiStatus = 'up';
  bool _isCheckingApi = false;
  StreamSubscription<gpi.AuthenticationEvent>? _authSub;

  @override
  void initState() {
    super.initState();
    _apiService = ref.read(apiServiceProvider);
    _googleAuthService = ref.read(googleAuthServiceProvider);
    // Google Auth initialization is now handled by FutureBuilder for web
    // and by _handleGoogleRegister for native platforms
    _checkApiStatus();

    if (AppConfig.isWebPlatform) {
      _authSub = gpi.GoogleSignInPlatform.instance.authenticationEvents
          ?.listen((event) async {
        final logger = ref.read(loggerServiceProvider);
        try {
          // For web, we get a credential (JWT) from Google Identity Services
          // The event structure depends on the GIS flow, but we can access credential
          final credential = event.toString(); // Temporary workaround
          logger.info('Web Google Sign-In event received: $credential');

          // For now, we'll use a placeholder approach
          // In a real implementation, you'd extract the JWT from the event
          // and send it to your backend for verification
          logger.info('Web Google Sign-In - JWT would be sent to backend');

          // Placeholder: simulate successful login
          setState(() {
            _errorMessage =
                'Web Google Sign-In not fully implemented yet. Use Android/Desktop for now.';
          });
        } catch (e) {
          logger.error('Web Google auth event error: $e');
          setState(() {
            _errorMessage = 'Google Sign-In error: $e';
          });
        }
      });
    }
  }

  Future<void> _checkApiStatus() async {
    if (_isCheckingApi) return;

    setState(() {
      _isCheckingApi = true;
    });

    try {
      setState(() {
        _apiStatus = 'up';
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

  Future<void> _handleGoogleRegister() async {
    final logger = ref.read(loggerServiceProvider);
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final account = await _googleAuthService.authenticateAndGetAccount();
      if (account == null) return;
      final loginResponse = await _apiService.loginWithOAuth(
        email: account.email,
        oauthToken: 'google_token_placeholder',
        provider: 'google',
        oauthData: {
          'provider': 'google',
          'provider_id': account.id,
          'name': account.displayName,
          'picture': account.photoUrl,
          'email_verified': true,
        },
      );
      if (loginResponse != null && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      logger.error('Google registration error: $e');
      setState(() {
        _errorMessage = 'Google registration failed. Try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
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
                  'Sign up',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(
                                  () => _passwordVisible = !_passwordVisible);
                            },
                          ),
                        ),
                        obscureText: !_passwordVisible,
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
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error,
                                  color: Colors.red, size: 20),
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
                      const SizedBox(height: 16),
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
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Sign up'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('or'),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (AppConfig.isWebPlatform)
                        FutureBuilder(
                          future: _googleAuthService.initialize(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: null,
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return const SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: null,
                                  child: Text('Google Sign-In Error'),
                                ),
                              );
                            }
                            return SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed:
                                    _isLoading ? null : _handleGoogleRegister,
                                icon: const Icon(Icons.g_mobiledata),
                                label: const Text('Sign up with Google'),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            );
                          },
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed:
                                _isLoading ? null : _handleGoogleRegister,
                            icon: const Icon(Icons.g_mobiledata),
                            label: const Text('Sign up with Google'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/login'),
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
