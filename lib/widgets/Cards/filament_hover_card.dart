import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class FilamentHoverCard extends StatefulWidget {

  final Widget child;

  const FilamentHoverCard({
    super.key,
    required this.child,
  });

  @override
  State<FilamentHoverCard> createState() =>
      _FilamentHoverCardState();
}

class _FilamentHoverCardState
    extends State<FilamentHoverCard> {

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

        duration: const Duration(
          milliseconds: 120,
        ),

        curve: Curves.easeOut,

        child: widget.child,

      ),

    );
  }
}