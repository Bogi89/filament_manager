import 'package:flutter/material.dart';
import '../models/filament.dart';

class FilamentSpoolIcon extends StatelessWidget {

  final Filament filament;

  const FilamentSpoolIcon({
    super.key,
    required this.filament,
  });

  String _getSpoolImage() {

    final material =
        filament.material.toLowerCase();

    /// PLA
    if (material.contains("pla")) {
      return "assets/images/spool_pla.png";
    }

    /// PETG
    if (material.contains("petg")) {
      return "assets/images/spool_petg.png";
    }

    /// ABS
    if (material.contains("abs")) {
      return "assets/images/spool_abs.png";
    }

    /// ASA
    if (material.contains("asa")) {
      return "assets/images/spool_asa.png";
    }

    /// TPU
    if (material.contains("tpu")) {
      return "assets/images/spool_tpu.png";
    }

    /// HIPS
    if (material.contains("hips")) {
      return "assets/images/spool_hips.png";
    }

    /// CARBON
    if (material.contains("carbon")) {
      return "assets/images/spool_carbon.png";
    }

    /// PC ⭐ NEU
    if (material.contains("pc")) {
      return "assets/images/spool_pc.png";
    }

    /// PA (Nylon)
    if (material.contains("pa")) {
      return "assets/images/spool_pa.png";
    }

    /// PP
    if (material.contains("pp")) {
      return "assets/images/spool_pp.png";
    }

    /// PCTG
    if (material.contains("pctg")) {
      return "assets/images/spool_pctg.png";
    }

    /// PEI
    if (material.contains("pei")) {
      return "assets/images/spool_pei.png";
    }

    /// WOOD
    if (material.contains("wood")) {
      return "assets/images/spool_wood.png";
    }

    /// Fallback
    return "assets/images/spool_base.png";
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: 52,
      height: 52,
      child: Image.asset(
        _getSpoolImage(),
        fit: BoxFit.contain,

        /// ⭐ wichtig bei Fehlern sichtbar
        errorBuilder:
            (context, error, stackTrace) {

          return Image.asset(
            "assets/images/spool_base.png",
            fit: BoxFit.contain,
          );

        },
      ),
    );
  }
}