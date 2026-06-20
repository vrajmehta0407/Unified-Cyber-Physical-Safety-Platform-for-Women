import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class SosStreamService {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  Future<void> connect({required String incidentId, required String wsUrl}) async {
    await disconnect();
    _channel = WebSocketChannel.connect(Uri.parse('$wsUrl/$incidentId'));

    _channel!.stream.listen((event) {
      try {
        final data = jsonDecode(event);
        if (data is Map<String, dynamic>) {
          _controller.add(data);
        }
      } catch (_) {
        // ignore malformed messages
      }
    }, onDone: () async {
      await disconnect();
    }, onError: (_) async {
      await disconnect();
    });
  }

  Future<void> sendLocation({required double lat, required double lng}) async {
    // Optional: send location updates to server so it can rebroadcast
    final payload = jsonEncode({'lat': lat, 'lng': lng});
    _channel?.sink.add(payload);
  }

  Future<void> disconnect() async {
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  void dispose() {
    _controller.close();
    disconnect();
  }
}

