import 'package:first_module/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:second_module/main.dart';
import 'package:third_module/core/logger/app_logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Third Module',
      // Define routes here
      routes: {
        '/third_module': (context) => const ThirdModuleScreen(),
        '/first_module': (context) => const FirstModuleScreen(),
        '/second_module': (context) => const SecondModuleScreen(),
      },
      initialRoute: '/third_module',
    );
  }
}

class ThirdModuleScreen extends StatefulWidget {
  const ThirdModuleScreen({super.key});

  @override
  _ThirdModuleScreenState createState() => _ThirdModuleScreenState();
}

class _ThirdModuleScreenState extends State<ThirdModuleScreen> {
  static const platformRoute = MethodChannel('com.example.route');
  static const platformMap = MethodChannel('com.example.yourapp/map');

  Map<String, dynamic>? receivedMap;

  @override
  void initState() {
    super.initState();

    platformRoute.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'navigateTo') {
        final String routeName = call.arguments;
        _navigateToRoute(routeName);
      }
    });

    platformMap.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'sendMap') {
        setState(() {
          receivedMap = Map<String, dynamic>.from(call.arguments);
        });
      }
    });

    _retrieveMapData();
  }

  void _navigateToRoute(String routeName) {
    if (routeName == 'first_module') {
      Navigator.pushNamed(context, '/first_module', arguments: true); // Pass argument
    } else if (routeName == 'second_module') {
      Navigator.pushNamed(context, '/second_module', arguments: true); // Pass argument
    }
  }

  Future<void> _retrieveMapData() async {
    try {
      final Map<dynamic, dynamic> result = await platformMap.invokeMethod('sendMap');
      if (result != null) {
        setState(() {
          receivedMap = Map<String, dynamic>.from(result);
        });
      }
    } on PlatformException catch (e) {
      print("Failed to receive map data: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Third Module')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              AppLogger.d("This is a debug message");
              Navigator.pushNamed(context, '/first_module', arguments: false); // Navigated from third module
            },
            child: const Text('Go to First Module'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/second_module', arguments: false); // Navigated from third module
            },
            child: const Text('Go to Second Module'),
          ),
          ElevatedButton(
            onPressed: () {
              platformRoute.invokeMethod('getRoute', "On First Button Click");
              SystemNavigator.pop();
            },
            child: const Text('Finish'),
          ),
          const SizedBox(height: 20),
          Text('RECEIVED DATA: ${receivedMap?['name']}'),
          const SizedBox(height: 20),
          receivedMap == null
              ? const CircularProgressIndicator()
              : Text('Received Map: $receivedMap'),
        ],
      ),
    );
  }
}




