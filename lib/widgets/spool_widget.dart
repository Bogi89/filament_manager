import 'package:flutter/material.dart';

class SpoolWidget extends StatelessWidget {
  final String material;

  const SpoolWidget({
    super.key,
    required this.material,
  });

  String _getImage() {
    switch (material.toLowerCase()) {
      case "pla":
        return "assets/images/spool_pla.png";
      case "petg":
        return "assets/images/spool_petg.png";
      case "abs":
        return "assets/images/spool_abs.png";
      case "tpu":
        return "assets/images/spool_tpu.png";
      case "asa":
        return "assets/images/spool_asa.png";
      case "pa":
        return "assets/images/spool_pa.png";
      case "pc":
        return "assets/images/spool_pc.png";
      case "pp":
        return "assets/images/spool_pp.png";
      case "hips":
        return "assets/images/spool_hips.png";
      case "wood":
        return "assets/images/spool_wood.png";
      case "carbon":
        return "assets/images/spool_carbon.png";
      default:
        return "assets/images/spool_pla.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _getImage(),
      width: 70,
      height: 70,
    );
  }
}