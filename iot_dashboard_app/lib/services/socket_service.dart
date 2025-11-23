import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? socket;

  connect(Function(dynamic) onData) {
    socket = IO.io(
      "http://10.150.216.165:4000",
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );

    socket!.onConnect((_) {
      print("✅ Socket Connected");
    });

    socket!.on("iot_update", (data) {
      onData(data);
    });

    socket!.onDisconnect((_) => print("❌ Socket Disconnected"));
  }

  dispose() {
    socket?.disconnect();
  }
}
