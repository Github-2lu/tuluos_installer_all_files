import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuluos_installer/data/system_locales.dart';
import 'package:tuluos_installer/models/disk_info.dart';
import 'package:tuluos_installer/providers/disk_info_provider.dart';
import 'package:tuluos_installer/services/get_diskinfo.dart';
import 'package:tuluos_installer/services/get_locale.dart';
import 'package:tuluos_installer/services/get_timezones.dart';
import 'package:tuluos_installer/ui/screens/custom_partition.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() {
    return _WelcomeScreenState();
  }
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  List<DiskInfo> _disks = [];
  bool _isDataLoaded = false;
  bool _iserror = false;

  void setDisks(List<DiskInfo> disks) {
    ref.read(diskInfoProvider.notifier).setDiskInfos(disks);
  }

  void _getInitialData() async {
    try {
      _disks = await getDiskInfo();
      ref.watch(diskInfoProvider.notifier).setDiskInfos(_disks);

      allTimeZones = await getTimeZones();

      allLocales = await getLocales();

      setState(() {
        _isDataLoaded = true;
      });
    } on Exception {
      setState(() {
        _iserror = true;
      });
    }
  }

  @override
  void initState() {
    _getInitialData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Widget content = const Center(
      child: CircularProgressIndicator(),
    );
    if (_iserror) {
      content = const Center(
        child: Text("Error Getting initial Data"),
      );
    }
    if (_isDataLoaded) {
      content = const Center(
        child: Text("ready to go"),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          SizedBox(width: width * 0.9, height: height * 0.9, child: content),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: _isDataLoaded == false
                        ? null
                        : () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) =>
                                    const CustomPartitionScreen()));
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
