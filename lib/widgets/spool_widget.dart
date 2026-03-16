import 'package:flutter/material.dart';

class SpoolWidget extends StatelessWidget {
  final Color color;
  final String material;
  final double size;

  const SpoolWidget({
    super.key,
    required this.color,
    required this.material,
    this.size = 56,
  });

  String _materialImage(String material) {
    switch (material.toUpperCase()) {
      case "PLA":
        return "assets/images/spool_pla.png";
      case "PETG":
        return "assets/images/spool_petg.png";
      case "ABS":
        return "assets/images/spool_abs.png";
      case "ASA":
        return "assets/images/spool_asa.png";
      case "PC":
        return "assets/images/spool_pc.png";
      case "PA":
        return "assets/images/spool_pa.png";
      case "PEI":
        return "assets/images/spool_pei.png";
      case "PP":
        return "assets/images/spool_pp.png";
      case "TPU":
        return "assets/images/spool_tpu.png";
      case "HIPS":
        return "assets/images/spool_hips.png";
      case "CARBON":
        return "assets/images/spool_carbon.png";
      case "WOOD":
        return "assets/images/spool_wood.png";
      default:
        return "assets/images/spool_pla.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [

          /// Spool Base
          Image.asset(
            "assets/images/spool_base.png",
            fit: BoxFit.contain,
          ),

          /// Filament Color Layer
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [color, color],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Image.asset(
              "assets/images/filament_mask.png",
              fit: BoxFit.contain,
            ),
          ),

          /// Filament Shading
          Image.asset(
            "assets/images/filament_shading.png",
            fit: BoxFit.contain,
          ),

          /// Material Overlay (PLA / PETG / etc)
          Image.asset(
            _materialImage(material),
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}