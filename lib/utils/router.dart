import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../views/auth/login_view.dart';
import '../views/project/project_list_view.dart';
import '../views/project/project_add_view.dart';
import '../views/project/project_detail_view.dart';

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<User?> stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: _GoRouterRefreshStream(authService.authStateStream),
    redirect: (context, state) {
      final isLoggedIn = authService.currentUser != null;
      final isOnLoginPage = state.matchedLocation == '/login';

      if (!isLoggedIn && !isOnLoginPage) {
        return '/login';
      }

      if (isLoggedIn && isOnLoginPage) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      GoRoute(path: '/', builder: (context, state) => const ProjectListView()),
      GoRoute(
        path: '/add',
        builder: (context, state) => const ProjectAddView(),
      ),
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) =>
            ProjectDetailView(projectId: state.pathParameters['id']!),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
