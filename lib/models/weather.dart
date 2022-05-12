class Weather {
  final double temp;
  final int weatherCode;
  final double windspeed;
  final List hourlyTime;
  final List hourlyTemp;
  final List hourlyCode;

  Weather(
      {required this.temp,
      required this.weatherCode,
      required this.windspeed,
      required this.hourlyTime,
      required this.hourlyTemp,
      required this.hourlyCode});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
        temp: json['current_weather']['temperature'].toDouble(),
        weatherCode: json["current_weather"]["weathercode"],
        windspeed: json["current_weather"]["windspeed"],
        hourlyTime: json["hourly"]["time"],
        hourlyTemp: json["hourly"]["temperature_2m"],
        hourlyCode: json["hourly"]["weathercode"]);
  }
}
