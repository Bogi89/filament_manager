import 'package:flutter/material.dart';
import '../models/print_job.dart';
import 'print_job_detail_page.dart';
import '../widgets/common/page_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/common/app_hover_card.dart';

enum SortOption { dateDesc, dateAsc, cost, weight, name }

enum DateFilterOption { all, today, week, month, year }

class HistoryPage extends StatefulWidget {
  final List<PrintJob> jobs;

  const HistoryPage({super.key, required this.jobs});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  SortOption selectedSort = SortOption.dateDesc;

  DateFilterOption selectedDateFilter = DateFilterOption.all;

  String selectedMaterial = "Alle";

  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  final Set<String> expandedMonths = {};

  static const String expandedMonthsKey = 'history_expanded_months';

  Future<void> _loadExpandedMonths() async {
    final prefs = await SharedPreferences.getInstance();

    final savedMonths = prefs.getStringList(expandedMonthsKey) ?? [];

    if (!mounted) return;

    setState(() {
      expandedMonths
        ..clear()
        ..addAll(savedMonths);
    });
  }

  Future<void> _saveExpandedMonths() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(expandedMonthsKey, expandedMonths.toList());
  }

  @override
  void initState() {
    super.initState();
    _loadExpandedMonths();
  }

  List<String> getMaterials() {
    final materials = widget.jobs.map((j) => j.material).toSet().toList();

    materials.sort();

    return ["Alle", ...materials];
  }

  void resetFilters() {
    setState(() {
      selectedSort = SortOption.dateDesc;

      selectedDateFilter = DateFilterOption.all;

      selectedMaterial = "Alle";

      searchController.clear();

      searchText = "";
    });
  }

  List<PrintJob> getProcessedJobs() {
    List<PrintJob> list = List.from(widget.jobs);

    /// 🔍 SUCHE

    if (searchText.isNotEmpty) {
      final query = searchText.toLowerCase();

      list = list.where((job) {
        return job.projectName.toLowerCase().contains(query);
      }).toList();
    }

    /// 🧪 MATERIAL

    if (selectedMaterial != "Alle") {
      list = list.where((job) {
        return job.material == selectedMaterial;
      }).toList();
    }

    /// 📅 DATUM FILTER

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
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

          return job.date.isAfter(
            startOfWeek.subtract(const Duration(days: 1)),
          );

        case DateFilterOption.month:
          return job.date.year == now.year && job.date.month == now.month;

        case DateFilterOption.year:
          return job.date.year == now.year;
      }
    }).toList();

    /// 📊 SORTIERUNG

    switch (selectedSort) {
      case SortOption.dateDesc:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;

      case SortOption.dateAsc:
        list.sort((a, b) => a.date.compareTo(b.date));
        break;

      case SortOption.cost:
        list.sort((a, b) => b.totalCost.compareTo(a.totalCost));
        break;

      case SortOption.weight:
        list.sort((a, b) => b.weightUsed.compareTo(a.weightUsed));
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

  Map<String, List<PrintJob>> groupByMonth(List<PrintJob> jobs) {
    final Map<String, List<PrintJob>> grouped = {};

    for (var job in jobs) {
      final key = "${_getMonthName(job.date.month)} ${job.date.year}";

      grouped.putIfAbsent(key, () => []);

      grouped[key]!.add(job);
    }

    return grouped;
  }

  String _getMonthName(int month) {
    const months = [
      "Januar",
      "Februar",
      "März",
      "April",
      "Mai",
      "Juni",
      "Juli",
      "August",
      "September",
      "Oktober",
      "November",
      "Dezember",
    ];

    return months[month - 1];
  }

  String getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.dateDesc:
        return "Datum (neu → alt)";

      case SortOption.dateAsc:
        return "Datum (alt → neu)";

      case SortOption.cost:
        return "Kosten";

      case SortOption.weight:
        return "Gewicht";

      case SortOption.name:
        return "Projektname";
    }
  }

  String getDateFilterLabel(DateFilterOption option) {
    switch (option) {
      case DateFilterOption.all:
        return "Alle";

      case DateFilterOption.today:
        return "Heute";

      case DateFilterOption.week:
        return "Diese Woche";

      case DateFilterOption.month:
        return "Dieser Monat";

      case DateFilterOption.year:
        return "Dieses Jahr";
    }
  }

  @override
  Widget build(BuildContext context) {
    final processed = getProcessedJobs();

    final grouped = groupByMonth(processed);

    final materials = getMaterials();

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFFE9EEF5),
      body: Column(
        children: [
          const PageHeader(title: "Druck Historie"),

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
                            color:
                                Theme.of(context).brightness == Brightness.dark
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
                                child: Text(getSortLabel(option)),
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<DateFilterOption>(
                            value: selectedDateFilter,
                            isExpanded: true,
                            items: DateFilterOption.values.map((option) {
                              return DropdownMenuItem(
                                value: option,
                                child: Text(getDateFilterLabel(option)),
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedMaterial,
                            isExpanded: true,
                            items: materials.map((m) {
                              return DropdownMenuItem(value: m, child: Text(m));
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }

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

                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),

                    hintText: "Projekt suchen...",

                    border: OutlineInputBorder(),
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

                    label: const Text("Filter zurücksetzen"),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: processed.isEmpty
                ? const Center(child: Text("Keine Drucke vorhanden"))
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
                              margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color:
                                      Theme.of(context).brightness ==
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
                                        child: const Icon(Icons.chevron_right),
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
                                        jobs.length == 1
                                            ? "1 Auftrag"
                                            : "${jobs.length} Aufträge",
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
                                          ? Colors.white.withValues(alpha: 0.06)
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
                                              PrintJobDetailPage(job: job),
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
                                              padding: const EdgeInsets.only(
                                                bottom: 6,
                                              ),

                                              child: Text(
                                                job.projectName,

                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                          ListTile(
                                            contentPadding: EdgeInsets.zero,

                                            leading: CircleAvatar(
                                              backgroundColor: job.color,
                                              child: job.color == Colors.white
                                                  ? Container(
                                                      width: 36,
                                                      height: 36,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
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
                                              "${job.filamentBrand} "
                                              "${job.material} "
                                              "${job.variant}",
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
                                              "${job.weightUsed.toStringAsFixed(0)} g • "
                                              "${job.printHours.toStringAsFixed(1)} h\n"
                                              "${job.date.day}."
                                              "${job.date.month}."
                                              "${job.date.year}",
                                            ),

                                            trailing: Text(
                                              "${job.totalCost.toStringAsFixed(2)} €",

                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
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
