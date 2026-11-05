import 'package:flutter/material.dart';

/// Limits the width of a page on large screens while preserving the
/// available width on phones and narrow desktop windows.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 1400,
  }) : assert(maxWidth > 0);

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox.expand(child: child),
      ),
    );
  }
}
