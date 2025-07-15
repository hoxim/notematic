import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/services/token_service.dart';
import 'src/services/logger_service.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/create_note_screen.dart';
import 'src/config/app_config.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  final logger = LoggerService();
  logger.init();
  logger.info('Starting Notematic Flutter app');
  AppConfig.logConfiguration();

  logger.info('About to run app');
  runApp(const MyApp());
  logger.info('App started');
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
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) =>
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
        : const LoginScreen();
  }
}
