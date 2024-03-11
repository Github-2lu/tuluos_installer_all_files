import 'dart:convert';
import 'dart:io';

import 'package:tuluos_installer/models/disk_info.dart';

Future<List<DiskInfo>> getDiskInfo() async {
  List<DiskInfo> disksInfo = [];
  final disks =
      await Process.run("lsblk", ["-o", "name,fstype,size,mountpoints", "-J"]);
  final disksJson = json.decode(disks.stdout.toString());

  for (final disk in disksJson["blockdevices"]) {
    disksInfo.add(DiskInfo.fromJson(disk));
  }
  return disksInfo;
}
