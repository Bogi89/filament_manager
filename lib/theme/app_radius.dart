import 'package:flutter/widgets.dart';

class AppRadius {

  // =========================
  // Radius Werte
  // =========================

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  // =========================
  // BorderRadius Helpers
  // =========================

  static const BorderRadius radiusXS =
      BorderRadius.all(
        Radius.circular(xs),
      );

  static const BorderRadius radiusSM =
      BorderRadius.all(
        Radius.circular(sm),
      );

  static const BorderRadius radiusMD =
      BorderRadius.all(
        Radius.circular(md),
      );

  static const BorderRadius radiusLG =
      BorderRadius.all(
        Radius.circular(lg),
      );

  static const BorderRadius radiusXL =
      BorderRadius.all(
        Radius.circular(xl),
      );

}