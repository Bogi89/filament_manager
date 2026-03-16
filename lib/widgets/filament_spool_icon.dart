import 'package:flutter/material.dart';
import '../models/filament.dart';

class FilamentSpoolIcon extends StatelessWidget {

final Filament filament;

const FilamentSpoolIcon({
super.key,
required this.filament,
});

String _getSpoolImage() {

final material = filament.material.toLowerCase();

if (material.contains("pla")) {
  return "assets/images/spool_pla.png";
}

if (material.contains("petg")) {
  return "assets/images/spool_petg.png";
}

if (material.contains("abs")) {
  return "assets/images/spool_abs.png";
}

if (material.contains("asa")) {
  return "assets/images/spool_asa.png";
}

if (material.contains("tpu")) {
  return "assets/images/spool_tpu.png";
}

if (material.contains("hips")) {
  return "assets/images/spool_hips.png";
}

if (material.contains("carbon")) {
  return "assets/images/spool_carbon.png";
}

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
  ),
);

}
}