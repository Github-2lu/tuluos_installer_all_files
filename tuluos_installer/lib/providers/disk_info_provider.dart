import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuluos_installer/models/disk_info.dart';

class DiskInfoNotifier extends StateNotifier<List<DiskInfo>> {
  DiskInfoNotifier() : super(const []);

  void setDiskInfos(List<DiskInfo> disks) {
    state = [...disks];
  }

  void changePartitionInfo(
      {required int selectedDiskIndex,
      required int selectedPartIndex,
      String? mountPt,
      String? isFormat}) {
    var newState = state;
    if (mountPt != null) {
      newState[selectedDiskIndex]
          .partitions[selectedPartIndex]
          .partitionMountPts = [mountPt];
    }
    if (isFormat != null) {
      newState[selectedDiskIndex]
          .partitions[selectedPartIndex]
          .partitionFormat = isFormat;
    }
    state = [...newState];
  }
}

final diskInfoProvider =
    StateNotifierProvider<DiskInfoNotifier, List<DiskInfo>>(
        (ref) => DiskInfoNotifier());
