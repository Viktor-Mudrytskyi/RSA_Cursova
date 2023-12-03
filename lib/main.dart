import 'dart:io';

import 'package:cursova/core/managers/file_picker_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _message;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: CustomScrollView(
        slivers: [
          SliverList.list(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final fileResponse =
                      await FilePickerManager().pickFileAsBYtes();
                  fileResponse.fold(
                    success: (data) async {
                      print('Old path: ${data.path}');
                      final KeyPair result = await RSA.generate(2048);
                      // final file = File('D:/Work/3-1/Crypto/Cursova/test.txt');
                      final t = await RSA.encryptOAEPBytes(
                        data.bytes!,
                        'test',
                        Hash.SHA256,
                        result.publicKey,
                      );

                      final Uri uriPath = Uri.parse(data.path!);
                      final segments = uriPath.pathSegments.toList();
                      segments.removeLast();
                      print(await getDownloadsDirectory());

                      final String newPath =
                          '${segments.join('/')}/encrypt.txt';

                      print('New path: $newPath');

                      final fileEncrypted = File(newPath);
                      fileEncrypted.writeAsBytesSync(t);
                      print('Successful crypt');
                      setState(() {
                        _message =
                            'New path: $newPath \nSuccessful crypt\n Old path: ${data.path}';
                      });
                    },
                    failure: (failure) {
                      print(failure);
                      setState(() {
                        _message = '$failure';
                      });
                    },
                  );
                },
                child: const Text('Pick File'),
              ),
              const SizedBox(height: 30),
              if (_message != null) Text(_message!),
            ],
          ),
        ],
      ),
    );
  }
}
