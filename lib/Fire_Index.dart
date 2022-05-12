import 'dart:ui';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'models/weather.dart';

class FireIndex extends StatefulWidget {
  const FireIndex({Key? key}) : super(key: key);

  @override
  State<FireIndex> createState() => _FireIndexState();
}

class _FireIndexState extends State<FireIndex> {
  Location location = Location();
  bool searching = true;

  dynamic uploadLocation() async {
    LocationData position = await location.getLocation();
    dynamic res = [position.latitude, position.longitude];
    return res;
  }
 Widget transformer() {
    if (!searching) {
      return FutureBuilder<dynamic>(
        future: uploadLocation(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder<Fire_Index>(
                future: getFireIndex(lat, lon),
                builder: (context, s) {
                  if (s.hasData) {
                    var fi = s.data;
                    return weatherBox(fi!);
                  } else {
                    print(s.data);
                    print("sdsadaas");
                    return const CircularProgressIndicator();
                  }
                });
 
    } else {
      Widget searchFireIndex(lat,lon){
      return FutureBuilder<Fire_Index>(
          future: getFireIndex(lat, lon),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print("YES");
              var _fi = snapshot.data;
              return weatherBox(_fi!);
            } else {
              print("2222222");
              return CircularProgressIndicator();
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: Text('Fire Index'),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Center(child: transformer),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/example');
                    },
                    child: Text("  Forecast  ")),
              ),
            ]),
          ],
        ));
  }
}

IndexCalculation(Fire_Index _fireIndex) {
  double temp = _fireIndex.temp;
  double windspeed = _fireIndex.windspeed;
  int humidity = _fireIndex.humidity;
  int precipitation_days = _fireIndex.precipitation_days;
  String fireIndex;

  if (temperature >= 30) {
    return fireIndex = 'assets/5.PNG';
  } else if (temperature >= 20 && temperature < 30) {
    return fireIndex = 'assets/4.PNG';
  } else if (temperature >= 15 && temperature < 20) {
    fireIndex = 'assets/3.PNG';
  } else if (temperature >= 5 && temperature < 15) {
    fireIndex = 'assets/2.PNG';
  } else if (temperature < 5) {
    fireIndex = 'assets/1.PNG';
  }
}

Widget weatherBox(Fire_Index _fireIndex) {
  String fireIndex = IndexCalculation(_fireIndex);
  print(fireIndex);
  return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
    Container(child: Image(image: AssetImage('$fireIndex'))),
    Container(
        margin: const EdgeInsets.all(20.0),
        child: Text(
          "${_fireIndex.temp}°C",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        )),
    Container(
        margin: const EdgeInsets.all(10.0),
        child: Text(
          "${_fireIndex.windspeed}km/h wind speed",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        )),
    Container(
        margin: const EdgeInsets.all(10.0),
        child: Text(
          "${_fireIndex.humidity}% Humidity",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        )),
    Container(
        margin: const EdgeInsets.all(10.0),
        child: Text(
          "${_fireIndex.precipitation_days}h of precipitation yesterday",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        )),
    Container(
        margin: const EdgeInsets.all(10.0),
        child: Text(
          "${_fireIndex.wind_direction}° wind direction",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        )),
  ]);
}

Future<Fire_Index> getFireIndex(lat, lon) async {
  Fire_Index _fi;
  final url = Uri.parse(
      "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,weathercode");
  final res = await http.get(url);
  if (res.statusCode == 200) {
    print("SUCCESS");
    print(jsonDecode(res.body));
    _fi = Fire_Index.fromJson(jsonDecode(res.body));
  } else {
    print("ERROR");
    throw Exception("failed");
  }
  return _fi;
}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Future<Widget>>('transformer', transformer));
  }
}
