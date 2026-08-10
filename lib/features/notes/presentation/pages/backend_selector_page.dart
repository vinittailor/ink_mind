import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ink_mind/core/di/injection_container.dart';
import 'package:ink_mind/core/theme/app_colors.dart';
import 'package:ink_mind/core/theme/app_text_styles.dart';

/// Screen allowing runtime selection between SQLite and ObjectBox storage backends.
class BackendSelectorPage extends StatelessWidget {
  const BackendSelectorPage({super.key});

  void _onSelectBackend(BuildContext context, StorageBackend backend) {
    selectNotesBackend(backend);
    context.goNamed('home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.storage_rounded,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'InkMind Vector Backend',
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose a storage backend to power RAG retrieval & indexing:',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _BackendCard(
                title: 'Simple DB (SQLite)',
                subtitle: 'Stores chunk text & JSON vectors locally. Computes cosine similarity in Dart.',
                icon: Icons.table_chart_outlined,
                accentColor: AppColors.primary,
                onTap: () => _onSelectBackend(context, StorageBackend.sqlite),
              ),
              const SizedBox(height: 20),
              _BackendCard(
                title: 'Vector DB (ObjectBox + HNSW)',
                subtitle: 'High-performance vector database. Uses native HNSW index for nearest-neighbor search.',
                icon: Icons.hub_outlined,
                accentColor: AppColors.secondary,
                onTap: () => _onSelectBackend(context, StorageBackend.objectbox),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackendCard extends StatelessWidget {
  const _BackendCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.onSurfaceMuted,
            ),
          ],
        ),
      ),
    );
  }
}
