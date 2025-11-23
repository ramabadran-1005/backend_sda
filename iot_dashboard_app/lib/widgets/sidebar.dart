// lib/widgets/sidebar.dart
import 'package:flutter/material.dart';
import '../styles.dart';

class Sidebar extends StatelessWidget {
  final void Function(String route) onNavigate;
  const Sidebar({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Overview', 'route': '/'},
      {'label': 'Warehouse', 'route': '/warehouse'},
      {'label': 'Slots', 'route': '/slots'},
      {'label': 'Nodes', 'route': '/nodes'},
      {'label': 'Node Health', 'route': '/node_health'},
      {'label': 'Predictions', 'route': '/predictions'},
      {'label': 'Alerts', 'route': '/alerts'},
      {'label': 'Reports', 'route': '/reports'},
      {'label': 'Charts', 'route': '/charts'},
    ];
    return Container(
      width: 240,
      color: primaryGreen,
      child: Column(children: [
        const SizedBox(height: 28),
        Text('NWarehouse', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentYellow)),
        const SizedBox(height: 22),
        ...items.map((it) {
          return ListTile(
            leading: Icon(Icons.circle, size: 14, color: Colors.white54),
            title: Text(it['label']!, style: const TextStyle(color: Colors.white70)),
            onTap: () => onNavigate(it['route']!),
          );
        }).toList(),
        const Spacer(),
        const Divider(color: Colors.white24),
        const ListTile(
          leading: CircleAvatar(radius: 16, backgroundColor: accentYellow, child: Icon(Icons.person, color: primaryGreen)),
          title: Text('Admin', style: TextStyle(color: Colors.white)),
          subtitle: Text('SuperUser', style: TextStyle(color: Colors.white70)),
        ),
        const SizedBox(height: 12),
      ]),
    );
  }
}
