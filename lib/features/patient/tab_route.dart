import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:homemed/features/patient/tabs/history.dart';
import 'package:homemed/features/patient/tabs/home.dart';
import 'package:homemed/features/patient/tabs/profile.dart';

final patientTabRoute = StatefulShellRoute.indexedStack(
  builder: ((_, _, navigationShell) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (idx) => navigationShell.goBranch(idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }),
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(path: '/patient', builder: (_, _) => const PatientHome()),
      ],
    ),

    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/patient/history',
          builder: (_, _) => const PatientHistory(),
        ),
      ],
    ),

    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/patient/profile',
          builder: (_, _) => const PatientProfile(),
        ),
      ],
    ),
  ],
);
