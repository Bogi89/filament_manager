import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/filament.dart';
import '../../state/app_state.dart';

import '../filament_spool_icon.dart';
import 'filament_hover_card.dart';
import 'filament_progress_bar.dart';
import '../../pages/filament_detail_page.dart';
import 'filament_spool_group_widget.dart';
import '../spool_count_widget.dart';

class FilamentCard extends StatefulWidget {

  final Filament filament;

  const FilamentCard({
    super.key,
    required this.filament,
  });

  @override
  State<FilamentCard> createState() =>
      _FilamentCardState();
}

class _FilamentCardState
    extends State<FilamentCard> {

  Filament? editingFilament;

  final TextEditingController
      weightController =
          TextEditingController();

  void _changeWeight(
      int change,
      Filament filament,
      ) {

    final current =
        double.tryParse(
          weightController.text,
        ) ??
            filament.remainingWeight;

    double newValue =
        current + change;

    if (newValue < 0) {
      newValue = 0;
    }

    if (newValue >
        filament.totalWeight) {
      newValue =
          filament.totalWeight;
    }

    weightController.text =
        newValue.toInt().toString();

    setState(() {});
  }

  String _buildColorNames(
  Filament f,
) {
  print("DEBUG CARD colorNames: ${f.colorNames}");

  // Keine Farben vorhanden
  if (f.colorNames.isEmpty) {
    return "Unknown";
  }

  // Nimm ersten gültigen Namen
  for (final name in f.colorNames) {
    final cleaned = name.trim();

    if (cleaned.isNotEmpty &&
        cleaned.toLowerCase() != "unknown") {
      return cleaned;
    }
  }

  // Falls nur Unknown enthalten
  return "Unknown";
}

  Widget _weightButton(
      String text,
      VoidCallback onPressed,
      ) {

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 2,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final f = widget.filament;

    final appState =
        context.watch<AppState>();

    /// 🧵 Gewicht aus Spools berechnen

final totalWeight =
    f.totalWeight *
        f.spools.length;

final remainingWeight =
    f.spools.fold<double>(
        0,
        (sum, spool) =>
            sum +
            spool.weight);

final percent =
    (remainingWeight /
        totalWeight) *
    100;

    Color percentColor;

    if (percent <=
        appState.warningPercent) {

      percentColor =
          Colors.red;

    } else if (percent <= 50) {

      percentColor =
          Colors.orange;

    } else {

      percentColor =
          Colors.green;
    }

    final isEditing =
        editingFilament == f;

    final isDark =
        Theme.of(context)
                .brightness ==
            Brightness.dark;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),

      child: FilamentHoverCard(

        child: Card(

          color: isDark
              ? null
              : Colors.white,

          elevation:
              isDark ? 0 : 3,

          shadowColor:
              isDark
                  ? Colors.transparent
                  : Colors.black
                      .withOpacity(
                          0.08),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
                    20),
          ),

          child: InkWell(

            borderRadius:
                BorderRadius.circular(
                    20),

            onTap: () {

              if (isEditing) return;

              Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) =>
        FilamentDetailPage(
          filament: f,
        ),
  ),
);

            },

            child: Padding(
              padding:
                  const EdgeInsets.all(
                      16),

              child: Row(
                children: [

                  FilamentSpoolIcon(
                    filament: f,
                  ),

                  const SizedBox(
                      width: 16),

                  /// MAIN TEXT

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Column(
  crossAxisAlignment:
      CrossAxisAlignment.start,

  children: [

    Wrap(
      spacing: 6,
      runSpacing: 6,

      children:
          f.colors
              .take(4)
              .map(
                  (color) {

        return Container(

          width: 12,
          height: 12,

          decoration:
              BoxDecoration(

            color: color ==
                    Colors.white
                ? const Color(
                    0xFFE5E7EB)
                : color,

            shape:
                BoxShape.circle,

            border:
                color ==
                        Colors.white
                    ? Border.all(
                        color:
                            const Color(
                                0xFF9CA3AF),
                        width: 0.5,
                      )
                    : null,
          ),
        );

      }).toList(),
    ),

  ],
),

const SizedBox(width: 8),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Row(
                                    children: [

                                      Text(
                                        f.material,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,

                                        style:
                                            const TextStyle(
                                          fontSize:
                                              17,
                                          fontWeight:
                                              FontWeight
                                                  .w700,
                                        ),
                                      ),

                                      const SizedBox(
                                          width:
                                              8),

                                      Expanded(
  child: Text(
    _buildColorNames(f),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: 13,
      color: Colors.grey.shade400,
    ),
  ),
),

                                    ],
                                  ),

                                  if (f
                                      .variant
                                      .isNotEmpty)

                                    Text(
                                      f.variant,

                                      maxLines: 3,

                                      overflow:
                                          TextOverflow
                                              .ellipsis,

                                      style:
                                          TextStyle(
                                        fontSize:
                                            13,

                                        color: Colors
                                            .grey
                                            .shade400,
                                      ),
                                    ),

                                ],
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(
                            height: 6),

                        if (isEditing)

                          Wrap(
                            spacing: 6,
                            runSpacing: 6,

                            children: [

                              _weightButton(
                                "-10",
                                () {
                                  _changeWeight(
                                      -10,
                                      f);
                                },
                              ),

                              _weightButton(
                                "-",
                                () {
                                  _changeWeight(
                                      -1,
                                      f);
                                },
                              ),

                              SizedBox(
                                width: 80,

                                child:
                                    TextField(

                                  controller:
                                      weightController,

                                  keyboardType:
                                      TextInputType
                                          .number,

                                  textAlign:
                                      TextAlign
                                          .center,

                                  decoration:
                                      const InputDecoration(
                                    isDense:
                                        true,
                                  ),
                                ),
                              ),

                              _weightButton(
                                "+",
                                () {
                                  _changeWeight(
                                      1,
                                      f);
                                },
                              ),

                              _weightButton(
                                "+10",
                                () {
                                  _changeWeight(
                                      10,
                                      f);
                                },
                              ),

                              IconButton(
                                icon:
                                    const Icon(
                                        Icons
                                            .check),

                                color:
                                    Colors.green,

                                onPressed:
                                    () {

                                  final newWeight =
                                      double.tryParse(
                                          weightController
                                              .text);

                                  if (newWeight !=
                                      null) {

                                    f.remainingWeight =
                                        newWeight;

                                    context
                                        .read<
                                            AppState>()
                                        .updateFilament(
                                            f);
                                  }

                                  setState(() {

                                    editingFilament =
                                        null;

                                  });
                                },
                              ),

                            ],
                          )

                        else

                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Row(
  children: [

    Expanded(
      child: Text(
        "${remainingWeight.toInt()} g von ${totalWeight.toInt()} g",
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
        ),
      ),
    ),

    SpoolCountWidget(
      spoolCount: f.spools.length,
      showArrow: false,
    ),

  ],
),

                              const SizedBox(
                                  height: 6),

                              FilamentProgressBar(
                                percent:
                                    percent,
                              ),

                            ],
                          ),

                      ],
                    ),
                  ),

                  const SizedBox(
                      width: 16),

                  /// RIGHT SIDE

                  if (!isEditing)

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .end,

                      children: [

                        Container(

                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),

                          decoration:
                              BoxDecoration(

                            color:
                                percentColor
                                    .withOpacity(
                                        0.12),

                            borderRadius:
                                BorderRadius
                                    .circular(
                                        8),
                          ),

                          child: Row(
                            mainAxisSize:
                                MainAxisSize
                                    .min,

                            children: [

                              Container(

                                width: 8,
                                height: 8,

                                decoration:
                                    BoxDecoration(

                                  color:
                                      percentColor,

                                  shape:
                                      BoxShape
                                          .circle,
                                ),
                              ),

                              const SizedBox(
                                  width: 6),

                              Text(
                                "${percent.round()}%",

                                style:
                                    TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight
                                          .bold,

                                  color:
                                      percentColor,
                                ),
                              ),

                            ],
                          ),
                        ),

                        const SizedBox(
                            height: 2),

                        Row(
                          children: [

                            IconButton(

                              icon:
                                  const Icon(
                                      Icons
                                          .edit,
                                      size:
                                          18),

                              onPressed: () {

                                editingFilament =
                                    f;

                                weightController
                                        .text =
                                    f.remainingWeight
                                        .toInt()
                                        .toString();

                                setState(() {});
                              },
                            ),

                            IconButton(

                              icon:
                                  const Icon(
                                      Icons
                                          .delete,
                                      size:
                                          18,
                                      color:
                                          Colors
                                              .red),

                              onPressed: () {

                                context
                                    .read<
                                        AppState>()
                                    .removeFilament(
                                        f);
                              },
                            ),

                          ],
                        ),

                      ],
                    ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}