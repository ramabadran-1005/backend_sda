import 'package:flutter/material.dart';
import '../models/master_data_model.dart';
import '../widgets/sensor_card.dart';

class WarehouseMapPage extends StatelessWidget {
  final List<MasterData> nodes;

  WarehouseMapPage({this.nodes = const []});

  static const Map<int, Offset> positions = {
    2101: Offset(40, 60),
    2102: Offset(140, 60),
    2103: Offset(240, 60),
    2104: Offset(40, 160),
    2105: Offset(140, 160),
    2106: Offset(240, 160),
  };

  @override
  Widget build(BuildContext context) {
    final displayNodes = nodes.isEmpty
        ? [
            MasterData(
              nodeId: 2101,
              tgs2620: 767,
              tgs2602: 656,
              tgs2600: 1072,
              drift2620: 'None',
              drift2602: 'None',
              drift2600: 'None',
              var2620: 'None',
              var2602: 'None',
              var2600: 'None',
              flat2620: 'None',
              flat2602: 'None',
              flat2600: 'None',
              uptimeSec: 'None',
              jitterMs: 'None',
              rssiDbm: 'None',
              cpuTempC: 'None',
              freeHeapBytes: 'None',
              timestamp: '04-04-2025 11:44',
            ),
          ]
        : nodes;

    return Scaffold(
      appBar: AppBar(title: Text('Warehouse Map')),
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/warehouse_blueprint.png',
              opacity: AlwaysStoppedAnimation(0.2),
            ),
          ),
          for (var n in displayNodes)
            if (positions.containsKey(n.nodeId))
              Positioned(
                left: positions[n.nodeId]!.dx,
                top: positions[n.nodeId]!.dy,
                child: GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      content: SensorCard(node: n),
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.green,
                    child: Text(
                      '${n.nodeId}',
                      style: TextStyle(fontSize: 8, color: Colors.white),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
