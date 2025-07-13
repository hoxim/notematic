import 'package:flutter/material.dart';
import 'package:notematic/src/services/api_service.dart';
import 'package:notematic/src/services/token_service.dart';
import 'package:notematic/src/services/logger_service.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/create_note_screen.dart';
import 'src/config/app_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'src/rust/frb_generated.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = LoggerService();
  logger.init();
  logger.info('Starting Notematic Flutter app');
  AppConfig.logConfiguration();
  if (!kIsWeb) {
    try {
      await _initializeRust();
      logger.info('Rust initialized successfully');
    } catch (e) {
      logger.error('Failed to initialize Rust: $e');
    }
  } else {
    logger.info('Running on web - skipping Rust initialization');
  }
  logger.info('About to run app');
  runApp(const MyApp());
  logger.info('App started');
}

Future<void> _initializeRust() async {
  if (!kIsWeb) {
    await RustLib.init();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notematic',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: AuthWrapper(onToggleTheme: _toggleTheme, themeMode: _themeMode),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home':
            (context) =>
                HomeScreen(onToggleTheme: _toggleTheme, themeMode: _themeMode),
        '/create-note': (context) => const CreateNoteScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  const AuthWrapper({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  final _logger = LoggerService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _logger.info('Starting auth check...');
    try {
      final isLoggedIn = await TokenService.isLoggedIn();
      _logger.info('Auth check result: $isLoggedIn');

      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
      _logger.info('Auth check completed');
    } catch (e) {
      _logger.error('Failed to check auth status: $e');
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _isLoggedIn
        ? HomeScreen(
          onToggleTheme: widget.onToggleTheme,
          themeMode: widget.themeMode,
        )
        : LoginScreen();
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _getUserFriendlyError(String errorMessage) {
    final message = errorMessage.toLowerCase();

    if (message.contains('user already exists') ||
        message.contains('username already exists')) {
      return 'Username already exists. Please choose a different username.';
    }
    if (message.contains('user not found') ||
        message.contains('invalid credentials')) {
      return 'Invalid username or password. Please try again.';
    }
    if (message.contains('email')) {
      return 'Please enter a valid email address.';
    }
    if (message.contains('password')) {
      return 'Password must be at least 6 characters long.';
    }
    if (message.contains('network') || message.contains('connection')) {
      return 'Connection error. Please check your internet connection.';
    }
    if (message.contains('server') || message.contains('internal')) {
      return 'Server error. Please try again later.';
    }

    return errorMessage;
  }

  Future<void> _submitForm() async {
    final logger = LoggerService();

    if (!_formKey.currentState!.validate()) {
      logger.warning('Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final api = ApiService();
      logger.info('Starting ${_isLogin ? 'login' : 'registration'} process');

      if (_isLogin) {
        // Login
        final response = await api.login(
          username: _usernameController.text,
          password: _passwordController.text,
        );

        // Save tokens and username
        await TokenService.saveTokens(
          accessToken: response['access_token'],
          refreshToken: response['refresh_token'],
          userId: _usernameController.text, // Save actual username
        );

        logger.info('Login successful: ${_usernameController.text}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home screen
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        // Register
        final response = await api.register(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Save tokens and username
        await TokenService.saveTokens(
          accessToken: response['access_token'],
          refreshToken: response['refresh_token'],
          userId: _usernameController.text, // Save actual username
        );

        logger.info('Registration successful: ${_usernameController.text}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Registration successful! Please log in with your credentials.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Switch to login mode after successful registration
        setState(() {
          _isLogin = true;
          _passwordController.clear();
        });
      }
    } catch (e) {
      logger.error('${_isLogin ? 'Login' : 'Registration'} failed: $e');
      final userFriendlyError = _getUserFriendlyError(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFriendlyError), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notematic'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLogin ? 'Login' : 'Register',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (!_isLogin) ...[
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  if (!_isLoading) _submitForm();
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : Text(_isLogin ? 'Login' : 'Register'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin
                      ? 'Don\'t have an account? Register'
                      : 'Already have an account? Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
