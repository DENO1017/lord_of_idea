import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lord_of_idea/features/home/presentation/home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      if (state.matchedLocation == '/') return '/home';
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
      ),
    ],
  );
});
