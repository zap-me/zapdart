import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:zapdart/colors.dart';

import 'package:zapdart/utils.dart';
import 'package:zapdart/widgets.dart';
import 'package:zapdart/libzap.dart';

void main() => runApp(MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print(window.physicalSize);

    return Material(
        child: ListView(children: [
      ListTile(
          title: Text('UniversalPlatform'),
          subtitle: Text(
            'Web: ${UniversalPlatform.isWeb} \n '
            'MacOS: ${UniversalPlatform.isMacOS} \n'
            'Windows: ${UniversalPlatform.isWindows} \n'
            'Linux: ${UniversalPlatform.isLinux} \n'
            'Android: ${UniversalPlatform.isAndroid} \n'
            'IOS: ${UniversalPlatform.isIOS} \n'
            'Fuschia: ${UniversalPlatform.isFuchsia} \n',
          )),
      ListTile(
          title: Text('Libzap version'),
          subtitle: Text('${LibZap().version()}, ${(LibZap()).toString()}')),
      ListTile(
          title: Text('raisedButton'),
          subtitle: raisedButton(
              onPressed: () => alert(context, 'hello', 'world'),
              child: Text('Button'))),
      ListTile(
          title: Text('RoundedButton'),
          subtitle: RoundedButton(() => alert(context, 'hello', 'world'),
              ZapWhite, ZapBlue, ZapBlueGradient, 'Button',
              holePunch: true)),
    ]));
  }
}
