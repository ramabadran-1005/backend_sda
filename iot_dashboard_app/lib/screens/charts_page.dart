import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'master_data_service.dart';  // Your current API service

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  final service = MasterDataService();
  DateTime? from;
  DateTime? to;

  Future<void> pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context, initialDate: DateTime.now(),
      firstDate: DateTime(2024), lastDate: DateTime.now(),
    );

    if (picked != null) setState(() => isFrom ? from = picked : to = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => pickDate(true),
              child: Text(from == null ? "From" : DateFormat('dd-MM-yyyy').format(from!)),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => pickDate(false),
              child: Text(to == null ? "To" : DateFormat('dd-MM-yyyy').format(to!)),
            ),
          ],
        ),
        Expanded(
          child: FutureBuilder(
            future: service.fetchData(from: from, to: to),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                return const Center(child: Text("No Chart Data"));
              }

              final data = snapshot.data as List<MasterData>;

              final points = <FlSpot>[
                for (int i = 0; i < data.length; i++)
                  FlSpot(i.toDouble(), data[i].tgs2620.toDouble())
              ];

              return Padding(
                padding: const EdgeInsets.all(16),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true)),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: points,
                        isCurved: true,
                        barWidth: 3,
                        color: Colors.blue,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
