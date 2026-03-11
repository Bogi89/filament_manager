import 'package:flutter/material.dart';
import '../models/print_job.dart';

class HistoryPage extends StatelessWidget {

  final List<PrintJob> jobs;

  const HistoryPage({
    super.key,
    required this.jobs,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Druck Historie"),
      ),

      body: jobs.isEmpty
          ? const Center(
              child: Text("Keine Drucke vorhanden"),
            )

          : ListView.builder(

              itemCount: jobs.length,

              itemBuilder: (context, index) {

                final job = jobs[index];

                return Card(

                  margin: const EdgeInsets.all(10),

                  child: Padding(

                    padding: const EdgeInsets.all(12),

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        /// PROJEKTNAME
                        if (job.projectName.isNotEmpty)

                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              "Projekt: ${job.projectName}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        ListTile(

                          contentPadding: EdgeInsets.zero,

                          leading: CircleAvatar(
                            backgroundColor: job.color,
                          ),

                          title: Text(
                            "${job.filamentBrand} ${job.material} ${job.variant}",
                          ),

                          subtitle: Text(
                            "${job.weightUsed.toStringAsFixed(0)} g • "
                            "${job.printHours.toStringAsFixed(1)} h\n"
                            "${job.date.day}.${job.date.month}.${job.date.year}",
                          ),

                          trailing: Text(
                            "${job.totalCost.toStringAsFixed(2)} €",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}