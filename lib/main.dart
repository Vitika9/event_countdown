import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'EventPage.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var initialixationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initialixationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: 
      (int id,String title,String body,String payload) async{}
      );
  var initializationSettings = InitializationSettings(
      initialixationSettingsAndroid, initialixationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: (String payload) async{
    if(payload!=null){
      debugPrint('notification payload '+payload);
    }
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'My app',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: EventPage());
  }
}
