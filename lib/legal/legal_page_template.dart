import 'package:flutter/material.dart';

class LegalPageTemplate extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final Widget child;
  final IconData? icon;
  final String? description;

  const LegalPageTemplate({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.child,
    this.icon,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFFE9EEF5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Card(
                elevation: 0,
                color: theme.cardColor,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          if (icon != null)
                            Icon(
                              icon,
                              size: 56,
                              color: theme.colorScheme.primary,
                            ),

                          if (icon != null) const SizedBox(height: 16),

                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          if (description != null) ...[
                            const SizedBox(height: 12),

                            Text(
                              description!,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.75,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Letzte Aktualisierung: $lastUpdated',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const SizedBox(height: 32),

                      const Divider(),

                      const SizedBox(height: 32),

                      child,

                      const SizedBox(height: 40),

                      const Divider(),

                      const SizedBox(height: 16),

                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Filament Manager',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Version 1.0.0',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '© 2026 Robin\nAlle Rechte vorbehalten.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
