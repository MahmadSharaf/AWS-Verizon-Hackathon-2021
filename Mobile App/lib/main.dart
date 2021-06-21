import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Near-Wild Safety'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;
  late String token;
  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      print(value);
      token = value!;
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("message recieved");
      final notification = json.decode(message.data['default']);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Wild Animal Alert"),
              content: Column(children: [
                Text(notification['body']),
                Image.network(notification['imageUrl'])
              ]),
              // content: Text(event.notification!.body!),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  int counter = 0;
  List<String> strings = ["Stream Stopped", "Streaming"];
  String displayedString = "Start Stream";
  final _formKey = GlobalKey<FormState>();
  TextEditingController cameraUrl = new TextEditingController();
  bool viewVisible = true;

  void onPressed() {
    setState(() {
      if (counter == 0) {
        hideWidget();
        print(startStream(token, cameraUrl.text, Platform.operatingSystem));
        displayedString = "Streaming";
        counter = 1;
      } else {
        showWidget();
        print(stopStream());
        displayedString = "Stream Stopped";
        counter = 0;
      }
      // displayedString = strings[counter];
      // counter = counter < 1 ? counter + 1 : 0;
    });
  }

  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  void showWidget() {
    setState(() {
      viewVisible = true;
    });
  }

  void hideWidget() {
    setState(() {
      viewVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
            child: new Container(
                padding: const EdgeInsets.all(30.0),
                color: Colors.white,
                child: new Form(
                  key: _formKey,
                  child: new Center(
                      child: new Column(children: [
                    new Padding(padding: EdgeInsets.only(top: 140.0)),
                    new Text(displayedString,
                        style: new TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold)),
                    new Padding(padding: EdgeInsets.only(top: 50.0)),
                    Visibility(
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible: viewVisible,
                        child: new TextFormField(
                          controller: cameraUrl,
                          decoration: new InputDecoration(
                            labelText: "Enter IP Camera URL",
                            fillColor: Colors.white,
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                              borderSide: new BorderSide(),
                            ),
                            //fillColor: Colors.green
                          ),
                          validator: (val) {
                            if (val!.length == 0) {
                              return "URL cannot be empty";
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.url,
                          style: new TextStyle(
                            fontFamily: "Poppins",
                          ),
                        )),
                    new Padding(padding: new EdgeInsets.all(10.0)),
                    new ElevatedButton(
                      child: new Text("Click me!",
                          style: new TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              fontSize: 20.0)),
                      // color: Colors.red,
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          onPressed();
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Sending Request')));
                        }
                      },
                    )
                  ])),
                ))));
  }
}

Future<String> startStream([token = '', String url = '', platform]) async {
  final response = await http.get(Uri.parse(
      'https://jm7eey7i2m.execute-api.us-east-1.amazonaws.com/streamTrigger?stream=start&token=' +
          token +
          '&cameraUrl=' +
          url +
          '&platform=' +
          platform));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return response.body;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to start the stream');
  }
}

Future<String> stopStream() async {
  final response = await http.get(Uri.parse(
      'https://jm7eey7i2m.execute-api.us-east-1.amazonaws.com/streamTrigger?stream=stop'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return response.body;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to start the stream');
  }
}
