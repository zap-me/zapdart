// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

typedef TextTheme TextThemer([TextTheme textTheme]);

Brightness ZapBrightness = Brightness.light;

Color ZapWhite =         Colors.white;
Color ZapGrey =          Color(0xFFF8F6F1);
Color ZapBlue =          Color(0xFF3765CB);
Gradient? ZapBlueGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ZapBlue,
            Color(0xFF5080CB)
          ]);
Color ZapYellow =        Color(0xFFFFBB00);
Gradient? ZapYellowGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ZapYellow,
            Color(0xFFFFD020)
          ]);
Color ZapGreen =         Color(0xFF009075);
Gradient? ZapGreenGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ZapGreen,
            Color(0xFF109090)
          ]);
Color ZapRed =           Colors.red;
Color ZapWarning =       ZapYellow;
Color ZapWarningLight =  Color(0x80FFBB00);
Color ZapBlack =         Colors.black;
Color ZapBlackMed =      Colors.black54;
Color ZapBlackLight =    Colors.black38;
Color ZapOutgoingFunds = ZapYellow;
Color ZapIncomingFunds = ZapGreen;

TextThemer ZapTextThemer = GoogleFonts.oxygenTextTheme;

void overrideTheme({Brightness? zapBrightness,
  Color? zapWhite, Color? zapGrey, Color? zapBlue, Gradient? zapBlueGradient, Color? zapYellow, Gradient? zapYellowGradient, Color? zapGreen, Gradient? zapGreenGradient, Color? zapRed,
  Color? zapWarning, Color? zapWarningLight, Color? zapBlack, Color? zapBlackMed, Color? zapBlackLight,
  Color? zapOutgoingFunds, Color? zapIncomingFunds,
  TextThemer? zapTextThemer}) {
  // brightness
  if (zapBrightness != null)
    ZapBrightness = zapBrightness;
  // colors
  if (zapWhite != null)
    ZapWhite = zapWhite;
  if (zapGrey != null)
    ZapGrey = zapGrey;
  if (zapBlue != null)
    ZapBlue = zapBlue;
  if (zapBlueGradient != null)
    ZapBlueGradient = zapBlueGradient;
  if (zapYellow != null)
    ZapYellow = zapYellow;
  if (zapYellowGradient != null)
    ZapYellowGradient = zapYellowGradient;
  if (zapGreen != null)
    ZapGreen = zapGreen;
  if (zapGreenGradient != null)
    ZapGreenGradient = zapGreenGradient;
  if (zapRed != null)
    ZapRed = zapRed;
  if (zapWarning != null)
    ZapWarning = zapWarning;
  if (zapWarningLight != null)
    ZapWarningLight = zapWarningLight;
  if (zapBlack != null)
    ZapBlack = zapBlack;
  if (zapBlackMed != null)
    ZapBlackMed = zapBlackMed;
  if (zapBlackLight != null)
    ZapBlackLight = zapBlackLight;
  if (zapOutgoingFunds != null)
    ZapOutgoingFunds = zapOutgoingFunds;
  if (zapIncomingFunds!= null)
    ZapIncomingFunds = zapIncomingFunds;
  // text theme
  if (zapTextThemer != null)
    ZapTextThemer = zapTextThemer;
}
