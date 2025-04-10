import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('Background message: ${message.notification!.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(fbMessaging());
}

class fbMessaging extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic("messaging");

    messaging.getToken().then((value) {
      print("FCM Token: $value");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("Message received");
      print("Notification: ${event.notification!.body}");

      _handleNotification(event);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
    });
  }

  void _handleNotification(RemoteMessage event) {
    String type = event.data['notification_type'] ?? 'regular';

    if (type == 'important') {
      _showImportantDialog(event.notification!.body!);
    } else {
      _showRegularDialog(event.notification!.body!);
    }
  }

  void _showImportantDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Important Notification", style: TextStyle(color: Colors.red)),
          content: Text(message),
          backgroundColor: Colors.red[50],
          actions: [
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showRegularDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Regular Notification", style: TextStyle(color: Colors.blue)),
          content: Text(message),
          backgroundColor: Colors.blue[50],
          actions: [
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title!)),
      body: Center(child: Text("Firebase Message")),
    );
  }
}
