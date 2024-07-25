import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:weather_app/SearchWidget.dart';
import 'package:weather_app/main.dart';
import 'secretdata.dart';
import 'additional_info_item.dart';
import 'hourly_forecast.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String cityName = 'London';
  String errorMessage = '';

  Future<Map<String, dynamic>> getCurrentWeather() async {
    if (cityName.isEmpty) {
      throw "City name cannot be empty.";
    }

    try {
      final result = await http.get(
        Uri.parse(
            "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey"),
      );
      final data = jsonDecode(result.body);

      if (int.parse(data['cod']) != 200) {
        throw "City not found.";
      }

      return data;
    } on http.ClientException catch (_) {
      throw "No internet connection.";
    } catch (e) {
      throw "An unexpected error occurred.";
    }
  }

  void _updateCity(String city) {
    setState(() {
      cityName = city;
      errorMessage = '';
    });
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'item x');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 154, 202, 228),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 154, 202, 228),
        title: const Text("Weather App",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: SearchWidget(onSearch: _updateCity)),
          Expanded(
            child: FutureBuilder(
              future: getCurrentWeather(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final data = snapshot.data!;
                final currentWeatherData = data['list'][0];
                final currentTemperature = currentWeatherData['main']['temp'];
                final currentSky = currentWeatherData['weather'][0]['main'];

                // Get the current date and time in the desired format
                final now = DateTime.now();
                final currentDate = DateFormat('yyyy-M-d H:m:s').format(now);

                // Show notification with weather details
                showNotification(
                  'Weather Update on $currentDate',
                  'Current temperature in $cityName is ${(currentTemperature - 273.15).toStringAsFixed(1)}°C with $currentSky',
                );

                final currentPressure = currentWeatherData['main']['pressure'];
                final currentWindSpeed = currentWeatherData['wind']['speed'];
                final currentHumidity = currentWeatherData['main']['humidity'];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main card
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        "${(currentTemperature - 273.15).toStringAsFixed(3)} °C",
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(
                                        currentSky == 'Clouds' ||
                                                currentSky == 'Rain'
                                            ? Icons.cloud
                                            : Icons.sunny,
                                        size: 65,
                                      ),
                                      Text(
                                        currentSky,
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Hourly Forecast",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              itemCount: 29,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                final hourlyForeCast = data['list'][index + 1];
                                final hourlySky =
                                    hourlyForeCast['weather'][0]['main'];
                                final time = DateTime.parse(
                                    hourlyForeCast['dt_txt'].toString());
                                return HourlyForeCastItem(
                                  time: DateFormat.j().format(time),
                                  icon: hourlySky == 'Clouds' ||
                                          hourlySky == 'Rain'
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  temperature:
                                      (hourlyForeCast['main']['temp'] - 273.15)
                                          .toStringAsFixed(3),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Additional Information",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Additional_Information(
                                icon: Icons.water_drop,
                                label: "Humidity",
                                value: "${currentHumidity.toString()}%",
                              ),
                              Additional_Information(
                                icon: Icons.air,
                                label: "Wind Speed",
                                value: currentWindSpeed.toString(),
                              ),
                              Additional_Information(
                                icon: Icons.beach_access,
                                label: "Pressure",
                                value: "${currentPressure.toString()} atm",
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Center(
                            child: Text(
                              "© 2024 Amalgsoft Tech Solutions",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
