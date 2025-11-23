// lib/core/helpers.dart

/* -------------------- Safe Parsing Helpers -------------------- */

int parseIntSafe(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

double parseDoubleSafe(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

String parseStringSafe(dynamic v) {
  if (v == null) return '';
  return v.toString();
}

/* ---------------------------------------------------------------
   NodeID Parser — FINAL FORMAT (Based on your requirement)
   ✔ 1st digit  -> warehouse
   ✔ next 2     -> slot
   ✔ rest       -> node
   ✔ IDs smaller than 4 digits => INVALID
---------------------------------------------------------------- */

Map<String, int> parseNodeId(String raw) {
  String id = raw.trim();

  // remove any non-digit garbage
  id = id.replaceAll(RegExp(r'\D'), '');

  // invalid if less than 4 digits
  if (id.length < 4) {
    return {'warehouse': -1, 'slot': -1, 'node': -1};
  }

  final warehouse = int.tryParse(id.substring(0, 1)) ?? -1;
  final slot = int.tryParse(id.substring(1, 3)) ?? -1;
  final node = int.tryParse(id.substring(3)) ?? -1;

  return {
    'warehouse': warehouse,
    'slot': slot,
    'node': node,
  };
}

/* -------------------- Color Logic for Score -------------------- */

import 'package:flutter/material.dart';

Color scoreColor(double score) {
  if (score > 80) return Colors.red;
  if (score > 50) return Colors.orange;
  if (score > 20) return Colors.yellow.shade700;
  return Colors.green;
}

/* -------------------- Timestamp Helper -------------------- */

DateTime? parseTimestamp(dynamic v) {
  if (v == null) return null;
  try {
    return DateTime.tryParse(v.toString());
  } catch (_) {
    return null;
  }
}
