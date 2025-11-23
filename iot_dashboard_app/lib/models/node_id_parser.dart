// lib/models/node_id_parser.dart

/// Parses numeric NodeID of format:
/// WSSNNN...
/// W = warehouse (1 digit)
/// SS = slot (2 digits)
/// Rest = node id
///
/// Example:
/// 21045 → W=2, S=10, Node=45
class NodeIdParser {
  static Map<String, int> parse(String id) {
    final s = id.trim();
    if (s.isEmpty) return {'warehouse': 0, 'slot': 0, 'node': 0};

    final digits = RegExp(r'^\d+$').hasMatch(s) ? s : s.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 3) {
      return {'warehouse': 0, 'slot': 0, 'node': 0}; // invalid
    }

    final warehouse = int.tryParse(digits.substring(0, 1)) ?? 0;
    final slot = int.tryParse(digits.substring(1, 3)) ?? 0;
    final node = digits.length > 3 ? int.tryParse(digits.substring(3)) ?? 0 : 0;

    return {'warehouse': warehouse, 'slot': slot, 'node': node};
  }
}
