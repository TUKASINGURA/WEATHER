import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secretdata.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'London';
      final result = await http.get(
        Uri.parse(
            "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey"),
      );
      final data = jsonDecode(result.body);

      if (int.parse(data['cod']) != 200) {
        throw "an Unexpected Error occured";
      }

      // data['list'][0]['main']['temp'];
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Weather App",
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            // This icon is responsible for refreshing the application when placed
            IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
            )
          ],
        ),
        body: FutureBuilder(
          future: getCurrentWeather(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final data = snapshot.data!;
            final currentWeatherData = data['list'][0];

            final currentTemperature = currentWeatherData['main']['temp'];
            final currentSky = currentWeatherData['weather'][0]['main'];
            final currentPresure = currentWeatherData['main']['pressure'];
            final currentWindSpeed = currentWeatherData['wind']['speed'];
            final currentHumidity = currentWeatherData['main']['humidity'];

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // main card
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      "$currentTemperature K",
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      currentSky == 'cloud' ||
                                              currentSky == 'Rain'
                                          ? Icons.cloud
                                          : Icons.sunny,
                                      size: 65,
                                    ),
                                    Text(
                                      currentSky,
                                      style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )),
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
                        itemCount: 14,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final hourlyForeCast = data['list'][index + 1];
                          final hourlysky =
                              data['list'][index + 1]['weather'][0]['main'];
                          final time = DateTime.parse(
                              hourlyForeCast['dt_txt'].toString());
                          return HourlyForeCastItem(
                            //the j format displays the time in 3am or 3pm format whie the hm displays the time in 00:00 format
                            //there are so many other formats that can been chosen according to someones interest in the UI
                            time: DateFormat.j().format(time),
                            icon: hourlysky == 'Clouds' || hourlysky == 'Rain'
                                ? Icons.sunny
                                : Icons.cloud,
                            temperature:
                                hourlyForeCast['main']['temp'].toString(),
                          );
                        },
                      ),
                    ),
                    // SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   child: Row(
                    //     children: [
                    //       for (int i = 0; i < 5; i++)
                    //         HourlyForeCastItem(
                    //           time: data['list'][i + 1]['dt'].toString(),
                    //           icon: data['list'][i + 1]['weather'][0]['main'] ==
                    //                       'Clouds' ||
                    //                   data['list'][i + 1]['weather'][0]
                    //                           ['main'] ==
                    //                       'Rain'
                    //               ? Icons.cloud
                    //               : Icons.sunny,
                    //           temperature: data['list'][i + 1]['main']['temp']
                    //               .toString(),
                    //         ),
                    //     ],
                    //   ),
                    // ),
                    const SizedBox(height: 10),
                    const Text(
                      "Additional Information",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    //additional information
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Additional_Information(
                          icon: Icons.water_drop,
                          label: "Humidity",
                          value: currentHumidity.toString(),
                        ),
                        Additional_Information(
                          icon: Icons.air,
                          label: "Wind speed",
                          value: currentWindSpeed.toString(),
                        ),
                        Additional_Information(
                          icon: Icons.beach_access,
                          label: "Pressure",
                          value: currentPresure.toString(),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Center(
                      child: Text(
                        "© 2024 Almagsoft Tech Solutions",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ));
  }
}
