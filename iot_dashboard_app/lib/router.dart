// lib/router.dart
import 'package:flutter/material.dart';
import 'pages/overview_page.dart';
import 'pages/warehouse_page.dart';
import 'pages/slots_page.dart';
import 'pages/nodes_page.dart';
import 'pages/node_health_page.dart';
import 'pages/predictions_page.dart';
import 'pages/alerts_page.dart';
import 'pages/reports_page.dart';
import 'pages/charts_page.dart';

Map<String, WidgetBuilder> appRoutes() {
  return {
    '/': (_) => const OverviewPage(),
    '/warehouse': (_) => const WarehousePage(),
    '/slots': (_) => const SlotsPage(),
    '/nodes': (_) => const NodesPage(),
    '/node_health': (_) => const NodeHealthPage(),
    '/predictions': (_) => const PredictionsPage(),
    '/alerts': (_) => const AlertsPage(),
    '/reports': (_) => const ReportsPage(),
    '/charts': (_) => const ChartsPage(),
  };
}
