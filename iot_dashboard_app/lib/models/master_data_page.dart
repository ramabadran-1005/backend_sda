import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ===== Models =====
class MasterData {
  final int nodeId;
  final int tgs2620;
  final int tgs2602;
  final int tgs2600;
  final String timestamp;

  MasterData({
    required this.nodeId,
    required this.tgs2620,
    required this.tgs2602,
    required this.tgs2600,
    required this.timestamp,
  });

  factory MasterData.fromJson(Map<String, dynamic> json) {
    return MasterData(
      nodeId: json['NodeID'] ?? 0,
      tgs2620: json['TGS2620'] ?? 0,
      tgs2602: json['TGS2602'] ?? 0,
      tgs2600: json['TGS2600'] ?? 0,
      timestamp: json['Timestamp'] ?? 'N/A',
    );
  }
}

// ===== Pages =====
class MasterDataPage extends StatefulWidget {
  const MasterDataPage({super.key});

  @override
  State<MasterDataPage> createState() => _MasterDataPageState();
}

class _MasterDataPageState extends State<MasterDataPage> {
  List<MasterData> nodes = [];
  bool isLoading = true;

  final String apiUrl = 'http://10.150.216.165:4000/api/masterdata';

  Future<void> fetchMasterData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          nodes = data.map((e) => MasterData.fromJson(e)).toList();
        } else {
          // fallback to dummy data
          nodes = getDummyData();
        }
      } else {
        // fallback to dummy data
        nodes = getDummyData();
      }
    } catch (e) {
      // fallback to dummy data
      nodes = getDummyData();
    }

    setState(() => isLoading = false);
  }

  List<MasterData> getDummyData() {
    return [
      MasterData(nodeId: 2101, tgs2620: 767, tgs2602: 656, tgs2600: 1072, timestamp: '04-04-2025 11:44'),
      MasterData(nodeId: 2102, tgs2620: 780, tgs2602: 670, tgs2600: 1090, timestamp: '04-04-2025 11:45'),
      MasterData(nodeId: 2103, tgs2620: 790, tgs2602: 680, tgs2600: 1100, timestamp: '04-04-2025 11:46'),
    ];
  }

  @override
  void initState() {
    super.initState();
    fetchMasterData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Master Data')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: nodes.length,
              itemBuilder: (context, index) {
                final node = nodes[index];
                return Card(
                  child: ListTile(
                    title: Text('NodeID: ${node.nodeId} | Timestamp: ${node.timestamp}'),
                    subtitle: Text('TGS2620: ${node.tgs2620}, TGS2602: ${node.tgs2602}, TGS2600: ${node.tgs2600}'),
                  ),
                );
              },
            ),
    );
  }
}

// ===== Main App =====
void main() => runApp(MaterialApp(
      title: 'IoT Dashboard Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: MasterDataPage(),
    ));
