import 'package:flutter/material.dart';

class AppHoverCard extends StatefulWidget {
  final Widget child;

  const AppHoverCard({super.key, required this.child});

  @override
  State<AppHoverCard> createState() => _AppHoverCardState();
}

class _AppHoverCardState extends State<AppHoverCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },

      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },

      child: AnimatedScale(
        scale: hovering ? 1.01 : 1.0,

        duration: const Duration(milliseconds: 120),

        curve: Curves.easeOut,

        child: widget.child,
      ),
    );
  }
}
