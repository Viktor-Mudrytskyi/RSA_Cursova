import 'dart:io';

import 'package:cursova/core/failures/base_failure.dart';
import 'package:cursova/core/failures/encryption_failures/computation_failure.dart';
import 'package:cursova/core/managers/file_picker_manager.dart';
import 'package:cursova/core/managers/file_saver_manager.dart';
import 'package:cursova/core/managers/permission_manager.dart';
import 'package:cursova/core/rsa/managers/rsa_manager.dart';
import 'package:cursova/core/rsa/rsa_key_pair.dart';
import 'package:cursova/core/widgets/keys_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RSAKeyPair? _keys;
  bool _isLoading = false;
  PlatformFile? _pickedFile;
  String? _generatedFilePath;

  void _showPopUp(BaseFailure failure, BuildContext context) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        content: Text(failure.toString()),
      ),
    );
  }

  Future<void> _generateKeys() async {
    _isLoading = true;
    _pickedFile = null;
    _keys = null;
    _generatedFilePath = null;
    setState(() {});
    final keys = await RSAmanager().generateKeys();
    _keys = keys;
    _isLoading = false;
    setState(() {});
  }

  Future<void> _pickFile() async {
    _generatedFilePath = null;
    setState(() {});
    final permissionRes = await PermissionManager().resolveStorageAccess();
    if (permissionRes != null) {
      if (context.mounted) {
        _showPopUp(permissionRes, context);
      }
      return;
    }

    final filePickerRes = await FilePickerManager().pickPlatformFile();
    filePickerRes.fold(
      success: (platformFile) {
        _pickedFile = platformFile;
        setState(() {});
      },
      failure: (failure) {
        if (context.mounted) {
          _showPopUp(failure, context);
        }
      },
    );
  }

  Future<void> _encrypt() async {
    _isLoading = true;
    setState(() {});
    try {
      final cryptedBytes = await RSAmanager().encryptBytes(
        _pickedFile!.bytes!,
        _keys!.publicKey,
      );
      final saverRes = await FileSaverManager().writeToDownloadFolder(
        cryptedBytes,
        '${_pickedFile!.name.split('.').removeAt(0)}_encrypted',
        _pickedFile!.extension ?? '',
      );
      saverRes.fold(
        success: (success) {
          _generatedFilePath = success.path;
        },
        failure: (failure) {
          if (context.mounted) {
            _showPopUp(
              ComputationFailure(),
              context,
            );
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        _showPopUp(
          ComputationFailure(),
          context,
        );
      }
    } finally {
      _isLoading = false;
      setState(() {});
    }
  }

  Future<void> _decrypt() async {
    _isLoading = true;
    setState(() {});
    try {
      final decryptedBytes = await RSAmanager().decryptBytes(
        _pickedFile!.bytes!,
        _keys!.privateKey,
      );
      final saverRes = await FileSaverManager().writeToDownloadFolder(
        decryptedBytes,
        '${_pickedFile!.name.split('.').removeAt(0)}_decrypted',
        _pickedFile!.extension ?? '',
      );
      saverRes.fold(
        success: (success) {
          _generatedFilePath = success.path;
        },
        failure: (failure) {
          if (context.mounted) {
            _showPopUp(
              ComputationFailure(),
              context,
            );
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        _showPopUp(
          ComputationFailure(),
          context,
        );
      }
    } finally {
      _isLoading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverAppBar(
                title: Text('RSA App'),
                centerTitle: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.list(
                  children: [
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _generateKeys,
                      child: const Text('Generate keys'),
                    ),
                    if (_keys != null) KeysWidget(keys: _keys!),
                    if (_keys != null)
                      ElevatedButton(
                        onPressed: _pickFile,
                        child: const Text('Pick a file'),
                      ),
                    if (_pickedFile != null)
                      Text(
                        'Selected File: ${_pickedFile!.name}',
                        textAlign: TextAlign.center,
                      ),
                    if (_pickedFile != null)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _encrypt,
                              child: const Text('Encrypt'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _decrypt,
                              child: const Text('Decrypt'),
                            ),
                          ),
                        ],
                      ),
                    if (_generatedFilePath != null)
                      Text(
                        'Result: ${_generatedFilePath!}',
                        textAlign: TextAlign.center,
                      )
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            ColoredBox(
              color: Colors.black.withOpacity(.2),
              child: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
        ],
      ),
    );
  }
}
