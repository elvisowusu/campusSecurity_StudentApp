import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';

class SocketIOClient {
  final String serverUrl;
  late IO.Socket socket;

  SocketIOClient(this.serverUrl);

  Future<void> connect() async {
    socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connected to SocketIO server');
    });

    socket.onDisconnect((_) {
      print('Disconnected from SocketIO server');
    });

    socket.onError((error) {
      print('SocketIO Error: $error');
    });

    // Wait for the connection to be established
    await Future.delayed(Duration(seconds: 2));
  }

  Future<void> sendLocationUpdate({
    required String studentId,
    required double latitude,
    required double longitude,
  }) async {
    final url =
        'https://prediction-model-apjr.onrender.com/api/update_location';

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'student_id': studentId,
      'latitude': latitude,
      'longitude': longitude,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // print('Location update sent successfully');
      } else {
        // print('Failed to send location update: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error sending location update: $e');
    }
  }

  void updateLocation({
    required String studentId,
    required double latitude,
    required double longitude,
  }) async {
    socket.emit('update_location', {
      'student_id': studentId,
      'latitude': latitude,
      'longitude': longitude,
    });

    await sendLocationUpdate(
      studentId: studentId,
      latitude: latitude,
      longitude: longitude,
    );
  }

  void dispose() {
    socket.disconnect();
    socket.dispose();
  }
}
