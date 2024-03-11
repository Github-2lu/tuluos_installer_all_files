import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuluos_installer/data/system_locales.dart';
import 'package:tuluos_installer/providers/locale_info_provider.dart';
import 'package:tuluos_installer/providers/user_info_provider.dart';
import 'package:tuluos_installer/ui/screens/summary.dart';

class LocaleUserInput extends ConsumerStatefulWidget {
  const LocaleUserInput({super.key});

  @override
  ConsumerState<LocaleUserInput> createState() {
    return _LocalUserInput();
  }
}

class _LocalUserInput extends ConsumerState<LocaleUserInput> {
  final GlobalKey<FormFieldState> _zoneKey = GlobalKey<FormFieldState>();
  final _userFormkey = GlobalKey<FormState>();

  void _saveData() {
    if (_userFormkey.currentState!.validate() &&
        _zoneKey.currentState!.validate()) {
      _userFormkey.currentState!.save();
      _zoneKey.currentState!.save();
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => const SummaryScreen()));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    var localeInfo = ref.watch(localeInfoProvider);
    var userInfo = ref.watch(userInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Locale & User Screen"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          SizedBox(
            height: height * 0.8,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // const Text("world"),
                  SizedBox(
                    width: width * 0.4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField(
                            value: localeInfo["Region"],
                            hint: const Text("Choose Region"),
                            decoration:
                                const InputDecoration(label: Text("Region")),
                            items: [
                              for (final entry in allTimeZones.entries)
                                DropdownMenuItem(
                                    value: entry.key, child: Text(entry.key))
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _zoneKey.currentState!.reset();
                                });
                                ref
                                    .read(localeInfoProvider.notifier)
                                    .addLocaleInfo("Region", value);
                              }
                            }),
                        const SizedBox(
                          height: 10,
                        ),
                        DropdownButtonFormField(
                          key: _zoneKey,
                          value: allTimeZones[localeInfo["Region"]]!
                                  .contains(localeInfo["Zone"])
                              ? localeInfo["Zone"]
                              : null,
                          hint: const Text("Choose Zone"),
                          decoration:
                              const InputDecoration(label: Text("Zone")),
                          items: [
                            for (final region
                                in allTimeZones[localeInfo["Region"]]!)
                              DropdownMenuItem(
                                  value: region, child: Text(region))
                          ],
                          validator: (value) {
                            if (value == null &&
                                allTimeZones[localeInfo["Region"]]!
                                    .isNotEmpty) {
                              return "Choose Zone";
                            }
                            return null;
                          },
                          onChanged: (value) {},
                          onSaved: (newValue) {
                            ref
                                .read(localeInfoProvider.notifier)
                                .addLocaleInfo("Zone", newValue);
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        DropdownButtonFormField(
                            value: localeInfo["Locale"],
                            hint: const Text("Choose Locale"),
                            decoration:
                                const InputDecoration(label: Text("Locale")),
                            items: [
                              for (final locale in allLocales)
                                DropdownMenuItem(
                                    value: locale, child: Text(locale))
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                ref
                                    .read(localeInfoProvider.notifier)
                                    .addLocaleInfo("Locale", value);
                              }
                            }),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: width * 0.4,
                    child: Form(
                      key: _userFormkey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                                hintText: "Enter Full Name",
                                label: Text("Full Name")),
                            initialValue: userInfo["FullName"],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Enter name";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              ref
                                  .read(userInfoProvider.notifier)
                                  .addUserInfo("FullName", newValue!);
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                                hintText: "Enter User name",
                                label: Text("User Name")),
                            initialValue: userInfo["UserName"],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Enter User Name";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              ref
                                  .read(userInfoProvider.notifier)
                                  .addUserInfo("UserName", newValue!);
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                                hintText: "Enter Host name",
                                label: Text("Host Name")),
                            initialValue: userInfo["HostName"],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Enter Host Name";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              ref
                                  .read(userInfoProvider.notifier)
                                  .addUserInfo("HostName", newValue!);
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(
                                hintText: "Enter User Password name",
                                label: Text("UserPassword")),
                            initialValue: userInfo["UserPassword"],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Enter User Password";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              ref
                                  .read(userInfoProvider.notifier)
                                  .addUserInfo("UserPassword", newValue!);
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(
                                hintText: "Enter Root Password",
                                label: Text("Root Password")),
                            initialValue: userInfo["RootPassword"],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Enter Root Password";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              ref
                                  .read(userInfoProvider.notifier)
                                  .addUserInfo("RootPassword", newValue!);
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
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
                    onPressed: () {
                      _saveData();
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
