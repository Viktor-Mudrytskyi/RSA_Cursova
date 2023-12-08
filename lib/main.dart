// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cursova/core/failures/base_failure.dart';
import 'package:cursova/core/managers/file_picker_manager.dart';
import 'package:cursova/core/managers/file_saver_manager.dart';
import 'package:cursova/core/managers/permission_manager.dart';
import 'package:cursova/core/rsa/managers/rsa_manager.dart';
import 'package:cursova/core/rsa/rsa_key_pair.dart';
import 'package:file_picker/file_picker.dart';
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
  RSAKeyPair? _keyPair;
  //Data
  PlatformFile? _pickedFile;

  //Loading indicators
  bool _isBeingCyphered = false;
  bool _isBeingDeciphered = false;

  //Encrypted
  String _encryptedPath = '';

  //Decrypted
  String _decryptedPath = '';

  void _showPopUp(BaseFailure failure, BuildContext context) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        content: Text(failure.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RSA App'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            sliver: SliverList.list(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final storagePermission =
                        await PermissionManager().resolveStorageAccess();
                    if (storagePermission != null) {
                      _showPopUp(storagePermission, context);
                      return;
                    }

                    final response =
                        await FilePickerManager().pickFileAsBYtes();
                    response.fold(
                      success: (data) async {
                        _pickedFile = data;
                        setState(() {});
                      },
                      failure: (failure) {
                        _showPopUp(failure, context);
                      },
                    );
                  },
                  child: const Text('Pick File'),
                ),
                const SizedBox(height: 15),
                if (_pickedFile != null)
                  Column(
                    children: [
                      Text(
                        _pickedFile!.path!,
                        textAlign: TextAlign.center,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: (_isBeingCyphered)
                                ? const Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  )
                                : Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          _isBeingCyphered = true;
                                          setState(() {});
                                          final keys =
                                              await RSAmanager().generateKeys();
                                          final cypheredBytes =
                                              await RSAmanager().cypherBytes(
                                            _pickedFile!.bytes!,
                                            keys.publicKey,
                                          );
                                          final response =
                                              await FileSaverManager()
                                                  .writeToDownloadFolder(
                                            cypheredBytes,
                                            '${_pickedFile!.name.split('.').removeAt(0)}_crypted',
                                            _pickedFile!.extension!,
                                          );
                                          response.fold(
                                            success: (file) {
                                              _encryptedPath = file.path;
                                              setState(() {});
                                            },
                                            failure: (failure) {
                                              _showPopUp(failure, context);
                                            },
                                          );
                                          _keyPair = keys;
                                          _isBeingCyphered = false;
                                          setState(() {});
                                        },
                                        child: const Text(
                                          'Cypher the file',
                                        ),
                                      ),
                                      if (_encryptedPath.isNotEmpty)
                                        Column(
                                          children: [
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Text(_encryptedPath),
                                          ],
                                        ),
                                    ],
                                  ),
                          ),
                          Expanded(
                            child: (!_isBeingDeciphered)
                                ? Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          _isBeingDeciphered = true;
                                          setState(() {});

                                          final cypheredBytes =
                                              _pickedFile!.bytes!;

                                          final decypheredBytes =
                                              await RSAmanager().decipherBytes(
                                            cypheredBytes,
                                            _keyPair!.privateKey,
                                          );

                                          final response =
                                              await FileSaverManager()
                                                  .writeToDownloadFolder(
                                            decypheredBytes,
                                            '${_pickedFile!.name.split('.').removeAt(0)}_decrypted',
                                            _pickedFile!.extension!,
                                          );

                                          response.fold(
                                            success: (file) {
                                              _decryptedPath = file.path;
                                              setState(() {});
                                            },
                                            failure: (failure) {
                                              _showPopUp(failure, context);
                                            },
                                          );
                                          _isBeingDeciphered = false;
                                          setState(() {});
                                        },
                                        child: const Text('Decypher'),
                                      ),
                                      if (_decryptedPath.isNotEmpty)
                                        Column(
                                          children: [
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Text(_decryptedPath),
                                          ],
                                        ),
                                    ],
                                  )
                                : const Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
