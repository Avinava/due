import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/month/month_screen.dart';
import 'settings_route.dart';

/// Two places: the month, and settings over it. The add/edit sheet is a
/// modal, not a route.
GoRouter buildRouter({String initialLocation = '/', GlobalKey<NavigatorState>? navigatorKey}) => GoRouter(
  initialLocation: initialLocation,
  navigatorKey: navigatorKey,
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const NoTransitionPage(child: Scaffold(body: MonthScreen())),
      routes: [
        GoRoute(
          path: MonthScreen.settingsPath.substring(1),
          builder: (context, state) => const Scaffold(body: SettingsRoute()),
        ),
      ],
    ),
  ],
);
