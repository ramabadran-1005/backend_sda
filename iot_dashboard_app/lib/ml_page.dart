import 'package:flutter/material.dart';
import 'main.dart'; // import ApiService and models

class MLPage extends StatefulWidget {
  @override
  State<MLPage> createState() => _MLPageState();
}

class _MLPageState extends State<MLPage> {
  final ApiService api = ApiService();
  late Future<List<PredictionData>> predictionsFuture;

  @override
  void initState() {
    super.initState();
    predictionsFuture = fetchPredictions();
  }

  // ========== Fetch predictions from backend ==========
  Future<List<PredictionData>> fetchPredictions() async {
    final data = await api.fetchData();
    List<PredictionData> preds = [];
    for (var d in data) {
      double prob = await api.predictFailure(d);
      preds.add(PredictionData(
        nodeId: d.nodeId,
        timestamp: d.timestamp,
        tgs2620: d.tgs2620,
        tgs2602: d.tgs2602,
        tgs2600: d.tgs2600,
        risk: prob,
      ));
    }
    return preds;
  }

  // ========== Risk color based on probability ==========
  Color getRiskColor(double risk) {
    if (risk > 50) return Colors.red;
    if (risk > 20) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ML Predictions")),
      body: FutureBuilder<List<PredictionData>>(
        future: predictionsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          if (data.isEmpty) return Center(child: Text("No predictions yet"));

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) {
              final d = data[i];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text("Node: ${d.nodeId}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("TGS2620: ${d.tgs2620} | TGS2602: ${d.tgs2602} | TGS2600: ${d.tgs2600}"),
                      Text(
                        "Failure Probability: ${d.risk.toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: getRiskColor(d.risk),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Timestamp: ${d.timestamp}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ========== PredictionData model ==========
class PredictionData {
  final int nodeId, tgs2620, tgs2602, tgs2600;
  final String timestamp;
  final double risk;

  PredictionData({
    required this.nodeId,
    required this.tgs2620,
    required this.tgs2602,
    required this.tgs2600,
    required this.timestamp,
    required this.risk,
  });
}
