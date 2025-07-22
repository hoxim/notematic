import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/services/logger_service.dart';
import 'src/services/api_service.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/create_note_screen.dart';
import 'src/config/app_config.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/register_screen.dart';
import 'src/services/unified_storage_service.dart';
import 'src/providers/user_provider.dart';

// ObjectBox will be initialized when needed by the services

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  final logger = LoggerService();
  logger.init();
  logger.info('Starting Notematic Flutter app');
  AppConfig.logConfiguration();

  logger.info('Initializing platform services');
  await UnifiedStorageService().initialize();

  logger.info('About to run app');
  runApp(const ProviderScope(child: MyApp()));
  logger.info('App started');
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
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
      navigatorKey: navigatorKey,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.pink,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: MaterialColor(0xFF212121, <int, Color>{
          50: Color(0xFF212121),
          100: Color(0xFF212121),
          200: Color(0xFF212121),
          300: Color(0xFF212121),
          400: Color(0xFF212121),
          500: Color(0xFF212121),
          600: Color(0xFF212121),
          700: Color(0xFF212121),
          800: Color(0xFF212121),
          900: Color(0xFF000000),
        }),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: AuthWrapper(onToggleTheme: _toggleTheme, themeMode: _themeMode),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/create-note': (context) => const CreateNoteScreen(),
      },
    );
  }
}

class AuthWrapper extends ConsumerStatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  const AuthWrapper({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.checkAndSetLoginStatus();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    if (_isLoading) return const CircularProgressIndicator();
    if (isLoggedIn) return const HomeScreen();
    return const LoginScreen();
  }
}
