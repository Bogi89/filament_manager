import 'package:flutter/material.dart';

class PrintSettingsSection extends StatelessWidget {
  const PrintSettingsSection({
    super.key,
    required this.selectedDiameter,
    required this.diameters,
    required this.nozzleTemp,
    required this.bedTemp,
    required this.onDiameterChanged,
    required this.onNozzleTempChanged,
    required this.onBedTempChanged,
  });

  final double? selectedDiameter;
  final List<double> diameters;
  final int? nozzleTemp;
  final int? bedTemp;
  final ValueChanged<double?> onDiameterChanged;
  final ValueChanged<int?> onNozzleTempChanged;
  final ValueChanged<int?> onBedTempChanged;

  void _increaseNozzle() {
    onNozzleTempChanged((nozzleTemp ?? 0) + 10);
  }

  void _decreaseNozzle() {
    onNozzleTempChanged((nozzleTemp ?? 0) - 10);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Druckeinstellungen",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<double>(
            initialValue: selectedDiameter,
            hint: const Text("Durchmesser"),
            items: diameters
                .map((d) => DropdownMenuItem(value: d, child: Text("$d mm")))
                .toList(),
            onChanged: onDiameterChanged,
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              "Temperaturen",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          const SizedBox(height: 12),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.02)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),

              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Nozzle",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: _decreaseNozzle,
                            icon: const Icon(Icons.remove),
                          ),

                          GestureDetector(
                            onTap: () {
                              final controller = TextEditingController(
                                text: nozzleTemp?.toString() ?? '',
                              );

                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Nozzle Temperatur"),
                                    content: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Abbrechen"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          final value = int.tryParse(
                                            controller.text,
                                          );

                                          if (value != null) {
                                            onNozzleTempChanged(value);
                                          }

                                          Navigator.pop(context);
                                        },
                                        child: const Text("Speichern"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              "${nozzleTemp ?? '-'}°C",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          IconButton(
                            onPressed: _increaseNozzle,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Bed",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              onBedTempChanged((bedTemp ?? 0) - 5);
                            },
                            icon: const Icon(Icons.remove),
                          ),

                          Text(
                            "${bedTemp ?? '-'}°C",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              onBedTempChanged((bedTemp ?? 0) + 5);
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
