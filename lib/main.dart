import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ar_flutter_plugin_2/ar_flutter_plugin.dart';

import 'examples/objectgesturesexample.dart';
import 'examples/screenshotexample.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  static const String _title = 'AR Plugin Demo';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion = 'No Idea';
    // Platform messages may fail, so we use a try/catch PlatformException.
    //try {
    //platformVersion = await ArFlutterPlugin.platformVersion;
    //} on PlatformException {
    //platformVersion = 'Failed to get platform version.';
    //}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ObjectGesturesWidget());
  }
}

class ExampleList extends StatelessWidget {
  const ExampleList({super.key});

  @override
  Widget build(BuildContext context) {
    final examples = [
      Example(
        'Object Transformation Gestures',
        'Rotate and Pan Objects',
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ObjectGesturesWidget()),
        ),
      ),
      Example(
        'Screenshots',
        'Place 3D objects on planes and take screenshots',
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ScreenshotWidget()),
        ),
      ),
    ];
    return ListView(
      children:
          examples.map((example) => ExampleCard(example: example)).toList(),
    );
  }
}

class ExampleCard extends StatelessWidget {
  const ExampleCard({super.key, required this.example});
  final Example example;

  @override
  build(BuildContext context) {
    return Card(
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          example.onTap();
        },
        child: ListTile(
          title: Text(example.name),
          subtitle: Text(example.description),
        ),
      ),
    );
  }
}

class Example {
  const Example(this.name, this.description, this.onTap);
  final String name;
  final String description;
  final Function onTap;
}
