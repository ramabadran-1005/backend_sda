// lib/pages/overview_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../styles.dart';
import '../widgets/stat_card.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (s.loadingOverview) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          StatCard(title: 'Nodes', value: s.totalNodes.toString(), icon: Icons.sensors, color: primaryGreen),
          StatCard(title: 'Alerts', value: s.totalAlerts.toString(), icon: Icons.warning, color: Colors.redAccent),
          StatCard(title: 'Predictions', value: s.totalPredictions.toString(), icon: Icons.analytics, color: accentYellow),
          StatCard(title: 'Reports', value: s.totalReports.toString(), icon: Icons.file_copy, color: Colors.teal),
        ],
      ),
    );
  }
}
