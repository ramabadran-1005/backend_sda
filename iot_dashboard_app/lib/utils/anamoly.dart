import '../models/master_data_model.dart';

bool detectAnomaly(MasterData d) {
  if ((d.tgs2620 ?? 0) > 900) return true;
  if ((d.cpuTemp ?? 0) > 70) return true;
  if ((d.rssi ?? -30) < -85) return true;
  return false;
}
