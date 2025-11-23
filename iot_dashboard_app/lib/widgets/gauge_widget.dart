// lib/widgets/gauge_widget.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../styles.dart';

class GaugeWidget extends StatelessWidget {
  final double value;
  final String label;
  const GaugeWidget({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final Color col = value > 80 ? Colors.red : value > 50 ? Colors.orange : primaryGreen;
    return SfRadialGauge(axes: [
      RadialAxis(minimum: 0, maximum: 100, showLabels: false, showTicks: false, ranges: [
        GaugeRange(startValue: 0, endValue: 30, color: Colors.green),
        GaugeRange(startValue: 30, endValue: 60, color: accentYellow),
        GaugeRange(startValue: 60, endValue: 80, color: Colors.orange),
        GaugeRange(startValue: 80, endValue: 100, color: Colors.red),
      ], pointers: [NeedlePointer(value: value)], annotations: [
        GaugeAnnotation(widget: Column(mainAxisSize: MainAxisSize.min, children: [Text('${value.toStringAsFixed(0)}%', style: TextStyle(color: col, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(fontSize: 10))]), positionFactor: 0.8)
      ])
    ]);
  }
}
