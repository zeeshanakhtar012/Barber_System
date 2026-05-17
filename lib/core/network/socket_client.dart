import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketClient extends GetxService {
  late io.Socket queueSocket;
  late io.Socket notificationSocket;

  // Base URL for socket connection
  static final String baseUrl = GetPlatform.isAndroid ? 'http://10.0.2.2:5001' : 'http://localhost:5001';

  Future<SocketClient> init() async {
    queueSocket = io.io('$baseUrl/queue', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    notificationSocket = io.io('$baseUrl/notifications', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    return this;
  }

  void connectQueue(String shopId) {
    if (!queueSocket.connected) {
      queueSocket.connect();
    }
    queueSocket.emit('join_shop_room', shopId);
  }

  void disconnectQueue() {
    if (queueSocket.connected) {
      queueSocket.disconnect();
    }
  }
}
