import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:homemed/screens/auth/register.dart';
import 'package:homemed/screens/welcome.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: ((context, state) => Welcome())),
    GoRoute(path: '/register', builder: ((_, _) => Register())),
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
      ),
    );
  }
}
