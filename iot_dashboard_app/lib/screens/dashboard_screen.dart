import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/master_data_model.dart';
import 'login_screen.dart';

class WarehouseMap extends StatefulWidget {
  const WarehouseMap({super.key});

  @override
  State<WarehouseMap> createState() => _WarehouseMapState();
}

class _WarehouseMapState extends State<WarehouseMap> {
  List<MasterData> nodes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMasterData();
  }

  Future<void> _loadMasterData() async {
    setState(() { _loading = true; _error = null; });
    try {
      nodes = await ApiService.fetchMasterData();
    } catch (e) {
      _error = e.toString();
    }
    setState(() { _loading = false; });
  }

  Future<void> _logout() async {
    await AuthService().logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  itemCount: nodes.length,
                  itemBuilder: (_, i) {
                    final node = nodes[i];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text('${node.name} (ID: ${node.nodeId})'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (node.location != null) Text('Location: ${node.location}'),
                            Text('Drift: ${node.drift2600}, ${node.drift2602}, ${node.drift2620}'),
                            Text('Var: ${node.var2600}, ${node.var2602}, ${node.var2620}'),
                            Text('Flat: ${node.flat2600}, ${node.flat2602}, ${node.flat2620}'),
                            Text('Uptime: ${node.uptimeSec}s, Jitter: ${node.jitterMs}ms'),
                            Text('RSSI: ${node.rssiDbm} dBm, CPU Temp: ${node.cpuTempC}°C'),
                            Text('Free Heap: ${node.freeHeapBytes} bytes'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
