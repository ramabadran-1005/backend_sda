import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/report.dart';

class ReportsPage extends StatefulWidget {
  final int slotId;
  final String slotName;

  const ReportsPage({super.key, required this.slotId, required this.slotName});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final api = ApiService(baseUrl: 'http://YOUR_BACKEND_URL');
  List<Report> reports = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  void fetchReports() async {
    try {
      final data = await api.getReports(widget.slotId);
      setState(() {
        reports = data;
        loading = false;
      });
    } catch (e) {
      print('Error fetching reports: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reports for ${widget.slotName}')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return ListTile(
                  title: Text('Report ID: ${report.id}'),
                  subtitle: Text('Status: ${report.status}'),
                );
              },
            ),
    );
  }
}
