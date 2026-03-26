import 'package:flutter/material.dart';
import '../models/print_job.dart';

class PrintJobDetailPage extends StatelessWidget {

  final PrintJob job;

  const PrintJobDetailPage({
    super.key,
    required this.job,
  });

  Widget _infoRow(String label, String value) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [

          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

        ],
      ),
    );

  }

  @override
  Widget build(BuildContext context) {

    final formattedDate =
        "${job.date.day.toString().padLeft(2, '0')}."
        "${job.date.month.toString().padLeft(2, '0')}."
        "${job.date.year}";

    return Scaffold(

      appBar: AppBar(
        title: Text(
          job.projectName.isEmpty
              ? "Druckdetails"
              : job.projectName,
        ),
      ),

      body: ListView(

        padding: const EdgeInsets.all(20),

        children: [

          /// FARBE

          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: job.color,
            ),
          ),

          const SizedBox(height: 30),

          /// FILAMENT

          const Text(
            "Filament",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(

                children: [

                  _infoRow(
                    "Hersteller",
                    job.filamentBrand,
                  ),

                  _infoRow(
                    "Material",
                    job.material,
                  ),

                  _infoRow(
                    "Variante",
                    job.variant,
                  ),

                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// DRUCKDATEN

          const Text(
            "Druckdaten",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(

                children: [

                  _infoRow(
                    "Gewicht",
                    "${job.weightUsed.toStringAsFixed(0)} g",
                  ),

                  _infoRow(
                    "Druckzeit",
                    "${job.printHours.toStringAsFixed(1)} h",
                  ),

                  _infoRow(
                    "Kosten",
                    "${job.totalCost.toStringAsFixed(2)} €",
                  ),

                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// DATUM

          const Text(
            "Datum",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: _infoRow(
                "Gedruckt am",
                formattedDate,
              ),
            ),
          ),

        ],
      ),

    );

  }

}