// ignore_for_file: avoid_print

import 'package:cursova/core/failures/file_failures/cant_access_storage.dart';
import 'package:cursova/core/failures/file_failures/storage_perm_denied.dart';
import 'package:cursova/core/managers/file_picker_manager.dart';
import 'package:cursova/core/managers/file_saver_manager.dart';
import 'package:cursova/core/managers/permission_manager.dart';
import 'package:cursova/core/rsa/managers/rsa_manager.dart';
import 'package:flutter/material.dart';

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
  String? _prime;
  bool _isLoad = false;
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
                  final storagAccessResponse =
                      await PermissionManager().resolveStorageAccess();
                  if (storagAccessResponse != null) {
                    if (storagAccessResponse is CantAccessStorage) {
                      await PermissionManager().requestStorageAccess();
                      return;
                    }
                    if (storagAccessResponse is StoragePermanentlyDenied) {
                      _message = storagAccessResponse.toString();
                      setState(() {});
                    }
                  } else {
                    final fileResponse =
                        await FilePickerManager().pickFileAsBYtes();
                    fileResponse.fold(
                      success: (file) async {
                        final res = await FileSaverManager()
                            .writeToDownloadFolder(file);
                        res.fold(
                          success: (writtenFile) {
                            _message = 'New path: ${writtenFile.path}';
                            setState(() {});
                          },
                          failure: (failure) async {
                            print(failure);
                            setState(() {
                              _message = '$failure';
                            });
                          },
                        );
                      },
                      failure: (failure) {
                        print(failure);
                        setState(() {
                          _message = '$failure';
                        });
                      },
                    );
                  }
                },
                child: const Text('Pick File'),
              ),
              const SizedBox(height: 30),
              if (_message != null) Text(_message!),
              const SizedBox(height: 30),
              ElevatedButton(
                  onPressed: () async {
                    _isLoad = true;
                    setState(() {});
                    await RSAmanager().generateKeys();
                    _isLoad = false;
                    setState(() {});
                  },
                  child: const Text(
                    'Gen prime',
                  )),
              Text(_prime ?? ''),
              if (_isLoad) const CircularProgressIndicator.adaptive()
            ],
          ),
        ],
      ),
    );
  }
}
