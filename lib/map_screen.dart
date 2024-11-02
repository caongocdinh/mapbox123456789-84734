import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapboxMapController mapController;
  final String accessToken = "sk.eyJ1Ijoi...6D";  // Thay bằng access token của bạn

  final LatLng startPoint = LatLng(10.8231, 106.6297);  // Điểm bắt đầu
  final LatLng endPoint = LatLng(10.762622, 106.660172);  // Điểm kết thúc

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
    _showDistanceAndDuration();  // Gọi hàm này để hiển thị kết quả khi map được tạo
  }

  void _showDistanceAndDuration() async {
    final result = await calculateDistanceAndDuration(startPoint, endPoint);
    if (result != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Distance and Duration'),
          content: Text(
            'Distance: ${result['distance']} meters\nDuration: ${result['duration']} seconds',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapbox Distance Calculation'),
      ),
      body: MapboxMap(
        accessToken: accessToken,
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: startPoint,
          zoom: 12,
        ),
      ),
    );
  }

  // Hàm tính khoảng cách và thời gian
  Future<Map<String, dynamic>?> calculateDistanceAndDuration(
      LatLng start, LatLng end) async {
    final String url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?access_token=$accessToken';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];
        final distance = route['distance'];
        final duration = route['duration'];
        return {'distance': distance, 'duration': duration};
      } else {
        print('Request failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
