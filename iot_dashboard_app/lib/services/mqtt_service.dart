import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  MQTTService._();
  static final instance = MQTTService._();

  final _client = MqttServerClient('10.150.216.165', 'flutter_client');

  Future<void> init() async {
    _client.logging(on: false);
    _client.port = 1883;
    _client.keepAlivePeriod = 20;

    try {
      await _client.connect();
      _client.subscribe('warehouse/sensors', MqttQos.atLeastOnce);
    } catch (_) {}
  }

  void listen(Function(String msg) callback) async {
    if (_client.connectionStatus!.state != MqttConnectionState.connected) {
      await init();
    }

    _client.updates!.listen((events) {
      final message = (events[0].payload as MqttPublishMessage)
          .payload
          .message;

      callback(MqttPublishPayload.bytesToStringAsString(message));
    });
  }
}
