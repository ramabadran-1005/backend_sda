// lib/widgets/warehouse_tile.dart
import 'package:flutter/material.dart';
import 'gauge_widget.dart';
import '../styles.dart';
import 'package:flutter/widgets.dart';

class WarehouseTile extends StatelessWidget {
  final Map data;
  const WarehouseTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final int wid = data['warehouse'] ?? 0;
    final double avg = (data['avg'] ?? 0.0) as double;
    final bool active = avg < 80;
    final color = active ? primaryGreen : Colors.redAccent;
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/slots');
      },
      child: Card(
        child: SizedBox(
          height: 140,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(width: 120, height: 100, child: GaugeWidget(value: avg, label: 'WH $wid')),
            const SizedBox(height: 6),
            Text('Warehouse $wid', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${data['count']} nodes', style: const TextStyle(color: Colors.black54)),
          ]),
        ),
      ),
    );
  }
}
