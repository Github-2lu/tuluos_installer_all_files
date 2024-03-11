import 'package:flutter/material.dart';

class ShowInstallAlert extends StatelessWidget {
  const ShowInstallAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Install Confirmation"),
      content:
          const Text("Do you want to install TuluOs with this configuration?"),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop<bool>(false);
            },
            child: const Text("Cancel")),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop<bool>(true);
            },
            child: const Text("OK"))
      ],
    );
  }
}
