import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/filament.dart';
import '../../pages/filament_detail_page.dart';
import '../../state/app_state.dart';
import '../common/app_hover_card.dart';
import '../filament_spool_icon.dart';
import '../spool_count_widget.dart';
import 'filament_progress_bar.dart';
import '../../utils/color_name_localizer.dart';

class FilamentCard extends StatefulWidget {
  final Filament filament;

  const FilamentCard({
    super.key,
    required this.filament,
  });

  @override
  State<FilamentCard> createState() => _FilamentCardState();
}

class _FilamentCardState extends State<FilamentCard> {
  Filament? editingFilament;

  final TextEditingController weightController =
      TextEditingController();

  void _changeWeight(
    int change,
    Filament filament,
  ) {
    final current =
        double.tryParse(weightController.text) ??
            filament.remainingWeight;

    double newValue = current + change;

    if (newValue < 0) {
      newValue = 0;
    }

    if (newValue > filament.totalWeight) {
      newValue = filament.totalWeight;
    }

    weightController.text =
        newValue.toInt().toString();

    setState(() {});
  }

  String _buildColorNames(
  BuildContext context,
  Filament filament,
) {
  final validNames = filament.colorNames
      .map((name) => name.trim())
      .where(
        (name) =>
            name.isNotEmpty &&
            name.toLowerCase() != 'unknown',
      )
      .map(
        (name) => ColorNameLocalizer.localize(
          context,
          name,
        ),
      )
      .toList();

  if (validNames.isEmpty) {
    return 'Unknown';
  }

  return validNames.join(' + ');
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

  Widget _buildColorDots(Filament filament) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: filament.colors.take(4).map(
        (color) {
          return Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color == Colors.white
                  ? const Color(0xFFE5E7EB)
                  : color,
              shape: BoxShape.circle,
              border: color == Colors.white
                  ? Border.all(
                      color:
                          const Color(0xFF9CA3AF),
                      width: 0.5,
                    )
                  : null,
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildHeader(
    Filament filament, {
    required bool compact,
  }) {
    if (compact) {
      return Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 5),
            child: _buildColorDots(filament),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  filament.material,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _buildColorNames(context, filament),
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
                if (filament
                    .variant.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    filament.variant,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          Colors.grey.shade400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: _buildColorDots(filament),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    filament.material,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _buildColorNames(
  context,
  filament,
),
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
              if (filament
                  .variant.isNotEmpty)
                Text(
                  filament.variant,
                  maxLines: 3,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        Colors.grey.shade400,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPercentBadge(
    double percent,
    Color percentColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: percentColor.withValues(
          alpha: 0.12,
        ),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: percentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${percent.round()}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: percentColor,
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildActionButtons(
  Filament filament,
) {
  final l10n = AppLocalizations.of(context)!;

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: const Icon(
          Icons.edit,
          size: 18,
        ),
        onPressed: () {
          editingFilament = filament;

          final currentWeight =
              filament.spools.fold<double>(
            0,
            (sum, spool) =>
                sum + spool.weight,
          );

          weightController.text =
              currentWeight
                  .toInt()
                  .toString();

          setState(() {});
        },
      ),
      IconButton(
        icon: const Icon(
          Icons.delete,
          size: 18,
          color: Colors.red,
        ),
        onPressed: () async {
          final shouldDelete =
              await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: Text(
                  l10n.deleteFilamentTitle,
                ),
                content: Text(
                  '${l10n.deleteFilamentConfirmation}\n\n'
                  '${filament.material} '
                  '${_buildColorNames(context, filament)}',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        dialogContext,
                      ).pop(false);
                    },
                    child: Text(
                      l10n.cancel,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        dialogContext,
                      ).pop(true);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor:
                          Colors.red,
                    ),
                    child: Text(
                      l10n.delete,
                    ),
                  ),
                ],
              );
            },
          );

          if (!mounted) {
            return;
          }

          if (shouldDelete == true) {
            context
                .read<AppState>()
                .removeFilament(filament);
          }
        },
      ),
    ],
  );
}

  Widget _buildWeightEditor(
    Filament filament,
  ) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment:
          WrapCrossAlignment.center,
      children: [
        _weightButton(
          '-10',
          () => _changeWeight(
            -10,
            filament,
          ),
        ),
        _weightButton(
          '-',
          () => _changeWeight(
            -1,
            filament,
          ),
        ),
        SizedBox(
          width: 80,
          child: TextField(
            controller: weightController,
            keyboardType:
                TextInputType.number,
            textAlign: TextAlign.center,
            decoration:
                const InputDecoration(
              isDense: true,
            ),
          ),
        ),
        _weightButton(
          '+',
          () => _changeWeight(
            1,
            filament,
          ),
        ),
        _weightButton(
          '+10',
          () => _changeWeight(
            10,
            filament,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.check),
          color: Colors.green,
          onPressed: () {
            final newWeight =
                double.tryParse(
              weightController.text,
            );

            if (newWeight != null) {
              final currentWeight =
                  filament.spools.fold(
                0.0,
                (sum, spool) =>
                    sum + spool.weight,
              );

              if (newWeight <
                  currentWeight) {
                double toRemove =
                    currentWeight -
                        newWeight;

                for (final spool
                    in filament.spools) {
                  if (toRemove <= 0) {
                    break;
                  }

                  if (spool.weight <=
                      toRemove) {
                    toRemove -=
                        spool.weight;
                    spool.weight = 0;
                  } else {
                    spool.weight -=
                        toRemove;
                    toRemove = 0;
                  }
                }
              } else if (newWeight >
                  currentWeight) {
                double toAdd =
                    newWeight -
                        currentWeight;

                for (final spool
                    in filament
                        .spools.reversed) {
                  if (toAdd <= 0) {
                    break;
                  }

                  final freeSpace =
                      1000.0 -
                          spool.weight;

                  if (freeSpace <= 0) {
                    continue;
                  }

                  if (toAdd >=
                      freeSpace) {
                    spool.weight =
                        1000.0;
                    toAdd -=
                        freeSpace;
                  } else {
                    spool.weight +=
                        toAdd;
                    toAdd = 0;
                  }
                }
              }

              filament.remainingWeight =
                  filament.spools
                      .fold<double>(
                0,
                (sum, spool) =>
                    sum + spool.weight,
              );

              context
                  .read<AppState>()
                  .updateFilament(
                    filament,
                  );
            }

            setState(() {
              editingFilament = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildWeightInfo(
  Filament filament,
  double remainingWeight,
  double totalWeight,
  double percent,
) {
  final l10n = AppLocalizations.of(context)!;

  return Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              l10n.remainingWeightOfTotal(
                remainingWeight.toInt(),
                totalWeight.toInt(),
              ),
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SpoolCountWidget(
            spoolCount:
                filament.spools.length,
            showArrow: false,
          ),
        ],
      ),
      const SizedBox(height: 6),
      FilamentProgressBar(
        percent: percent,
      ),
    ],
  );
}

  Widget _buildDesktopLayout({
    required Filament filament,
    required bool isEditing,
    required double remainingWeight,
    required double totalWeight,
    required double percent,
    required Color percentColor,
  }) {
    return Row(
      children: [
        FilamentSpoolIcon(
          filament: filament,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildHeader(
                filament,
                compact: false,
              ),
              const SizedBox(height: 6),
              if (isEditing)
                _buildWeightEditor(
                  filament,
                )
              else
                _buildWeightInfo(
                  filament,
                  remainingWeight,
                  totalWeight,
                  percent,
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        if (!isEditing)
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              _buildPercentBadge(
                percent,
                percentColor,
              ),
              const SizedBox(height: 2),
              _buildActionButtons(
                filament,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMobileLayout({
    required Filament filament,
    required bool isEditing,
    required double remainingWeight,
    required double totalWeight,
    required double percent,
    required Color percentColor,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            FilamentSpoolIcon(
              filament: filament,
              size: 68,
              rightMargin: 12,
            ),
            Expanded(
              child: _buildHeader(
                filament,
                compact: true,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (isEditing)
          _buildWeightEditor(
            filament,
          )
        else ...[
          _buildWeightInfo(
            filament,
            remainingWeight,
            totalWeight,
            percent,
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _buildPercentBadge(
                percent,
                percentColor,
              ),
              const Spacer(),
              _buildActionButtons(
                filament,
              ),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filament = widget.filament;

    final appState =
        context.watch<AppState>();

    final totalWeight =
        filament.totalWeight;

    final remainingWeight =
        filament.spools.fold<double>(
      0,
      (sum, spool) =>
          sum + spool.weight,
    );

    final percent = totalWeight > 0
        ? (remainingWeight /
                totalWeight) *
            100
        : 0.0;

    Color percentColor;

    if (percent <=
        appState.warningPercent) {
      percentColor = Colors.red;
    } else if (percent <= 50) {
      percentColor = Colors.orange;
    } else {
      percentColor = Colors.green;
    }

    final isEditing =
        editingFilament == filament;

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: AppHoverCard(
        child: Card(
          color:
              isDark ? null : Colors.white,
          elevation: isDark ? 0 : 3,
          shadowColor: isDark
              ? Colors.transparent
              : Colors.black.withValues(
                  alpha: 0.08,
                ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: InkWell(
            borderRadius:
                BorderRadius.circular(20),
            onTap: () {
              if (isEditing) {
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FilamentDetailPage(
                    filament: filament,
                  ),
                ),
              );
            },
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (
                  context,
                  constraints,
                ) {
                  final isCompact =
                      constraints.maxWidth <
                          620;

                  if (isCompact) {
                    return _buildMobileLayout(
                      filament: filament,
                      isEditing: isEditing,
                      remainingWeight:
                          remainingWeight,
                      totalWeight:
                          totalWeight,
                      percent: percent,
                      percentColor:
                          percentColor,
                    );
                  }

                  return _buildDesktopLayout(
                    filament: filament,
                    isEditing: isEditing,
                    remainingWeight:
                        remainingWeight,
                    totalWeight:
                        totalWeight,
                    percent: percent,
                    percentColor:
                        percentColor,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}