import 'package:flutter/material.dart';
import 'package:ink_mind/core/di/injection_container.dart';
import 'package:ink_mind/core/routes/app_router.dart';
import 'package:ink_mind/core/theme/app_theme.dart';

Future<void> main() async {
  // Ensure Flutter engine is initialized before any async work.
  WidgetsFlutterBinding.ensureInitialized();

  // Bootstrap the get_it service locator.
  // All features register their dependencies here before the UI starts.
  await initDependencies();

  runApp(const InkMindApp());
}

class InkMindApp extends StatelessWidget {
  const InkMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'InkMind',
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────────────────
      theme: AppTheme.dark,

      // ── Routing ────────────────────────────────────────────────────────────
      routerConfig: AppRouter.router,
    );
  }
}
