import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:homemed/screens/auth/register.dart';
import 'package:homemed/screens/auth/verify.dart';
import 'package:homemed/screens/welcome.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env.local');
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_KEY'];

  await Supabase.initialize(url: supabaseUrl!, publishableKey: supabaseKey!);

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const Welcome()),
    GoRoute(path: '/register', builder: (_, _) => const Register()),
    GoRoute(path: '/verify', builder: (_, _) => const Verify()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'HomeMed',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: Size(.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: .circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationThemeData(
          border: OutlineInputBorder(borderRadius: .all(.circular(8))),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: .floating,
          dismissDirection: .horizontal,
        ),
      ),
    );
  }
}
