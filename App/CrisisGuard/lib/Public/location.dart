
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'dart:io';
// /import 'package:flutter_isolate/flutter_isolate.dart';
void backgroundTask( String s) {
  Timer.periodic(Duration(seconds: 20), (timer) {
    location_fn();
    // Perform your periodic task here
    //print('Background task executed at ${DateTime.now()}');
  });
}
class sapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ShakeDetectionDemo(),
    );
  }
}



class ShakeDetectionDemo extends StatefulWidget {
  @override
  _ShakeDetectionDemoState createState() => _ShakeDetectionDemoState();
}
class location_fn
{
  String lat="0";
  String lon="0";
  Future<String> location()
  async {



    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);


    lat=position.latitude.toString();
    lon=position.longitude.toString();
    return position.latitude.toString()+"#"+position.longitude.toString();

  }
  String loc_send()
  {
    //print("++++++++++++++++++++++");
    //print("++++++++++++++++++++++");
    //print("++++++++++++++++++++++");
    location();
    //print(lat+"#"+lon);
    return lat+"#"+lon;
  }
}
class _ShakeDetectionDemoState extends State<ShakeDetectionDemo> {
  double _accelerometerX = 0.0;
  double _accelerometerY = 0.0;
  double _accelerometerZ = 0.0;
  String checkingstatus = "0";
  String usertype = "0";
  bool _isShaking = false;
  location_fn ob=location_fn();
  // bool _status=true;
  Future<String> checkfn()
  async {
    final sh = await SharedPreferences.getInstance();
    // String lid=sh.getString("lid").toString();
    checkingstatus=sh.getString("lid").toString();
    usertype=sh.getString("type").toString();
    return sh.getString("lid").toString();
  }
  get flutterLocalNotificationsPlugin => null;
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  // FlutterLocalNotificationsPlugin();
  // static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // static const String name = 'Awesome Notifications - Example App';
  // static const Color mainColor = Colors.deepPurple;
  String s="0";
  int i=0;
  @override
  void initState() {


    super.initState();


    accelerometerEvents.listen((AccelerometerEvent event) async {
      // setState(()  async {
      ob.location();
      String lids =checkfn().toString();
//       i+=1;
//       String lids =shh.getString("lid").toString();
//
//       print(lids);
      print("lids======="+lids);
      // if(checkingstatus=="-1")
      // {
      //   dispose();
      // }
      List<String> lll = ob.loc_send().split("#");
      final sh = await SharedPreferences.getInstance();
      sh.setString("lat", lll[0]);
      sh.setString("lon", lll[1]);


      _accelerometerX = event.x;
      _accelerometerY = event.y;
      _accelerometerZ = event.z;
      //print(_accelerometerX);
      //print(_accelerometerY);
      //print(_accelerometerZ);
      //print("====================");

      // Define a threshold for shake detection
      final double shakeThreshold = 70.0;
      print("shakeThreshold");
      print(shakeThreshold);
      // Check if the device is shaking based on accelerometer data
      _isShaking = (_accelerometerX.abs() > shakeThreshold ||
          _accelerometerY.abs() > shakeThreshold ||
          _accelerometerZ.abs() > shakeThreshold);

      print("shakeThreshold");
      print(usertype);
      print(_isShaking);
      print(_accelerometerX.abs().toString()+"======================bbb");
      if (_isShaking && usertype=="user") {
        //print(lll.toString() + "===>");
        //print("*************************************");
        final sh = await SharedPreferences.getInstance();
                    String url = sh.getString("url") ?? "";
                    String lid = sh.getString("lid") ?? "";
        var response = await http.post(
          Uri.parse(url+'User_send_emergency_alert'),
          body: {
            'lat': lll[0],
            'lon': lll[1],
            'lid': lid,
            // "feedback":"Shake Detected"
          },
        );
print("sended================================");
        // showDialog<void>(
        //   context: context,
        //   barrierDismissible: false, // user must tap button!
        //   builder: (BuildContext context) {
        //     return AlertDialog(
        //       title: const Text('Shaking Detected'),
        //       content: const SingleChildScrollView(
        //         child: ListBody(
        //           children: <Widget>[
        //             // Text('This is a alert dialog.'),
        //             Text('Are you sure you want to share your location'),
        //           ],
        //         ),
        //       ),
        //
        //
        //
        //       actions: <Widget>[
        //         TextButton(
        //           child: const Text('Approve'),
        //           onPressed: () async {
        //             final sh = await SharedPreferences.getInstance();
        //             String url = sh.getString("url") ?? "";
        //             String lid = sh.getString("lid") ?? "";
        //
        //             try {
        //               // Log confirmation
        //               print("Sending emergency alert...");
        //
        //               // API call
        //               var response = await http.post(
        //                 Uri.parse('$url/sendemergency'),
        //                 body: {
        //                   'lat': lll[0],
        //                   'lon': lll[1],
        //                   'lid': lid,
        //                   "feedback":"Shake Detected"
        //                 },
        //               );
        //
        //               var jsonData = json.decode(response.body);
        //               String status = jsonData['task']?.toString() ?? "error";
        //
        //               // Log status
        //               print("Status: $status");
        //
        //               if (status == "ok") {
        //                 print("Emergency alert sent successfully!");
        //                 // _sendNotification(); Uncomment if notification logic is implemented
        //               } else {
        //                 print("Failed to send emergency alert.");
        //               }
        //             } catch (e) {
        //               print("Error: $e");
        //             }
        //
        //             // Navigate to the home page
        //             Navigator.pushReplacement(
        //               context,
        //               MaterialPageRoute(builder: (context) => UserHome()),
        //             );
        //           },
        //         ),
        //         TextButton(
        //           child: const Text('Reject'),
        //           onPressed: () {
        //             // Directly navigate to the home page
        //             Navigator.pushReplacement(
        //               context,
        //               MaterialPageRoute(builder: (context) => UserHome()),
        //             );
        //           },
        //         ),
        //       ],
        //
        //     );
        //   },
        // );
      }









      if(i==0) {
        i=i+1;

        String url = sh.getString("url").toString();
        String lid = sh.getString("lid").toString();

        print("okkkkkkkkkkkkkkkkk");
        var data = await http.post(
            Uri.parse(url + "updatelocation"),
            body: {'lat': lll[0],
              "lon": lll[1],
              "lid": lid
            });

        var jasondata = json.decode(data.body);
        String status = jasondata['task'].toString();
        print(status + "+++++++++++++++====++----");
        print(lll.toString() + "===>");
        if (status == "ok") {
          // _sendNotification();
        }
        else {
          print("na");
        }

      }
      print(i);
      i=i+1;
      if(i==1000)
      {
        i=0;
      }

    });
  }



  // void startBackgroundTask() async {
  //   final isolate = await FlutterIsolate.spawn(backgroundTask,"");
  // }
  // // Start the background task
  // Future<void> _startBackgroundTask() async {
  //
  //   // final bool isRunning =  await FlutterBackground.isBackgroundExecutionActive;
  //   //
  //   // if (!isRunning) {
  //   //   await FlutterBackground.initialize(androidConfig: AndroidConfig(
  //   //     notificationChannelName: 'Background Tasks',
  //   //     notificationTitle: 'Background Task',
  //   //     notificationText: 'Running in the background',
  //   //     notificationImportance: AndroidNotificationImportance.Default,
  //   //   ));
  //   //
  //   //   final taskId = await FlutterBackground.executeTask(
  //   //     task: (taskId) async {
  //   //       // Periodically make HTTP requests in the background
  //   //       Timer.periodic(Duration(seconds: 10), (timer) async {
  //   //         await _fetchData();
  //   //       });
  //   //     },
  //   //     // Set the interval to trigger the task
  //   //     interval: Duration(seconds: 10),
  //   //     // Run the task immediately
  //   //     executeOnBoot: true,
  //   //   );
  //   // }
  // }

  Future<void> _fetchData() async {
    try {
      // final response = await http.get(Uri.parse(apiUrl));
      //
      // if (response.statusCode == 200) {
      //   // Handle the response data here
      //   //print('Response data: ${response.body}');
      // } else {
      //   // Handle errors
      //   //print('Error: ${response.statusCode}');
      // }
      //print("fetch data");
    } catch (e) {
      // Handle network or other errors
      //print('Error: $e');
    }
  }
  // Future<void> _sendNotification() async {
  //   await AwesomeNotifications().createNotification(
  //     content: NotificationContent(
  //       id: 0,
  //       channelKey: 'basic_channel',
  //       title: 'Awesome Notification',
  //       body: 'This is an awesome notification!',
  //     ),
  //   );
  // }


  @override
  void dispose() {
    super.dispose();

    // Cancel the accelerometer subscription when the widget is disposed
    accelerometerEvents.drain();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shake Detection Demo'),
      ),
      body:
      Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Accelerometer Data'),
            Text('X: $_accelerometerX'),
            Text('Y: $_accelerometerY'),
            Text('Z: $_accelerometerZ'),

            SizedBox(height: 20),
            Text(
              _isShaking ? 'Device is shaking!' : 'Device is not shaking.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isShaking ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );

  }
}
