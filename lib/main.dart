import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:homemed/screens/auth/complete_profile.dart';
import 'package:homemed/screens/auth/register.dart';
import 'package:homemed/screens/auth/verify.dart';
import 'package:homemed/screens/patient.dart';
import 'package:homemed/screens/request_form.dart';
import 'package:homemed/screens/welcome.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await dotenv.load(fileName: '.env.local');
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_KEY'];

  await Supabase.initialize(url: supabaseUrl!, publishableKey: supabaseKey!);

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;
final storage = GetStorage();

// Helper to turn a Stream into a ChangeNotifier for GoRouter's refreshListenable
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  // refresh when auth state changes
  refreshListenable: GoRouterRefreshStream(
    supabase.auth.onAuthStateChange.map((e) => e.session),
  ),
  redirect: (context, state) async {
    final user = supabase.auth.currentUser;
    final loggedIn = user != null;
    final goingToComplete = state.matchedLocation == '/complete-profile';
    final goingToAuthPages =
        state.matchedLocation == '/' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/verify';

    final role = storage.read('role');

    // If not logged in and trying to access complete-profile, send to register
    if (!loggedIn && goingToComplete) return '/register';

    // If logged in and on auth pages, send to complete-profile
    if (loggedIn) {
      try {
        final res = await supabase
            .from('profiles')
            .select(
              'name, phone, role, dob, gender, specialty, license, xp_years',
            )
            .eq('id', user.id)
            .maybeSingle();
        final hasProfile = res != null && res['role'] != null;

        // If logged in and on auth pages, send to home or complete-profile depending on profile
        if (goingToAuthPages) {
          return hasProfile ? '/home' : '/complete-profile';
        }

        // If logged in and trying to access complete-profile but profile exists, send to home
        if (goingToComplete && hasProfile) return '/home';

        if (res != null) {
          final role = res['role'];
          storage.write('role', role);
          storage.write('name', res['name']);
          storage.write('phone', res['phone']);

          if (role == 'doctor') {
            storage.write('specialty', res['specialty']);
            storage.write('license', res['license']);
            storage.write('xp_years', res['xp_years']);
          } else if (role == 'patient') {
            storage.write('dob', res['dob']);
            storage.write('gender', res['gender']);
          }
        }
      } catch (e) {
        // On error, fall back to complete-profile when on auth pages
        if (goingToAuthPages) return '/complete-profile';
      }
    }

    if (state.matchedLocation == '/home') {
      if (role == 'patient') return '/patient';
      if (role == 'doctor') return '/doctor';
    }

    // No-op
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const Welcome()),
    GoRoute(path: '/register', builder: (_, _) => const Register()),
    GoRoute(path: '/verify', builder: (_, _) => const Verify()),
    GoRoute(
      path: '/complete-profile',
      builder: (_, _) => const CompleteProfile(),
    ),
    GoRoute(path: '/home', builder: (_, _) => const SizedBox.shrink()),
    GoRoute(path: '/request-form', builder: (_, _) => const RequestForm()),

    patientTabRoute,
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
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
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
