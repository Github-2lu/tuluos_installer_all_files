// give description about partition
class PartitionInfo {
  //ex: sda1
  String partitionName;
  // ex: ext4 or fat32
  String partitionType;
  // partitionMountPts /mnt /mnt/boot/efi
  List<String> partitionMountPts;
  // ex: 100gb
  String partitionSize;
  // is partition is to be formatted
  String partitionFormat;

  PartitionInfo(
      {required this.partitionName,
      required this.partitionType,
      required this.partitionMountPts,
      required this.partitionFormat,
      required this.partitionSize});

  PartitionInfo.fromJson(Map<String, dynamic> partitionInfo)
      : partitionName = partitionInfo["name"],
        partitionType = partitionInfo["fstype"] ?? "",
        partitionMountPts = [
          for (final mp in partitionInfo["mountpoints"])
            if (mp != null) mp
        ],
        partitionSize = partitionInfo["size"],
        partitionFormat = "N";
}
