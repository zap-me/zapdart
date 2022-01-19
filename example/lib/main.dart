import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

import 'package:zapdart/utils.dart';
import 'package:zapdart/widgets.dart';
import 'package:zapdart/libzap.dart';
import 'package:zapdart/colors.dart';
import 'package:zapdart/form_ui.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: ZapTextThemer(Theme.of(context).textTheme),
        primaryTextTheme: ZapTextThemer(Theme.of(context).textTheme),
        colorScheme: ColorScheme(
          primary: ZapPrimary,
          primaryVariant: ZapPrimaryDark,
          secondary: ZapSecondary,
          secondaryVariant: ZapSecondaryDark,
          surface: ZapSurface,
          background: ZapBackground,
          error: ZapError,
          onPrimary: ZapOnPrimary,
          onSecondary: ZapOnSecondary,
          onSurface: ZapOnSurface,
          onBackground: ZapOnBackground,
          onError: ZapOnError,
          brightness: ZapBrightness)
      ),
      debugShowCheckedModeBanner: false,
      home: Demo(),
    );
  }
}

class Demo extends StatelessWidget {
  final _controller = TextEditingController();

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
          title: Text('RoundedButton 1'),
          subtitle: RoundedButton(() => alert(context, 'hello', 'world'),
              ZapOnSecondary, ZapSecondary, ZapSecondaryGradient, 'Button')),
      ListTile(
          title: Text('RoundedButton 2'),
          subtitle: RoundedButton(() => print('blah'),
            ZapOnSecondary, ZapSecondary, ZapSecondaryGradient, 'Blah',
            holePunch: true, width: 200)),
      ListTile(
          title: Text('RoundedButton 3'),
          subtitle: RoundedButton(() => alert(context, 'hello', 'world'),
              ZapOnSecondary, ZapGreen, ZapGreenGradient, 'Button hole punch',
              holePunch: true, width: 200)),
      ListTile(
        title: phoneNumberInput(_controller, (pn) => print(pn), (valid) => print(valid), countryCode: 'NZ', preferredCountries: ['New Zealand', 'Austrailia']))
    ]));
  }
}
