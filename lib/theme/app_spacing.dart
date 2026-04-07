import 'package:flutter/widgets.dart';

class AppSpacing {

  // Basis-Abstände
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double massive = 48;

  // =========================
  // EdgeInsets Helpers
  // =========================

  static const EdgeInsets paddingXS =
      EdgeInsets.all(xs);

  static const EdgeInsets paddingSM =
      EdgeInsets.all(sm);

  static const EdgeInsets paddingMD =
      EdgeInsets.all(md);

  static const EdgeInsets paddingLG =
      EdgeInsets.all(lg);

  static const EdgeInsets paddingXL =
      EdgeInsets.all(xl);

  static const EdgeInsets paddingXXL =
      EdgeInsets.all(xxl);

  // Horizontal Padding

  static const EdgeInsets horizontalSM =
      EdgeInsets.symmetric(horizontal: sm);

  static const EdgeInsets horizontalMD =
      EdgeInsets.symmetric(horizontal: md);

  static const EdgeInsets horizontalLG =
      EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets horizontalXL =
      EdgeInsets.symmetric(horizontal: xl);

  // Vertical Padding

  static const EdgeInsets verticalSM =
      EdgeInsets.symmetric(vertical: sm);

  static const EdgeInsets verticalMD =
      EdgeInsets.symmetric(vertical: md);

  static const EdgeInsets verticalLG =
      EdgeInsets.symmetric(vertical: lg);

  static const EdgeInsets verticalXL =
      EdgeInsets.symmetric(vertical: xl);

}