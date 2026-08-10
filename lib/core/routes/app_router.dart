// go_router configuration for InkMind.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ink_mind/core/di/injection_container.dart';
import 'package:ink_mind/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:ink_mind/features/chat/presentation/pages/chat_page.dart';
import 'package:ink_mind/features/classifier/presentation/cubit/classifier_cubit.dart';
import 'package:ink_mind/features/classifier/presentation/pages/classifier_page.dart';
import 'package:ink_mind/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:ink_mind/features/notes/presentation/pages/backend_selector_page.dart';
import 'package:ink_mind/features/notes/presentation/pages/notes_page.dart';

/// Route name constants — use these instead of raw strings at call sites.
abstract final class AppRoutes {
  static const String selector = '/';
  static const String home = '/chat';
  static const String notes = '/notes';
  static const String classifier = '/classifier';
}

class AppRouter {
  AppRouter._(); // prevent instantiation

  /// The single [GoRouter] instance consumed by [MaterialApp.router].
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.selector,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.selector,
        name: 'selector',
        builder: (BuildContext context, GoRouterState state) {
          return const BackendSelectorPage();
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider(
            create: (_) => sl<ChatCubit>(),
            child: const ChatPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.notes,
        name: 'notes',
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider(
            create: (_) => sl<NotesCubit>(),
            child: const NotesPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.classifier,
        name: 'classifier',
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider(
            create: (_) => sl<ClassifierCubit>(),
            child: const ClassifierPage(),
          );
        },
      ),
    ],
  );
}
