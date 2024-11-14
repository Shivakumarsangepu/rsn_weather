import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import '../models/weather_report_response.dart';

class WeatherProvider with ChangeNotifier {
  Weather? _weather;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  Weather? get weather => _weather;

  Future<void> fetchWeather() async {
    _isLoading = true;
    notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );

        String apiKey = '7af2b6984691f6aac34b411870873c43';
        String url = 'https://api.openweathermap.org/data/2.5/weather?'
            'lat=${position.latitude}&lon=${position.longitude}&units=metric&appid=$apiKey';
        debugPrint('api:: $url');
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          _weather = Weather.fromJson(data);
        } else {
          throw Exception('Failed to load weather data');
        }
      } else {
        throw Exception('Location permission denied');
      }
    } catch (e) {
      debugPrint('Error fetching weather data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
