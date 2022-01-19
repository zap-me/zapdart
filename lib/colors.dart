// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

typedef TextTheme TextThemer([TextTheme textTheme]);

Brightness ZapBrightness = Brightness.light;

Color ZapPrimary = Color(0xffeeeeee);
Color ZapPrimaryDark = Color(0xffbcbcbc);

Color ZapSecondary = Color(0xff5c6bc0);
Gradient? ZapSecondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ZapSecondary, Color(0xFF6090E0)]);
Color ZapSecondaryDark = Color(0xff26418f);

Color ZapSurface = Colors.white;
Color ZapBackground = Colors.white;
Color ZapError = Color(0xffb00020);

Color ZapOnPrimary = Colors.black;
Color ZapOnSecondary = Colors.white;

Color ZapOnSurface = Colors.black;
Color ZapOnBackground = Colors.black;
Color ZapOnError = Colors.white;

Color ZapYellow = Color(0xFFFFBB00);
Gradient? ZapYellowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ZapYellow, Color(0xFFFFD030)]);
Color ZapGreen = Color(0xFF009075);
Gradient? ZapGreenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ZapGreen, Color(0xFF109090)]);
Color ZapRed = Colors.red;
Color ZapWarning = ZapYellow;
Color ZapWarningLight = Color(0x80FFBB00);
Color ZapBlack = Colors.black;
Color ZapBlackMed = Colors.black54;
Color ZapBlackLight = Colors.black38;
Color ZapOutgoingFunds = Colors.red;
Color ZapIncomingFunds = Colors.green;
Color ZapSelfFunds = Colors.black;

TextThemer ZapTextThemer = GoogleFonts.oxygenTextTheme;

void overrideTheme(
    {Brightness? zapBrightness,
    Color? zapPrimary,
    Color? zapPrimaryDark,
    Color? zapSecondary,
    Color? zapSecondaryDark,
    Gradient? zapSecondaryGradient,

    Color? zapSurface,
    Color? zapBackground,
    Color? zapError,
    Color? zapOnPrimary,
    Color? zapOnSecondary,
    Color? zapOnError,
    Color? zapOnSurface,
    Color? zapOnBackground,

    Color? zapYellow,
    Gradient? zapYellowGradient,
    Color? zapGreen,
    Gradient? zapGreenGradient,
    Color? zapRed,
    Color? zapWarning,
    Color? zapWarningLight,
    Color? zapBlack,
    Color? zapBlackMed,
    Color? zapBlackLight,
    Color? zapOutgoingFunds,
    Color? zapIncomingFunds,
    Color? zapSelfFunds,
    TextThemer? zapTextThemer}) {
  // brightness
  if (zapBrightness != null) ZapBrightness = zapBrightness;
  // colors
  if (zapPrimary != null) ZapPrimary = zapPrimary;
  if (zapPrimaryDark != null) ZapPrimaryDark = zapPrimaryDark;
  if (zapSecondary != null) ZapSecondary = zapSecondary;
  if (zapSecondaryDark != null) ZapSecondaryDark = zapSecondaryDark;

  if (zapSurface != null) ZapSurface = zapSurface;
  if (zapBackground != null) ZapBackground = zapBackground;
  if (zapError != null) ZapError = zapError;
  if (zapOnPrimary != null) ZapOnPrimary = zapOnPrimary;
  if (zapOnSecondary != null) ZapOnSecondary = zapOnSecondary;
  if (zapOnError != null) ZapOnError = zapOnError;
  if (zapOnSurface != null) ZapOnSurface = zapOnSurface;
  if (zapOnBackground != null) ZapOnBackground = zapOnBackground;

  if (zapYellow != null) ZapYellow = zapYellow;
  if (zapYellowGradient != null) ZapYellowGradient = zapYellowGradient;
  if (zapGreen != null) ZapGreen = zapGreen;
  if (zapGreenGradient != null) ZapGreenGradient = zapGreenGradient;
  if (zapRed != null) ZapRed = zapRed;
  if (zapWarning != null) ZapWarning = zapWarning;
  if (zapWarningLight != null) ZapWarningLight = zapWarningLight;
  if (zapBlack != null) ZapBlack = zapBlack;
  if (zapBlackMed != null) ZapBlackMed = zapBlackMed;
  if (zapBlackLight != null) ZapBlackLight = zapBlackLight;
  if (zapOutgoingFunds != null) ZapOutgoingFunds = zapOutgoingFunds;
  if (zapIncomingFunds != null) ZapIncomingFunds = zapIncomingFunds;
  if (zapSelfFunds != null) ZapSelfFunds = zapSelfFunds;
  // text theme
  if (zapTextThemer != null) ZapTextThemer = zapTextThemer;
}
