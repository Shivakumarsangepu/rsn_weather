import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weather_report/common_widgets/core.dart';
import 'package:weather_report/models/weather_report_response.dart';
import '../common_widgets/shimmer.dart';
import '../providers/weather_provider.dart';
import 'package:intl/intl.dart';




class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {


  String? sunRiseTime;
  String? sunSetTime ;


  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false).fetchWeather();
    });

  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.blue[50]),
        child: buildUI(context, weatherProvider),
      ),
    );
  }

  Widget buildUI(BuildContext context, WeatherProvider weatherProvider) {
    if (weatherProvider.weather != null) {
      changeTimeZone(
        weatherProvider.weather!.sys!.sunrise!,
        weatherProvider.weather!.sys!.sunset!,
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          weatherProvider.fetchWeather();
        },
        child: Stack(
          children: <Widget>[
            Container(
              color: Colors.blue[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                 VerticalSpace(height: deviceHeight(context)*0.01,),
                  Container(
                    color:  Colors.blue[50],
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: weatherProvider.weather!=null &&  weatherProvider.weather!.weather!=null  && weatherProvider.weather!.weather!.isNotEmpty
                        ? appBarWidget(weatherProvider.weather!.weather![0])
                        :Container(),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 16),
                      child: Text(DateFormat('d MMM yyyy').format(DateTime.now()),style: const TextStyle(color: Colors.orange,fontWeight: FontWeight.bold,fontSize: 16),)),
                  const VerticalSpace(),
                  Expanded(
                    child: Container(
                        color: Colors.blue[50],
                      child: SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (weatherProvider.weather != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    temperatureWidget(
                                        weatherProvider.weather!=null &&  weatherProvider.weather!.name!=null ? weatherProvider.weather!.name! : '',
                                        weatherProvider.weather!=null &&  weatherProvider.weather!.main!=null  &&   weatherProvider.weather!.main!.temp!=null ?  weatherProvider.weather!.main!.temp! : 0,
                                        weatherProvider.weather!=null &&  weatherProvider.weather!.weather!=null  &&  weatherProvider.weather!.weather![0].description!=null ?  weatherProvider.weather!.weather![0].description! : ''
                                    ),
                                    const VerticalSpace(height: 20,),
                                    sunTimingsWidget(),
                                    const VerticalSpace(height: 20,),
                                    weatherProvider.weather!=null &&  weatherProvider.weather!.main!=null
                                        ?  atmosphereDetailsWidget(weatherProvider.weather!.main!)
                                        : Container(),
                                    const VerticalSpace(),
                                    weatherProvider.weather!=null &&  weatherProvider.weather!.wind!=null
                                        ?  windWidget(weatherProvider.weather!.wind!)
                                        : Container(),
                                    const VerticalSpace(height: 20,),
                                  ],
                                ),
                              if (weatherProvider.weather == null && !weatherProvider.isLoading)
                                const Center(
                                  child: Text(
                                    "No weather data available.",
                                    style: TextStyle(fontSize: 16, color: Colors.red),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (weatherProvider.isLoading)
              const WeatherShimmer()
          ],
        ),
      ),
    );
  }


//Widgets
  Widget appBarWidget(WeatherElement weather){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Weather",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                getCloudImage(weather.icon!),
                Text(
                  "${weather.main}",
                  style: const TextStyle(fontSize: 16, fontWeight:FontWeight.w600),
                ),
              ],
            ),
            Text(
              "INDIA",
              style: TextStyle(fontSize: 16, fontWeight:FontWeight.w600,color: Colors.deepOrange[400]),
            ),
          ],
        ),

      ],
    );
  }

Widget temperatureWidget(String city,num temp, String desc){
    return Container(
      alignment: Alignment.centerRight,
      height: deviceHeight(context)/5,
      width: deviceWidth(context),
      decoration: BoxDecoration(
        image: const DecorationImage(image: AssetImage('assets/weather_bg.png'),fit: BoxFit.cover),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 0.5),
            ),
          ],
        borderRadius: BorderRadius.circular(10)
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(city,style: TextStyle(fontSize: 22,fontWeight: FontWeight.w400,color: HexColor('8BC2ED')),),
            Text('${temp.toInt()}°C',style: TextStyle(fontSize: 49,fontWeight: FontWeight.w400,color: HexColor('8BC2ED')),),
            Text(desc,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400,color: HexColor('8BC2ED')),),
          ],
        ),
      ),
    );
}

Widget sunTimingsWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          height:deviceHeight(context)/8,
          padding:const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 0.5),
              ),
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/sunrise.png',height: 50,),
              Text('$sunRiseTime',style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
            ],
          ),
        ),
        Container(
          height:deviceHeight(context)/8,
          padding:const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 0.5),
              ),
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/sunset.png',height: 50,),
              Text('$sunSetTime',style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
            ],
          ),
        ),
      ],
    );
}

Widget atmosphereDetailsWidget(Main main){
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 0.5),
                ),
              ],
              borderRadius: BorderRadius.circular(8)
          ),
          padding:const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Humidity',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color:Colors.black54),),
              Text('${main.humidity}%',style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.blue[300])),
            ],
          ),
        ),
        const VerticalSpace(height: 10,),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 0.5),
                ),
              ],
              borderRadius: BorderRadius.circular(8)
          ),
          padding:const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pressure',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.black54),),
              Text('${main.pressure} hPa',style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.blue[300])),
            ],
          ),
        ),
        const VerticalSpace(height: 10,),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 0.5),
                ),
              ],
              borderRadius: BorderRadius.circular(8)
          ),
          padding:const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Min temp',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.black54),),
              Text('${main.tempMin}°C',style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.blue[300])),
            ],
          ),
        ),
        const VerticalSpace(height: 10,),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 0.5),
                ),
              ],
              borderRadius: BorderRadius.circular(8)
          ),
          padding:const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Max temp',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.black54),),
              Text('${main.tempMax}°C',style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.blue[300])),
            ],
          ),
        ),
        const VerticalSpace(height: 10,),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 0.5),
                ),
              ],
              borderRadius: BorderRadius.circular(8)
          ),
          padding:const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Feels like',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.black54),),
              Text('${main.feelsLike}°C',style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.blue[300])),
            ],
          ),
        ),
        const VerticalSpace(height: 10,),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 0.5),
                ),
              ],
              borderRadius: BorderRadius.circular(8)
          ),
          padding:const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Temperature',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color:Colors.black54),),
              Text('${main.temp}°C',style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.blue[300])),
            ],
          ),
        ),
        const VerticalSpace(height: 10,),

      ],
    );
}

Widget windWidget(Wind wind){
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 4,
            offset: const Offset(0, 0.5),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/wind.png',width: 30,),
                const Text('Wind speed',style: TextStyle(color: Colors.lightBlueAccent,),),
                Text('${wind.speed}m/s',style: const TextStyle(color: Colors.lightBlueAccent,fontWeight: FontWeight.bold),),
              ],
            ),
            Column(
              children: [
                Image.asset('assets/wind_direction.png',width: 30,),
                const Text('Wind direction',style: TextStyle(color: Colors.blueAccent,),),
                Text('${wind.deg}°',style: const TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.bold),),
              ],
            ),
          ],
        ),
      ),
    );
}


// Functionality

void changeTimeZone(int sunRise, int sunSet){
  DateTime sunriseDateTime = DateTime.fromMillisecondsSinceEpoch(sunRise * 1000, isUtc: true).toLocal();
  DateTime sunsetDateTime = DateTime.fromMillisecondsSinceEpoch(sunSet * 1000, isUtc: true).toLocal();
  sunRiseTime = DateFormat('hh:mm a').format(sunriseDateTime);
  sunSetTime = DateFormat('hh:mm a').format(sunsetDateTime);
  setState(() {

  });
}

Widget getCloudImage(String id){
    String image= 'assets/01d.png';
    if(id == '01d'){
      image = 'assets/01d.png';
    }else if(id == '01n'){
      image = 'assets/01n.png';
    }else if(id == '02d'){
      image = 'assets/02d.png';
    }else if(id == '02n'){
      image = 'assets/02n.png';
    }else if(id == '03d' || id == '03n'){
      image = 'assets/03d.png';
    }else if(id == '04d' || id == '04n'){
      image = 'assets/04d.png';
    }else if(id == '09d' || id == '09n'){
      image = 'assets/09d.png';
    }else if(id == '10d'){
      image = 'assets/10d.png';
    }else if(id == '10n'){
      image = 'assets/10n.png';
    }else if(id == '11d' || id == '11n'){
      image = 'assets/11d.png';
    }else if(id == '13d' || id == '13n'){
      image = 'assets/13d.png';
    }else if(id == '50d' || id == '50d'){
      image = 'assets/50d.png';
    }else{
      image = 'assets/01n.png';
    }
    return Image.asset(image,height: 40,);
}


}
