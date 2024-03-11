import 'dart:io';

Future<List<String>> getLocales() async {
  final process = await Process.run("cat", ["/usr/share/i18n/SUPPORTED"]);
  return process.stdout.toString().split("\n");
}
