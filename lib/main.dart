import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_report/screens/weather_screen.dart';
import 'providers/weather_provider.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Weather Report',
        theme: ThemeData(primarySwatch: Colors.blue),
        // home: const HomeScreen(),
        home: const WeatherScreen(),
      ),
    );
  }
}
