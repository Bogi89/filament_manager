import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      ),
      backgroundColor: theme.brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFFE9EEF5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 600;

            return SingleChildScrollView(
              padding: EdgeInsets.all(
                isCompact ? 12 : 24,
              ),
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
                      padding: EdgeInsets.all(
                        isCompact ? 16 : 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            children: [
                              if (icon != null)
                                Icon(
                                  icon,
                                  size: isCompact ? 44 : 56,
                                  color: theme.colorScheme.primary,
                                ),

                              if (icon != null)
                                SizedBox(
                                  height: isCompact ? 12 : 16,
                                ),

                              Text(
                                title,
                                textAlign: TextAlign.center,
                                softWrap: true,
                                style: (
                                  isCompact
                                      ? theme.textTheme.titleLarge
                                      : theme.textTheme.headlineMedium
                                )?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              if (description != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  description!,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.75),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            '${localizations.legalLastUpdated}: $lastUpdated',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),

                          SizedBox(
                            height: isCompact ? 20 : 24,
                          ),

                          SizedBox(
                            height: isCompact ? 20 : 32,
                          ),

                          const Divider(),

                          SizedBox(
                            height: isCompact ? 20 : 32,
                          ),

                          child,

                          SizedBox(
                            height: isCompact ? 28 : 40,
                          ),

                          const Divider(),

                          const SizedBox(height: 16),

                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'FilaLog',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Version 1.0.0',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '© 2026 Robin\n'
                                  '${localizations.legalAllRightsReserved}',
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
            );
          },
        ),
      ),
    );
  }
}