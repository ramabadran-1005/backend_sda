// lib/pages/warehouse_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/warehouse_tile.dart';

class WarehousePage extends StatefulWidget {
  const WarehousePage({super.key});
  @override
  State<WarehousePage> createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  @override
  void initState() {
    super.initState();
    final s = Provider.of<AppState>(context, listen: false);
    s.loadWarehouses();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (s.loadingWarehouses) return const Center(child: CircularProgressIndicator());
    if (s.warehouses.isEmpty) return const Center(child: Text('No warehouses found'));

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: s.warehouses.map((w) => WarehouseTile(data: w)).toList(),
      ),
    );
  }
}
