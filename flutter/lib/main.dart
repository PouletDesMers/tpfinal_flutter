import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/product_screen.dart';
import 'screens/register_screen.dart';
import 'services/auth_provider.dart';
import 'services/favorites_provider.dart';

void main() {
  runApp(const MainApp());
}

// Point d'entrée de l'application — enveloppe toute l'app avec ChangeNotifierProvider
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'TP Final Flutter',
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/products': (context) => const ProductScreen(),
        },
      ),
    );
  }
}

// Écran d'accueil qui vérifie la session au démarrage
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Charge la session ET les favoris en parallèle
    await Future.wait([
      context.read<AuthProvider>().tryAutoLogin(),
      context.read<FavoritesProvider>().load(),
    ]);
    if (!mounted) return;

    if (context.read<AuthProvider>().isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/products');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
