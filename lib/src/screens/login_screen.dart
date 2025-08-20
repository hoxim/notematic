import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../providers/user_provider.dart';
import '../providers/token_provider.dart';
import '../providers/pending_oauth_provider.dart';
import '../services/api_service.dart';
import '../services/google_auth_service.dart';
import '../services/token_service.dart';
import '../providers/logger_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart'
    as gpi;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  late final ApiService _apiService;
  late final TokenService _tokenService;
  late final GoogleAuthService _googleAuthService;

  // API status
  bool _isCheckingApi = false;
  String _apiStatus = 'unknown';
  bool _autoLogin = false;

  StreamSubscription<gpi.AuthenticationEvent>? _authSub;

  @override
  void initState() {
    super.initState();
    _apiService = ref.read(apiServiceProvider);
    _googleAuthService = ref.read(googleAuthServiceProvider);
    _tokenService = ref.read(tokenServiceProvider);
    // Initialize Google Auth
    _googleAuthService.initialize();
    _checkApiStatus();
    _loadAutoLogin();
    // Subscribe to web auth events
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
    final loginResponse =
        await _apiService.login(email: email, password: password);
    if (loginResponse != null) {
      await _tokenService.saveUserEmail(email);
      // Set user email in provider
      ref.read(userProvider.notifier).setUser(email);

      // If there is a pending OAuth link request (e.g., from Google 409), link it now
      final pending = ref.read(pendingOAuthLinkProvider);
      if (pending != null && pending.email == email) {
        final logger = ref.read(loggerServiceProvider);
        logger.info('Attempting to link ${pending.provider} to $email');
        final linked = await _apiService.linkOAuthProvider(
          email: pending.email,
          provider: pending.provider,
          oauthToken: pending.oauthToken,
          oauthData: pending.oauthData,
        );
        if (linked) {
          logger.info('Successfully linked ${pending.provider} to $email');
          ref.read(pendingOAuthLinkProvider.notifier).state = null;
        } else {
          logger.warning('Failed to link ${pending.provider} to $email');
        }
      }
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

  /// Handle Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    final logger = ref.read(loggerServiceProvider);
    logger.info('🔐 LoginScreen: Starting Google Sign-In');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final account = await _googleAuthService.authenticateAndGetAccount();

      if (account != null) {
        logger.info('📧 Calling API for email: ${account.email}');
        final payload = {
          'provider': 'google',
          'provider_id': account.id,
          'name': account.displayName,
          'picture': account.photoUrl,
          'email_verified': true,
        };

        try {
          final loginResponse = await _apiService.loginWithOAuth(
            email: account.email,
            oauthToken: 'google_token_placeholder',
            provider: 'google',
            oauthData: payload,
          );

          if (loginResponse != null) {
            logger.info('🎉 API login successful');
            await _tokenService.saveUserEmail(account.email);
            ref.read(userProvider.notifier).setUser(account.email);
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          } else {
            logger.warning('❌ API login failed');
            setState(() {
              _errorMessage = 'Google login failed. Please try again.';
            });
          }
        } on OAuthConflictException {
          // Save pending link data and prompt password login
          ref.read(pendingOAuthLinkProvider.notifier).state =
              PendingOAuthLinkData(
            email: account.email,
            provider: 'google',
            oauthToken: 'google_token_placeholder',
            oauthData: payload,
          );
          logger.warning(
              'Account exists with local authentication. Ask user to login with password to link.');
          setState(() {
            _errorMessage =
                'This email is already registered with password. Sign in with your password to link Google.';
          });
        }
      } else {
        logger.info('ℹ️ Google Sign-In cancelled by user');
      }
    } catch (e) {
      logger.error('💥 Google Sign-In error: $e');
      setState(() {
        _errorMessage = 'Google Sign-In failed. Please try again.';
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
                      const SizedBox(height: 24),
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Google Sign-In button
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
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        // Web Google Sign-In not fully implemented yet
                                        setState(() {
                                          _errorMessage =
                                              'Web Google Sign-In not fully implemented yet. Use Android/Desktop for now.';
                                        });
                                      },
                                icon: Image.asset(
                                  'assets/google_logo.png',
                                  height: 20,
                                  width: 20,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.g_mobiledata, size: 20);
                                  },
                                ),
                                label: const Text('Continue with Google (Web)'),
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
                            onPressed: _isLoading ? null : _handleGoogleSignIn,
                            icon: Image.asset(
                              'assets/google_logo.png',
                              height: 20,
                              width: 20,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.g_mobiledata, size: 20);
                              },
                            ),
                            label: const Text('Continue with Google'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
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
