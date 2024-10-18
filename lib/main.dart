import 'dart:io';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:first_module/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:second_module/main.dart';
import 'package:third_module/core/logger/app_logger.dart';
import 'package:third_module/file_service.dart';

import 'ui/fab_bottomsheet.dart';

Future<void> main() async {
  runApp(const MyApp());
}

Future<void> configureAmplify() async {
  final authPlugin = AmplifyAuthCognito();
  final storagePlugin = AmplifyStorageS3();

  try {
    await Amplify.addPlugins([authPlugin, storagePlugin]);

    await Amplify.configure('''
    {
      "auth": {
        "plugins": {
          "awsCognitoAuthPlugin": {
            "CognitoUserPool": {
              "Default": {
                "PoolId": "*********",
                "AppClientId": "***********",
                "Region": "********"
              }
            },
            "IdentityManager": {
              "Default": {}
            },
            "CredentialsProvider": {
              "CognitoIdentity": {
                "Default": {
                  "PoolId": "****************",
                  "Region": "****************"
                }
              }
            }
          }
        }
      },
      "storage": {
        "plugins": {
          "awsS3StoragePlugin": {
            "bucket": "************",
            "region": "***********"
          }
        }
      }
    }
    ''');

    AppLogger.d('Amplify configured successfully');
  } catch (e) {
    AppLogger.d('Error configuring Amplify: $e');
  }
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
          ElevatedButton(
            onPressed: () {
              const platform = MethodChannel('com.example/openBottomSheet');
              platform.invokeMethod('open', {'message': "Open"});
            },
            child: const Text('Open Fittr BottomSheet'),
          ),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: false,
                builder: (context) => const BottomSheetContent(),
              );
            },
            child: const Text('Open BottomSheet'),
          ),
          ElevatedButton(
            onPressed: () async {
              FileService fileService = FileService();
              String? content = await fileService.readFileFromAndroid('example.txt');
              AppLogger.d("Content from Android: $content");
            },
            child: const Text('Read File'),
          ),
          ElevatedButton(
            onPressed: () async {
              const platform = MethodChannel('file_channel');
              FileService fileService = FileService();
              fileService.writeFileInFlutter();
              platform.invokeMethod("writeFile", "flutter.txt");
              AppLogger.d("Write from flutter");
            },
            child: const Text('Write File'),
          ),
          ElevatedButton(
            onPressed: () async {
              WidgetsFlutterBinding.ensureInitialized();
              await configureAmplify();
              uploadVideo(); 
            },
            child: const Text('Upload Video'),
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

Future<void> uploadVideo() async {
  // Open file picker to select a video
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);

  if (result != null) {
    File videoFile = File(result.files.single.path!);

    try {
      // Wrap the file in an AWSFile object
      final AWSFile awsFile = AWSFile.fromPath(videoFile.path);

      // Perform the upload using StorageUploadFileOperation
      final StorageUploadFileOperation<StorageUploadFileRequest, StorageUploadFileResult<StorageItem>> uploadOperation =
          Amplify.Storage.uploadFile(
        localFile: awsFile,
        path: StoragePath.fromString('uploads/${DateTime.now().millisecondsSinceEpoch}.mp4'),
        onProgress: (progress) {
          AppLogger.d('Progress: ${progress.fractionCompleted}');
        },
      );

      // Await the result
      final StorageUploadFileResult<StorageItem> uploadResult = await uploadOperation.result;

      AppLogger.d('Video uploaded: ${uploadResult.uploadedItem.path}');
      // You can now retrieve the uploaded video URL
      final Object url = await getVideoUrl(uploadResult.uploadedItem!.path);
      AppLogger.d('Video URL: $url');
    } catch (e) {
      AppLogger.d('Upload failed: $e');
    }
  }
}

Future<Object> getVideoUrl(String key) async {
  try {
    // Get the URL of the uploaded video
    final StorageGetUrlOperation getUrlOperation = Amplify.Storage.getUrl(path: StoragePath.fromString(key));
    final StorageGetUrlResult result = await getUrlOperation.result;
    return result.url;
  } catch (e) {
    AppLogger.d('Error getting video URL: $e');
    return '';
  }
}

