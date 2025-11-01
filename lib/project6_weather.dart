import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherData {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final double feelsLike;
  final int humidity;
  final double windSpeed;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      feelsLike: json['main']['feels_like'].toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
 
  static const String _apiKey = [API_KEY];
  Future<WeatherData>? _weatherFuture;
  String? _debugMessage;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _debugMessage = 'Location services are disabled. Please enable GPS.';
      });
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _debugMessage = 'Location permissions are denied. Please grant location access.';
        });
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _debugMessage = 'Location permissions are permanently denied. Please enable in settings.';
      });
      throw Exception('Location permissions are permanently denied');
    }

    setState(() {
      _debugMessage = 'Getting location...';
    });

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<WeatherData> _fetchWeather() async {
    try {
      

      // 1. Kiểm tra xem key có rỗng không (an toàn hơn)
      if (_apiKey.isEmpty || _apiKey == [API_KEY]) {
        setState(() {
          _debugMessage = 'Please replace the placeholder API key with your actual OpenWeatherMap API key.';
        });
        throw Exception('API key not configured. Please add your own key.');
      }

      final position = await _determinePosition();

      setState(() {
        _debugMessage = 'Location: ${position.latitude}, ${position.longitude}\nFetching weather...';
      });

      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric',
      );

      print('Fetching from: $url'); // Debug log

      final response = await http.get(url);

      setState(() {
        _debugMessage = 'Response status: ${response.statusCode}';
      });

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          _debugMessage = null; // Clear debug message on success
        });
        return WeatherData.fromJson(json);
      } else if (response.statusCode == 401) {
        setState(() {
          _debugMessage = 'Invalid API key. Please check your OpenWeatherMap API key.';
        });
        throw Exception('Invalid API key');
      } else {
        setState(() {
          _debugMessage = 'Server error: ${response.statusCode}\n${response.body}';
        });
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in _fetchWeather: $e'); // Debug log
      if (_debugMessage == null || !_debugMessage!.contains('Please replace')) {
        setState(() {
          _debugMessage = 'Error: $e';
        });
      }
      rethrow;
    }
  }

  void _loadWeather() {
    setState(() {
      _weatherFuture = _fetchWeather();
      _debugMessage = 'Starting...';
    });
  }

  String _getWeatherIcon(String iconCode) {
    // Map weather icons to emojis
    switch (iconCode.substring(0, 2)) {
      case '01':
        return '☀️';
      case '02':
        return '⛅';
      case '03':
      case '04':
        return '☁️';
      case '09':
      case '10':
        return '🌧️';
      case '11':
        return '⛈️';
      case '13':
        return '❄️';
      case '50':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeather,
          ),
        ],
      ),
      body: FutureBuilder<WeatherData>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Loading weather data...'),
                  if (_debugMessage != null) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _debugMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load weather',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_debugMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _debugMessage!,
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadWeather,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                    const SizedBox(height: 32),
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📝 Setup Instructions:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('1. Get free API key from:\nopenweathermap.org/api'),
                            SizedBox(height: 4),
                            Text('2. Replace the placeholder API key in the code'),
                            SizedBox(height: 4),
                            Text('3. Enable location permissions in your device settings'),
                            SizedBox(height: 4),
                            Text('4. Make sure GPS is enabled'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final weather = snapshot.data!;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue[400]!,
                  Colors.blue[800]!,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weather.cityName,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateTime.now().toString().split(' ')[0],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _getWeatherIcon(weather.icon),
                    style: const TextStyle(fontSize: 100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${weather.temperature.round()}°C',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    weather.description.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWeatherDetail(
                          icon: Icons.thermostat,
                          label: 'Feels Like',
                          value: '${weather.feelsLike.round()}°C',
                        ),
                        _buildWeatherDetail(
                          icon: Icons.water_drop,
                          label: 'Humidity',
                          value: '${weather.humidity}%',
                        ),
                        _buildWeatherDetail(
                          icon: Icons.air,
                          label: 'Wind',
                          value: '${weather.windSpeed.round()} m/s',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
