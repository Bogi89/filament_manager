import 'package:flutter/material.dart';

class LegalInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const LegalInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 500;

        return Card(
          elevation: 0,
          color: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.all(
              isCompact ? 16 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        softWrap: true,
                        style: (
                          isCompact
                              ? theme.textTheme.titleMedium
                              : theme.textTheme.titleLarge
                        )?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: isCompact ? 18 : 24,
                ),

                child,
              ],
            ),
          ),
        );
      },
    );
  }
}