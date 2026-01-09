import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/master_data_model.dart';
import '../widgets/sensor_card.dart';
import '../services/mqtt_service.dart';
import '../utils/anomaly.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final String apiUrl = "http://10.150.216.165:4000/api/master-data/";
  List<MasterData> nodes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
    MqttService.listen(onMessage);
    startAutoRefresh();
  }

  void startAutoRefresh() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 10));
      fetchData();
      return true;
    });
  }

  void onMessage(String data) {
    final jsonData = jsonDecode(data);
    final newNode = MasterData.fromJson(jsonData);

    setState(() {
      nodes.removeWhere((n) => n.nodeId == newNode.nodeId);
      nodes.add(newNode);
    });

    // Detect anomaly (turn into alert)
    if (detectAnomaly(newNode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("⚠ Node ${newNode.nodeId} anomaly detected!"),
        ),
      );
    }
  }

  Future<void> fetchData() async {
    try {
      setState(() => loading = true);
      final r = await http.get(Uri.parse(apiUrl));
      final body = jsonDecode(r.body);

      List list = body['data'];
      nodes = list.map((e) => MasterData.fromJson(e)).toList();

      setState(() => loading = false);
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Warehouse Sensors"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            onPressed: fetchData,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemCount: nodes.length,
                itemBuilder: (ctx, i) => SensorCard(node: nodes[i]),
              ),
            ),
    );
  }
}
