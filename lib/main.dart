import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() async {
  runApp(new MaterialApp(home: new AwesomeButton()));
}

class AwesomeButton extends StatefulWidget {
  AwesomeButtonState createState() => new AwesomeButtonState();
}

class AwesomeButtonState extends State<AwesomeButton> {
  int counter = 0;
  List<String> strings = ["Stream Stopped", "Streaming"];
  String displayedString = "Start Stream";
  void onPressed() {
    setState(() {
      if (counter == 0) {
        print(startStream());
        displayedString = "Streaming";
        counter = 1;
      } else {
        print(stopStream());
        displayedString = "Stream Stopped";
        counter = 0;
      }
      // displayedString = strings[counter];
      // counter = counter < 1 ? counter + 1 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("Bear_Detection"),
            backgroundColor: Colors.blueAccent),
        body: new Container(
            child: new Center(
                child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
              new Text(displayedString,
                  style: new TextStyle(
                      fontSize: 30.0, fontWeight: FontWeight.bold)),
              new Padding(padding: new EdgeInsets.all(10.0)),
              new ElevatedButton(
                child: new Text("Click me!",
                    style: new TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontSize: 20.0)),
                // color: Colors.red,
                onPressed: onPressed,
              )
            ]))));
  }
}

Future<String> startStream() async {
  final response = await http.get(Uri.parse(
      'https://jm7eey7i2m.execute-api.us-east-1.amazonaws.com/streamTrigger?stream=start'));

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
