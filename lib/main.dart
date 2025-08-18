import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/providers/logger_provider.dart';
import 'src/services/api_service.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/create_note_screen.dart';
import 'src/config/app_config.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/register_screen.dart';
import 'src/screens/settings_screen.dart';
import 'src/screens/profile_screen.dart';
import 'src/services/unified_storage_service.dart';
import 'src/providers/user_provider.dart';
import 'src/themes/app_theme_dark.dart';
import 'src/themes/app_theme_light.dart';
import 'src/providers/theme_provider.dart';

// ObjectBox will be initialized when needed by the services

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize logger through provider
  final container = ProviderContainer();
  final logger = container.read(loggerServiceProvider);
  logger.init();
  logger.info('Starting Notematic Flutter app');
  AppConfig.logConfiguration(logger);

  logger.info('Initializing platform services');
  await UnifiedStorageService().initialize();

  logger.info('About to run app');
  runApp(const ProviderScope(child: MyApp()));
  logger.info('App started');
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeProvider);
    final themeMode = themeModeAsync.value ?? ThemeMode.system;
    return MaterialApp(
      title: 'Notematic',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: themeMode,
      home: AuthWrapper(onToggleTheme: () {}, themeMode: themeMode),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/create-note': (context) => const CreateNoteScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
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
