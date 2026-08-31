import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:homemed/features/auth/complete_profile.dart';
import 'package:homemed/features/auth/login.dart';
import 'package:homemed/features/auth/register.dart';
import 'package:homemed/features/auth/verify.dart';
import 'package:homemed/features/patient/help_support.dart';
import 'package:homemed/features/patient/tab_route.dart';
import 'package:homemed/features/patient/widgets/request_form.dart';
import 'package:homemed/features/welcome.dart';
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
    final location = state.matchedLocation;
    final goingToAuthPages =
        location == '/' ||
        location == '/login' ||
        location == '/register' ||
        location == '/verify';
    final goingToComplete = location == '/complete-profile';

    if (!loggedIn) {
      if (goingToComplete) return '/register';
      if (location == '/' && storage.read('not-first') == true) return '/login';
      return null;
    }

    // --- USER IS LOGGED IN ---
    String? role = storage.read('role');

    // If role is not cached in storage, fetch once from Supabase (with timeout)
    if (role == null) {
      try {
        final res = await supabase
            .from('profiles')
            .select(
              'name, phone, role, dob, gender, specialty, license, xp_years',
            )
            .eq('id', user.id)
            .maybeSingle()
            .timeout(const Duration(seconds: 3));

        if (res != null && res['role'] != null) {
          role = res['role'] as String;
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
      } catch (_) {
        // Ignore network error/timeout when offline
      }
    }

    // If profile is incomplete, send to complete-profile
    if (role == null) {
      return goingToComplete ? null : '/complete-profile';
    }

    // User has a role: redirect away from auth/complete/home to their dashboard
    final dashboard = (role == 'doctor') ? '/doctor' : '/patient';

    if (goingToAuthPages || goingToComplete || location == '/home') {
      return dashboard;
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const Welcome()),
    GoRoute(path: '/register', builder: (_, _) => const Register()),
    GoRoute(path: '/login', builder: (_, _) => const Login()),
    GoRoute(path: '/verify', builder: (_, _) => const Verify()),
    GoRoute(
      path: '/complete-profile',
      builder: (_, _) => const CompleteProfile(),
    ),
    GoRoute(path: '/home', builder: (_, _) => const SizedBox.shrink()),
    GoRoute(path: '/request-form', builder: (_, _) => const RequestForm()),
    GoRoute(path: '/help', builder: (_, _) => const PatientHelpSupport()),

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
