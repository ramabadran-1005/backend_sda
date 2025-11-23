// lib/pages/slots_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../styles.dart';
import 'nodes_page.dart';

class SlotsPage extends StatefulWidget {
  final String? filterWarehouse;
  const SlotsPage({super.key, this.filterWarehouse});
  @override
  State<SlotsPage> createState() => _SlotsPageState();
}

class _SlotsPageState extends State<SlotsPage> {
  @override
  void initState() {
    super.initState();
    final s = Provider.of<AppState>(context, listen: false);
    s.loadSlots(widget.filterWarehouse);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (s.loadingSlots) return const Center(child: CircularProgressIndicator());
    if (s.slots.isEmpty) return const Center(child: Text('No slots found'));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: s.slots.length,
      itemBuilder: (_, i) {
        final slot = s.slots[i];
        final avg = slot['avg'] ?? 0.0;
        final color = avg > 80 ? Colors.red : avg > 50 ? Colors.orange : primaryGreen;
        return Card(
          child: ListTile(
            leading: SizedBox(
              width: 64,
              child: slotGauge(avg),
            ),
            title: Text('Warehouse ${slot['warehouse']} - Slot ${slot['slot']}'),
            subtitle: Text('${slot['count']} nodes • Avg ${avg.toStringAsFixed(1)}%'),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => NodesPage(filterWarehouse: slot['warehouse'].toString(), filterSlot: slot['slot'].toString())));
              },
              style: ElevatedButton.styleFrom(backgroundColor: accentYellow, foregroundColor: Colors.black),
              child: const Text('Open'),
            ),
          ),
        );
      },
    );
  }
}
