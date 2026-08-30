import 'package:flutter/material.dart';

import '../models/filament.dart';
import '../theme/app_spacing.dart';

class FilamentSpoolIcon extends StatelessWidget {
  final Filament filament;
  final double size;
  final double? rightMargin;

  const FilamentSpoolIcon({
    super.key,
    required this.filament,
    this.size = 92,
    this.rightMargin,
  });

  String _getSpoolImage() {
    String material = filament.material.toLowerCase();

    /// RIFD ist PLA
    if (material.contains('rifd')) {
      material = 'pla';
    }

    if (material.contains('pla')) {
      return 'assets/images/spool_pla.png';
    }

    if (material.contains('petg')) {
      return 'assets/images/spool_petg.png';
    }

    if (material.contains('abs')) {
      return 'assets/images/spool_abs.png';
    }

    if (material.contains('asa')) {
      return 'assets/images/spool_asa.png';
    }

    if (material.contains('tpu')) {
      return 'assets/images/spool_tpu.png';
    }

    if (material.contains('hips')) {
      return 'assets/images/spool_hips.png';
    }

    if (material.contains('carbon')) {
      return 'assets/images/spool_carbon.png';
    }

    if (material.contains('pc')) {
      return 'assets/images/spool_pc.png';
    }

    if (material.contains('pa')) {
      return 'assets/images/spool_pa.png';
    }

    if (material.contains('pp')) {
      return 'assets/images/spool_pp.png';
    }

    if (material.contains('pctg')) {
      return 'assets/images/spool_pctg.png';
    }

    if (material.contains('pei')) {
      return 'assets/images/spool_pei.png';
    }

    if (material.contains('wood')) {
      return 'assets/images/spool_wood.png';
    }

    return 'assets/images/spool_base.png';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.only(
        right: rightMargin ?? AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset(
          _getSpoolImage(),
          fit: BoxFit.contain,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return Image.asset(
              'assets/images/spool_base.png',
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }
}