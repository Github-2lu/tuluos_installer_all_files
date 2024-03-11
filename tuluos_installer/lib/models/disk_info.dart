import 'package:tuluos_installer/models/partition_info.dart';

class DiskInfo {
  final String diskName;
  final List<PartitionInfo> partitions;
  const DiskInfo({required this.diskName, required this.partitions});

  DiskInfo.fromJson(Map<String, dynamic> diskJson)
      : diskName = diskJson["name"],
        partitions = diskJson["children"] != null
            ? [
                for (final partition in diskJson["children"])
                  PartitionInfo.fromJson(partition)
              ]
            : [];
}
