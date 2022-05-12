import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'models/weather.dart';

class MyHttpOverrides extends HttpOverrides { // 
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const Forecast());
}

class Forecast extends StatefulWidget {
  const Forecast({Key? key}) : super(key: key);

  @override
  State<Forecast> createState() => _ForecastState();
}

class _ForecastState extends State<Forecast> {
  final _controller = TextEditingController();
  Location location = Location();
  bool searching = false;

  dynamic uploadLocation() async {
    LocationData position = await location.getLocation();
    dynamic res = [position.latitude, position.longitude];
    return res;
  }

  Widget personalWeather() {
    return FutureBuilder<dynamic>(
      future: uploadLocation(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var lat = snapshot.data[0];
          var lon = snapshot.data[1];
          return FutureBuilder<Weather>(
              future: getCurrentWeather(lat, lon),
              builder: (context, s) {
                if (s.hasData) {
                  var w = s.data;
                  return weatherBox(w!);
                } else {
                  return const CircularProgressIndicator();
                }
              });
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget searchedWeather(lat, lon) {
    return FutureBuilder<Weather>(
        future: getCurrentWeather(lat, lon),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var _w = snapshot.data;
            return weatherBox(_w!);
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  Widget transformer() {
    if (!searching) {
      return personalWeather();
    } else {
      var input = _controller.text.split(" ");
      var lat = input[0];
      var lon = input[1];
      return searchedWeather(lat, lon);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Forecast"),
          backgroundColor: const Color(0xFF6200EE),
        ),
        body: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: TextField(
                  controller: _controller,
                  cursorColor: Theme.of(context).cursorColor,
                  decoration: InputDecoration(
                      labelText: 'Latitude and Longitude',
                      labelStyle: const TextStyle(
                        color: Color(0xFF6200EE),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6200EE)),
                      ),
                      suffixIcon: IconButton(
                          onPressed: () => {
                                searching = true,
                                FocusScope.of(context)
                                    .requestFocus(FocusNode()),
                                setState(() => {})
                              },
                          icon: Icon(Icons.search))),
                ),
              ),
            ),
            FutureBuilder<dynamic>(
                future: uploadLocation(),
                builder: (context, pos) {
                  if (pos.hasData) {
                    var lat = pos.data[0];
                    var lon = pos.data[1];
                    return Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text("Lat: ${lat}"), Text("Lon: ${lon}")]),
                    );
                  } else {
                    return Container();
                  }
                }),
            Center(child: transformer())
          ],
        ),
      ),
    );
  }
}

Widget weatherBox(Weather _weather) {
  return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
    Container(
        margin: const EdgeInsets.all(10.0),
        child: Text(
          "${_weather.temp}°C",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 55),
        )),
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            margin: const EdgeInsets.all(10.0),
            child: Icon(translateIcon(_weather.weatherCode))),
        Container(
          child: Text("Wind Speed: ${_weather.windspeed}km/h"),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < 9; i++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                        child: Icon(translateIcon(_weather.hourlyCode[i]))),
                    Container(
                        child: Text("${_weather.hourlyTime[i].substring(11)}")),
                    Container(child: Text("${_weather.hourlyTemp[i]}°C")),
                  ],
                )
            ],
          ),
        )
      ],
    ),
  ]);
}

Future<Weather> getCurrentWeather(lat, lon) async { // method to  get the url from the api 
  Weather _w;
  final url = Uri.parse(
      "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,weathercode");
  final res = await http.get(url);
  if (res.statusCode == 200) {
    _w = Weather.fromJson(jsonDecode(res.body));
  } else {
    throw Exception("failed");
  }
  return _w;
}

IconData translateIcon(int n) {
  dynamic dic = {
    0: Icons.wb_sunny,
    1: Icons.cloud,
    2: Icons.cloud,
    3: Icons.cloud,
  };
  return dic[n];
}


//https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&hourly=temperature_2m,weathercode



/*

Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                      child: Icon(translateIcon(_weather.hourlyCode[0]))),
                ),
                Container(
                    child: Text("${_weather.hourlyTime[0].substring(11)}")),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(child: Text("${_weather.hourlyTemp[0]}°C")),
                ),
              ],
            ),*/