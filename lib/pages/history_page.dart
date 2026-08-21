import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/print_job.dart';
import '../widgets/common/app_hover_card.dart';
import '../widgets/common/page_header.dart';
import 'print_job_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SortOption { dateDesc, dateAsc, cost, weight, name }

enum DateFilterOption { all, today, week, month, year }

class HistoryPage extends StatefulWidget {
  final List<PrintJob> jobs;

  const HistoryPage({
    super.key,
    required this.jobs,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  SortOption selectedSort = SortOption.dateDesc;

  DateFilterOption selectedDateFilter = DateFilterOption.all;

  String? selectedMaterial;

  final TextEditingController searchController = TextEditingController();

  String searchText = '';

  final Set<String> expandedMonths = {};

  static const String expandedMonthsKey = 'history_expanded_months';

  Future<void> _loadExpandedMonths() async {
    final prefs = await SharedPreferences.getInstance();

    final savedMonths = prefs.getStringList(expandedMonthsKey) ?? [];

    if (!mounted) {
      return;
    }

    setState(() {
      expandedMonths
        ..clear()
        ..addAll(savedMonths);
    });
  }

  Future<void> _saveExpandedMonths() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      expandedMonthsKey,
      expandedMonths.toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadExpandedMonths();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<String> getMaterials() {
    final materials = widget.jobs
        .map((job) => job.material)
        .toSet()
        .toList();

    materials.sort();

    return materials;
  }

  void resetFilters() {
    setState(() {
      selectedSort = SortOption.dateDesc;

      selectedDateFilter = DateFilterOption.all;

      selectedMaterial = null;

      searchController.clear();

      searchText = '';
    });
  }

  List<PrintJob> getProcessedJobs() {
    List<PrintJob> list = List.from(widget.jobs);

    if (searchText.isNotEmpty) {
      final query = searchText.toLowerCase();

      list = list.where((job) {
        return job.projectName.toLowerCase().contains(query);
      }).toList();
    }

    if (selectedMaterial != null) {
      list = list.where((job) {
        return job.material == selectedMaterial;
      }).toList();
    }

    final now = DateTime.now();

    list = list.where((job) {
      switch (selectedDateFilter) {
        case DateFilterOption.all:
          return true;

        case DateFilterOption.today:
          return job.date.year == now.year &&
              job.date.month == now.month &&
              job.date.day == now.day;

        case DateFilterOption.week:
          final startOfWeek = now.subtract(
            Duration(days: now.weekday - 1),
          );

          return job.date.isAfter(
            startOfWeek.subtract(
              const Duration(days: 1),
            ),
          );

        case DateFilterOption.month:
          return job.date.year == now.year &&
              job.date.month == now.month;

        case DateFilterOption.year:
          return job.date.year == now.year;
      }
    }).toList();

    switch (selectedSort) {
      case SortOption.dateDesc:
        list.sort(
          (a, b) => b.date.compareTo(a.date),
        );
        break;

      case SortOption.dateAsc:
        list.sort(
          (a, b) => a.date.compareTo(b.date),
        );
        break;

      case SortOption.cost:
        list.sort(
          (a, b) => b.totalCost.compareTo(a.totalCost),
        );
        break;

      case SortOption.weight:
        list.sort(
          (a, b) => b.weightUsed.compareTo(a.weightUsed),
        );
        break;

      case SortOption.name:
        list.sort(
          (a, b) => a.projectName.toLowerCase().compareTo(
                b.projectName.toLowerCase(),
              ),
        );
        break;
    }

    return list;
  }

  Map<String, List<PrintJob>> groupByMonth(
    List<PrintJob> jobs,
    String localeName,
  ) {
    final Map<String, List<PrintJob>> grouped = {};

    for (final job in jobs) {
      final key =
          '${_getMonthName(job.date.month, localeName)} ${job.date.year}';

      grouped.putIfAbsent(
        key,
        () => [],
      );

      grouped[key]!.add(job);
    }

    return grouped;
  }

  String _getMonthName(
    int month,
    String localeName,
  ) {
    return DateFormat.MMMM(localeName).format(
      DateTime(2000, month),
    );
  }

  String getSortLabel(
    AppLocalizations l10n,
    SortOption option,
  ) {
    switch (option) {
      case SortOption.dateDesc:
        return l10n.sortByDateNewest;

      case SortOption.dateAsc:
        return l10n.sortByDateOldest;

      case SortOption.cost:
        return l10n.sortByCost;

      case SortOption.weight:
        return l10n.sortByWeight;

      case SortOption.name:
        return l10n.sortByProjectName;
    }
  }

  String getDateFilterLabel(
    AppLocalizations l10n,
    DateFilterOption option,
  ) {
    switch (option) {
      case DateFilterOption.all:
        return l10n.all;

      case DateFilterOption.today:
        return l10n.today;

      case DateFilterOption.week:
        return l10n.thisWeek;

      case DateFilterOption.month:
        return l10n.thisMonth;

      case DateFilterOption.year:
        return l10n.thisYear;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final processed = getProcessedJobs();

    final grouped = groupByMonth(
      processed,
      l10n.localeName,
    );

    final materials = getMaterials();

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFFE9EEF5),
      body: Column(
        children: [
          PageHeader(
            title: l10n.printHistory,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<SortOption>(
                            value: selectedSort,
                            isExpanded: true,
                            items: SortOption.values.map((option) {
                              return DropdownMenuItem(
                                value: option,
                                child: Text(
                                  getSortLabel(
                                    l10n,
                                    option,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                selectedSort = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<DateFilterOption>(
                            value: selectedDateFilter,
                            isExpanded: true,
                            items:
                                DateFilterOption.values.map((option) {
                              return DropdownMenuItem(
                                value: option,
                                child: Text(
                                  getDateFilterLabel(
                                    l10n,
                                    option,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                selectedDateFilter = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: selectedMaterial,
                            isExpanded: true,
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text(l10n.all),
                              ),
                              ...materials.map((material) {
                                return DropdownMenuItem<String?>(
                                  value: material,
                                  child: Text(material),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedMaterial = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: l10n.searchProject,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: resetFilters,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.resetFilters),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: processed.isEmpty
                ? Center(
                    child: Text(
                      l10n.noPrintsAvailable,
                    ),
                  )
                : ListView(
                    children: grouped.entries.map((entry) {
                      final month = entry.key;

                      final jobs = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppHoverCard(
                            child: Card(
                              elevation: 0,
                              color: Theme.of(context).cardColor,
                              margin: const EdgeInsets.fromLTRB(
                                12,
                                8,
                                12,
                                4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withValues(alpha: 0.10)
                                      : Colors.black.withValues(alpha: 0.08),
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  setState(() {
                                    if (expandedMonths.contains(month)) {
                                      expandedMonths.remove(month);
                                    } else {
                                      expandedMonths.add(month);
                                    }
                                  });

                                  _saveExpandedMonths();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      AnimatedRotation(
                                        turns: expandedMonths.contains(month)
                                            ? 0.25
                                            : 0,
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        child: const Icon(
                                          Icons.chevron_right,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          month,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        l10n.historyJobs(
                                          jobs.length,
                                        ),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey.shade300
                                                  : Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (expandedMonths.contains(month))
                            ...jobs.asMap().entries.map((entry) {
                              final index = entry.key;

                              final job = entry.value;

                              final isLast = index == jobs.length - 1;

                              return AppHoverCard(
                                child: Card(
                                  elevation: 0,
                                  color: Theme.of(context).cardColor,
                                  margin: EdgeInsets.fromLTRB(
                                    12,
                                    4,
                                    12,
                                    isLast ? 18 : 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white.withValues(
                                                  alpha: 0.06,
                                                )
                                              : Colors.black.withValues(
                                                  alpha: 0.05,
                                                ),
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              PrintJobDetailPage(
                                            job: job,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (job.projectName.isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(
                                                bottom: 6,
                                              ),
                                              child: Text(
                                                job.projectName,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ListTile(
                                            contentPadding:
                                                EdgeInsets.zero,
                                            leading: CircleAvatar(
                                              backgroundColor: job.color,
                                              child: job.color ==
                                                      Colors.white
                                                  ? Container(
                                                      width: 36,
                                                      height: 36,
                                                      decoration:
                                                          BoxDecoration(
                                                        shape:
                                                            BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors
                                                              .grey
                                                              .shade400,
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                            title: Text(
                                              '${job.filamentBrand} '
                                              '${job.material} '
                                              '${job.variant}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color:
                                                    Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey.shade300
                                                    : Colors.grey.shade700,
                                              ),
                                            ),
                                            subtitle: Text(
                                              '${job.weightUsed.toStringAsFixed(0)} g • '
                                              '${job.printHours.toStringAsFixed(1)} h\n'
                                              '${job.date.day}.'
                                              '${job.date.month}.'
                                              '${job.date.year}',
                                            ),
                                            trailing: Text(
                                              '${job.totalCost.toStringAsFixed(2)} €',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                    FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}