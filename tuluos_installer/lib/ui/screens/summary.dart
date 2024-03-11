import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuluos_installer/models/partition_info.dart';
import 'package:tuluos_installer/providers/disk_info_provider.dart';
import 'package:tuluos_installer/providers/locale_info_provider.dart';
import 'package:tuluos_installer/providers/user_info_provider.dart';
import 'package:tuluos_installer/ui/screens/install.dart';
import 'package:tuluos_installer/ui/widgets/show_install_alert.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() {
    return _SummaryScreenState();
  }
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  PartitionInfo? _getRootPartitionStatus() {
    final disksInfo = ref.watch(diskInfoProvider);

    for (final disk in disksInfo) {
      for (final part in disk.partitions) {
        if (part.partitionMountPts.length == 1 &&
            part.partitionMountPts.contains("/")) {
          return part;
        }
      }
    }
    return null;
  }

  PartitionInfo? _getBootPartitionStatus() {
    final disksInfo = ref.watch(diskInfoProvider);

    for (final disk in disksInfo) {
      for (final part in disk.partitions) {
        if (part.partitionMountPts.length == 1 &&
            part.partitionMountPts.contains("/boot/efi")) {
          return part;
        }
      }
    }
    return null;
  }

  void _saveConfig(PartitionInfo bootInfo, PartitionInfo rootInfo,
      Map<String, String?> localeInfo, Map<String, String> userInfo) async {
    // const filePath = "/etc/tuluosinstaller/config/installConf.json";
    const filePath = "/etc/tuluosinstaller/install.json";
    Map<String, Map<String, String?>> summary = {};

    summary["bootInfo"] = {
      "name": bootInfo.partitionName,
      "isFormat": bootInfo.partitionFormat
    };

    summary["rootInfo"] = {
      "name": rootInfo.partitionName,
      "isFormat": rootInfo.partitionFormat
    };

    summary["LocaleInfo"] = {
      "Region": localeInfo["Region"],
      "Zone": localeInfo["Zone"],
      "Locale": localeInfo["Locale"]
    };

    summary["UserInfo"] = {
      "FullName": userInfo["FullName"],
      "UserName": userInfo["UserName"],
      "HostName": userInfo["HostName"],
      "UserPassword": userInfo["UserPassword"],
      "RootPassword": userInfo["RootPassword"]
    };

    final summaryStr = jsonEncode(summary);

    final command = "printf '$summaryStr' | sudo tee $filePath >> /dev/null";
    await Process.run('/bin/sh', ['-c', command]);
  }

  @override
  Widget build(BuildContext context) {
    final bootPartition = _getBootPartitionStatus();
    final rootPartition = _getRootPartitionStatus();
    final localeInfo = ref.watch(localeInfoProvider);
    final userInfo = ref.watch(userInfoProvider);

    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Summary"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          SizedBox(
            height: height * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        const Text("Partition info"),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              children: [
                                const Text("Boot Partition"),
                                Text("Name: ${bootPartition!.partitionName}"),
                                Text("Size: ${bootPartition.partitionSize}"),
                                Text(
                                    "Mount Point: ${bootPartition.partitionMountPts[0]}"),
                                Text(
                                    "Format partition: ${bootPartition.partitionFormat}")
                              ],
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Column(
                              children: [
                                const Text("Root Partiiton"),
                                Text(
                                    "PartitionName: ${rootPartition!.partitionName}"),
                                Text("Size : ${rootPartition.partitionSize}"),
                                Text(
                                    "Mount Point: ${rootPartition.partitionMountPts[0]}"),
                                Text(
                                    "Format Partition: ${rootPartition.partitionFormat}"),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            const Text("Locale Info"),
                            Text("Region: ${localeInfo["Region"]}"),
                            Text("Zone: ${localeInfo["Zone"]}"),
                            Text("Locale: ${localeInfo["Locale"]}")
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            const Text("User Info"),
                            Text("Full Name: ${userInfo["FullName"]}"),
                            Text("User Name: ${userInfo["UserName"]}"),
                            Text("Host Name: ${userInfo["HostName"]}"),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Prev")),
                ElevatedButton(
                    onPressed: () async {
                      final res = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => const ShowInstallAlert());
                      if (res != null && res) {
                        _saveConfig(
                            bootPartition, rootPartition, localeInfo, userInfo);
                        if (!context.mounted) return;
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => const InstallScreen()));
                      }
                    },
                    child: const Text("Next"))
              ],
            ),
          )
        ],
      ),
    );
  }
}
