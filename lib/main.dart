import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:medibot/data/data_sources/remote/chat_api_service.dart';
import 'package:medibot/data/data_sources/remote/profile_api_service.dart';
import 'package:medibot/data/repositories/chat_repository.dart';
import 'package:medibot/data/repositories/profile_repository.dart';
import 'package:medibot/presentation/navigation/auth_router.dart';
import 'package:medibot/presentation/navigation/navigation_service.dart';
import 'package:medibot/presentation/providers/auth/auth_provider.dart';
import 'package:medibot/presentation/providers/chat/chat_provider.dart';
import 'package:medibot/presentation/providers/profile/profile_provider.dart';
import 'package:medibot/presentation/theme/dark_theme.dart';
import 'package:medibot/presentation/theme/light_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Services
import 'services/google_sign_in_service.dart';
import 'services/connectivity_service.dart';

// Data Sources
import 'data/data_sources/local/secure_storage_service.dart';
import 'data/data_sources/local/onboarding_storage.dart';
import 'data/data_sources/remote/api_client.dart';
import 'data/data_sources/remote/auth_api_service.dart';

// Repositories
import 'data/repositories/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services
  final secureStorage = SecureStorageService();
  final sharedPreferences = await SharedPreferences.getInstance();
  final onboardingStorage = OnboardingStorage(sharedPreferences);
  final connectivityService = ConnectivityService();

  final apiClient = ApiClient(
    baseUrl: dotenv.env['BACKEND_URL'] ?? 'https://your-backend-url.com',
    storage: secureStorage,
  );

  final authApiService = AuthApiService(apiClient);
  final chatApiService = ChatApiService(apiClient);
  final profileApiService = ProfileApiService(apiClient);
  final googleSignInService = GoogleSignInService();

  final authRepository = AuthRepository(
    apiService: authApiService,
    storage: secureStorage,
    googleSignIn: googleSignInService,
    apiClient: apiClient,
  );

  final chatRepository = ChatRepository(chatApiService: chatApiService);

  final profileRepository = ProfileRepository(
    profileApiService: profileApiService,
  );

  runApp(
    MyApp(
      authRepository: authRepository,
      chatRepository: chatRepository,
      profileRepository: profileRepository,
      secureStorage: secureStorage,
      connectivityService: connectivityService,
      onboardingStorage: onboardingStorage,
    ),
  );
}

class MyApp extends StatefulWidget {
  final AuthRepository authRepository;
  final ChatRepository chatRepository;
  final ProfileRepository profileRepository;
  final SecureStorageService secureStorage;
  final ConnectivityService connectivityService;
  final OnboardingStorage onboardingStorage;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.chatRepository,
    required this.profileRepository,
    required this.secureStorage,
    required this.connectivityService,
    required this.onboardingStorage,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Brightness? _previousBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final newBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    if (_previousBrightness != null && _previousBrightness != newBrightness) {
      // Close any open popups/dialogs when theme changes
      final navigator = NavigationService.navigatorKey.currentState;
      if (navigator != null && navigator.canPop()) {
        navigator.pop();
      }
    }
    _previousBrightness = newBrightness;
    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: widget.authRepository),
        ),
        ChangeNotifierProvider(create: (_) => ChatProvider(widget.chatRepository)),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(widget.profileRepository),
        ),
        Provider<ConnectivityService>.value(value: widget.connectivityService),
        Provider<OnboardingStorage>.value(value: widget.onboardingStorage),
        Provider<AuthRepository>.value(value: widget.authRepository),
        Provider<ChatRepository>.value(value: widget.chatRepository),
        Provider<ProfileRepository>.value(value: widget.profileRepository),
      ],
      child: MaterialApp(
        title: 'MediBot',
        debugShowCheckedModeBanner: false,
        theme: getLightTheme(),
        darkTheme: getDarkTheme(),
        themeMode: ThemeMode.system,
        navigatorKey: NavigationService.navigatorKey,
        onGenerateRoute: AppRouter.generateRoute,
        home: const InitialScreen(),
      ),
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final onboardingStorage = context.read<OnboardingStorage>();

    final hasSeenOnboarding = await onboardingStorage.isOnboardingComplete();

    if (!hasSeenOnboarding) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
      return;
    }

    final isLoggedIn = await authProvider.checkAuthStatus();
    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.chat);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
