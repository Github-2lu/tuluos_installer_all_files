import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuluos_installer/models/disk_info.dart';
import 'package:tuluos_installer/providers/disk_info_provider.dart';
import 'package:tuluos_installer/services/get_diskinfo.dart';
import 'package:tuluos_installer/ui/screens/locale_user_input.dart';
import 'package:tuluos_installer/ui/widgets/show_partitions.dart';

class CustomPartitionScreen extends ConsumerStatefulWidget {
  const CustomPartitionScreen({super.key});

  @override
  ConsumerState<CustomPartitionScreen> createState() {
    return _CustomPartitionScreenState();
  }
}

class _CustomPartitionScreenState extends ConsumerState<CustomPartitionScreen> {
  int _selectedDiskIndex = 0;
  bool _isDataLoaded = true;
  bool _isError = false;

  bool _checkBoorRootPartitions(List<DiskInfo> disks) {
    bool isRootContains = false, isBootContains = false, isBreak = false;
    for (final disk in disks) {
      for (final partition in disk.partitions) {
        if (partition.partitionMountPts.contains("/")) {
          if (isRootContains) {
            isRootContains = false;
            isBreak = true;
            break;
          } else {
            isRootContains = true;
          }
        }

        if (partition.partitionMountPts.contains("/boot/efi")) {
          if (isBootContains) {
            isBootContains = false;
            isBreak = true;
            break;
          } else {
            isBootContains = true;
          }
        }
      }
      if (isBreak) {
        break;
      }
    }
    return isRootContains && isBootContains;
  }

  void _refreshDisks() async {
    try {
      setState(() {
        _isDataLoaded = false;
      });
      ref.watch(diskInfoProvider.notifier).setDiskInfos(await getDiskInfo());
      setState(() {
        _isDataLoaded = true;
      });
    } on Exception {
      setState(() {
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    Widget content = const Center(
      child: CircularProgressIndicator(),
    );

    if (_isError) {
      content = const Center(
        child: Text("Loding disks Failed"),
      );
    }

    if (_isDataLoaded) {
      final disks = ref.watch(diskInfoProvider);
      content = Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: width * 0.9,
                    height: height * 0.2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: width * 0.2,
                              child: DropdownButtonFormField(
                                  value: _selectedDiskIndex,
                                  items: [
                                    for (int i = 0; i < disks.length; i++)
                                      DropdownMenuItem(
                                          value: i,
                                          child: Text(disks[i].diskName))
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDiskIndex = value!;
                                    });
                                  }),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton.icon(
                                onPressed: _refreshDisks,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text("Refresh")),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton.icon(
                            onPressed: () {
                              Process.run("partitionmanager", []);
                            },
                            icon: const Icon(Icons.storage),
                            label: const Text("Partition Manager")),
                      ],
                    ),
                  ),
                  Container(
                    width: width * 0.9,
                    height: height * 0.5,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2)),
                    child: PartitionDataTable(
                        selectedDiskIndex: _selectedDiskIndex,
                        partitions: disks[_selectedDiskIndex].partitions),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Prev")),
                ElevatedButton(
                    onPressed: !_isDataLoaded
                        ? null
                        : () {
                            if (_checkBoorRootPartitions(disks)) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => const LocaleUserInput()));
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                        icon: const Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        ),
                                        title:
                                            const Text("Invalid Mountpoints"),
                                        content: const Text(
                                            "Only two paritions should be mounted as '/' for root and other '/boot/efi' for boot."),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                              child: const Text("Close"))
                                        ],
                                      ));
                            }
                          },
                    child: const Text("Next")),
              ],
            ),
          )
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom Partition Screen"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: content,
    );
  }
}
