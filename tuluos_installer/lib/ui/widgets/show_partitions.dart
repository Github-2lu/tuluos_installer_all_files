import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuluos_installer/models/partition_info.dart';
import 'package:tuluos_installer/providers/disk_info_provider.dart';

class PartitionDataTable extends ConsumerStatefulWidget {
  final int selectedDiskIndex;
  final List<PartitionInfo> partitions;

  const PartitionDataTable(
      {super.key, required this.selectedDiskIndex, required this.partitions});

  @override
  ConsumerState<PartitionDataTable> createState() {
    return _PartitionDataTableState();
  }
}

class _PartitionDataTableState extends ConsumerState<PartitionDataTable> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(
        showBottomBorder: true,
        horizontalMargin: 10,
        columns: const [
          DataColumn(label: Text("Name")),
          DataColumn(label: Text("File Type")),
          DataColumn(label: Text("Mount Points")),
          DataColumn(label: Text("Size")),
          DataColumn(label: Text("isFormat")),
        ],
        rows: [
          for (int i = 0; i < widget.partitions.length; i++)
            DataRow(cells: [
              DataCell(Text(widget.partitions[i].partitionName)),
              DataCell(Text(widget.partitions[i].partitionType)),
              DataCell(
                Row(
                  children: [
                    Text(widget.partitions[i].partitionMountPts.join("/n")),
                    PopupMenuButton(
                        child: const Icon(Icons.settings_outlined),
                        onSelected: (value) {
                          ref
                              .read(diskInfoProvider.notifier)
                              .changePartitionInfo(
                                  selectedDiskIndex: widget.selectedDiskIndex,
                                  selectedPartIndex: i,
                                  mountPt: value);
                        },
                        itemBuilder: (context) => const [
                              PopupMenuItem(value: "/", child: Text("/")),
                              PopupMenuItem(
                                  value: "/boot/efi", child: Text("/boot/efi")),
                            ])
                  ],
                ),
              ),
              DataCell(Text(widget.partitions[i].partitionSize)),
              DataCell(
                Checkbox(
                  value: widget.partitions[i].partitionFormat == "Y",
                  onChanged: (value) {
                    if (value != null) {
                      final isFormatStr = value == true ? "Y" : "N";
                      ref.read(diskInfoProvider.notifier).changePartitionInfo(
                          selectedDiskIndex: widget.selectedDiskIndex,
                          selectedPartIndex: i,
                          isFormat: isFormatStr);
                    }
                  },
                ),
              ),
            ])
        ],
      ),
    );
  }
}
