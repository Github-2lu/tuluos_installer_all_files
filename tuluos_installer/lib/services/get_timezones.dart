import 'dart:io';

Future<Map<String, List<String>>> getTimeZones() async {
  final process = await Process.run("timedatectl", ["list-timezones"]);
  List<String> processRes = process.stdout.toString().split("\n");

  Map<String, List<String>> timeZones = {};
  for (final res in processRes) {
    final region = res.split("/")[0];
    if (region != "") {
      if (timeZones[region] == null) {
        timeZones[region] = [];
      }
      if (res.split("/").length == 2) {
        final zone = res.split("/")[1];
        timeZones[region]!.add(zone);
      }
    }
  }
  return timeZones;
}
