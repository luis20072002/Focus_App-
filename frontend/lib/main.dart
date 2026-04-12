import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/tasks/create_task_screen.dart';
import 'screens/tasks/task_detail_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();

    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final status = authProvider.status;
        if (status == AuthStatus.checking) return null;
        final isAuth = status == AuthStatus.authenticated;
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';
        if (!isAuth && !isAuthRoute) return '/login';
        if (isAuth && isAuthRoute) return '/home';
        if (isAuth && state.matchedLocation == '/') return '/home';
        return null;
      },
      routes: [
        GoRoute(path: '/',         builder: (_, _) => const SplashScreen()),
        GoRoute(path: '/login',    builder: (_, _) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
        GoRoute(path: '/home',     builder: (_, _) => const HomeScreen()),
        GoRoute(path: '/create-task', builder: (_, _) => const CreateTaskScreen()),
        GoRoute(
          path: '/task/:id',
          builder: (_, state) => TaskDetailScreen(
            taskId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Focus App',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.fondo,
        colorScheme: const ColorScheme.dark(
          primary:   AppColors.naranja,
          secondary: AppColors.amarillo,
          surface:   AppColors.tarjeta,
          error:     AppColors.error,
        ),
        fontFamily: 'sans-serif',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.tarjeta,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.naranja, width: 1.5),
          ),
          labelStyle: const TextStyle(color: AppColors.grisTexto),
          hintStyle:  const TextStyle(color: AppColors.grisTexto),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.naranja,
            foregroundColor: AppColors.blanco,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

// Pantalla de carga mientras se verifica el token
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppColors.naranja),
      ),
    );
  }
}