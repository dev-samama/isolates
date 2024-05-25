import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _complexComputation() async {
    int result = 0;
    for (int i = 0; i < 1000000000; i++) {
      result += i;
      if (result % 100 == 0) {
        debugPrint('running');
      }
    }
    debugPrint(result.toString());
  }

  Future<void> _complexComputationWithIsolate() async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_complexComputationForIsolate, receivePort.sendPort);
    final result = await receivePort.first;
    debugPrint(result.toString());
  }

  static void _complexComputationForIsolate(SendPort sendPort) {
    int result = 0;
    for (int i = 0; i < 1000000000; i++) {
      result += i;
    }
    if (result % 1000000 == 0) {
      debugPrint('running');
    }
    sendPort.send(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lime,
        title: const Text('Isolates 👨🏻‍💻'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ScaleTransition(
              scale: _animation,
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.lime,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 50),
            OutlinedButton(
              onPressed: _complexComputationWithIsolate,
              child: const Text(
                'Run with Isolate, Sperate THREAD ❤️',
                style: TextStyle(color: Colors.green),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            OutlinedButton(
              onPressed: _complexComputation,
              child: const Text(
                'Running on Main Thread, Without ISOLATE 🤢',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
