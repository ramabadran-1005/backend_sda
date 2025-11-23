// lib/pages/predictions_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../styles.dart';

class PredictionsPage extends StatefulWidget {
  const PredictionsPage({super.key});
  @override
  State<PredictionsPage> createState() => _PredictionsPageState();
}

class _PredictionsPageState extends State<PredictionsPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<AppState>(context, listen: false).loadPredictions();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (s.loadingPredictions) return const Center(child: CircularProgressIndicator());
    if (s.predictions.isEmpty) return const Center(child: Text('No predictions'));
    return RefreshIndicator(
      onRefresh: () async => Provider.of<AppState>(context, listen: false).loadPredictions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: s.predictions.length,
        itemBuilder: (ctx, i) {
          final p = s.predictions[i];
          final nodeId = p['nodeId'] ?? p['NodeID'] ?? 'NA';
          final score = (p['riskScore'] ?? 0.0) as double;
          final status = score > 80 ? 'Critical' : score > 50 ? 'High' : score > 20 ? 'Medium' : 'Healthy';
          final color = score > 80 ? Colors.red : score > 50 ? Colors.orange : score > 20 ? accentYellow : primaryGreen;
          return Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: color, child: Text(nodeId.toString().substring(0, 2))),
              title: Text('Node $nodeId'),
              subtitle: Text('Risk ${score.toStringAsFixed(1)}%  • $status'),
              trailing: IconButton(icon: const Icon(Icons.refresh), onPressed: () => Provider.of<AppState>(context, listen: false).requestPrediction(p)),
            ),
          );
        },
      ),
    );
  }
}
