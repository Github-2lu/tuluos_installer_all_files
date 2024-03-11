import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class InstallScreen extends StatefulWidget {
  const InstallScreen({super.key});

  @override
  State<InstallScreen> createState() {
    return _InstallScreenState();
  }
}

class _InstallScreenState extends State<InstallScreen> {
  final _txtController = TextEditingController();
  String _installInfo = "";
  bool _isButtonActive = false;

  void _installSystem() async {
    final process = await Process.start("/etc/tuluosinstaller/run.sh", [],
        runInShell: true);
    await process.stdout.transform(utf8.decoder).forEach(_chageStr);
    setState(() {
      _isButtonActive = true;
    });
  }

  void _chageStr(String newInfo) {
    setState(() {
      _installInfo += newInfo;
    });
  }

  @override
  void dispose() {
    _txtController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _installSystem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    _txtController.text = _installInfo;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Install"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 0.8 * height,
            width: 0.9 * width,
            child: TextField(
              maxLength: null,
              maxLines: null,
              readOnly: true,
              controller: _txtController,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: _isButtonActive
                        ? () {
                            exit(0);
                          }
                        : null,
                    child: const Text("Finish")),
              ],
            ),
          )
        ],
      ),
    );
  }
}
