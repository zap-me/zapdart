import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

import 'colors.dart';

enum MessageCategory {
  Info,
  Warning,
}

Widget backButton(BuildContext context,
    {Color? color, void Function()? onPressed}) {
  color ??= ZapPrimary;
  return IconButton(
      icon: Icon(Icons.arrow_back_ios, color: color),
      onPressed: onPressed != null
          ? onPressed
          : () => Navigator.of(context).pop(false));
}

ButtonStyle raisedButtonStyle(
    {Color? primary, Color? textColor, EdgeInsetsGeometry? padding, Size? minSize}) {
  primary ??= ZapPrimary;
  textColor ??= ZapOnPrimary;
  padding ??= EdgeInsets.symmetric(horizontal: 16);
  minSize ??= Size(88, 36);
  return ElevatedButton.styleFrom(
    onPrimary: textColor,
    primary: primary,
    minimumSize: minSize,
    padding: padding,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
  );
}

Widget raisedButton(
    {required void Function()? onPressed,
    required Widget? child,
    Color? primary,
    Color? textColor,
    EdgeInsetsGeometry? padding,
    Size? minSize}) {
  return ElevatedButton(
      onPressed: onPressed,
      child: child,
      style: raisedButtonStyle(
          primary: primary, textColor: textColor, padding: padding, minSize: minSize));
}

Widget raisedButtonIcon(
    {required void Function()? onPressed,
    required Widget icon,
    required Widget label,
    Color? primary,
    Color? textColor,
    EdgeInsetsGeometry? padding,
    Size? minSize}) {
  return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
      style: raisedButtonStyle(
          primary: primary, textColor: textColor, padding: padding, minSize: minSize));
}

ButtonStyle flatButtonStyle() {
  return TextButton.styleFrom(
    primary: Colors.black87,
    minimumSize: Size(88, 36),
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );
}

Widget flatButton(
    {required void Function()? onPressed, required Widget child}) {
  return TextButton(
      onPressed: onPressed, child: child, style: flatButtonStyle());
}

Widget flatButtonIcon(
    {required void Function()? onPressed,
    required Widget icon,
    required Widget label}) {
  return TextButton.icon(
      onPressed: onPressed, icon: icon, label: label, style: flatButtonStyle());
}

void flushbarMsg(BuildContext context, String msg,
    {int seconds = 3, MessageCategory category = MessageCategory.Info}) {
  IconData icon;
  switch (category) {
    case MessageCategory.Info:
      icon = Icons.info;
      break;
    case MessageCategory.Warning:
      icon = Icons.warning;
      break;
  }
  Flushbar(
    messageText: Text(msg, style: TextStyle(color: ZapSecondary)),
    icon: Icon(icon,
        size: 28.0,
        color: category == MessageCategory.Info ? ZapSecondary : ZapWarning),
    duration: Duration(seconds: seconds),
    leftBarIndicatorColor: ZapSecondary,
    backgroundColor: ZapPrimary,
  )..show(context);
}

class RoundedButton extends StatelessWidget {
  RoundedButton(this.onPressed, this.textColor, this.fillColor,
      this.fillGradient, this.title,
      {this.icon,
      this.borderColor,
      this.width = 88,
      this.height = 35,
      this.holePunch = false})
      : super();

  final VoidCallback onPressed;
  final Color textColor;
  final Color fillColor;
  final Gradient? fillGradient;
  final String title;
  final IconData? icon;
  final Color? borderColor;
  final double width;
  final double height;
  final bool holePunch;

  @override
  Widget build(BuildContext context) {
    var radius = BorderRadius.circular(18.0);
    var buttonStyle = ElevatedButton.styleFrom(
        primary: fillGradient == null ? fillColor : Colors.transparent,
        side: fillGradient == null
            ? BorderSide(color: borderColor != null ? borderColor! : fillColor)
            : null,
        shape: RoundedRectangleBorder(borderRadius: radius),
        shadowColor: Colors.transparent);
    var decoration = BoxDecoration(
      color: fillColor,
      border: borderColor != null ? Border.all(color: borderColor!) : null,
      gradient: fillGradient,
      borderRadius: radius,
      boxShadow: kElevationToShadow[3],
    );
    var text = Text(title, style: TextStyle(color: textColor, fontSize: 14));
    Widget btn;
    if (icon != null && holePunch)
      throw ArgumentError('Can only use "icon" parameter OR "holePunch"');
    if (icon != null) {
      var row = Row(
          children: [Icon(icon, color: textColor, size: 14), text],
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround);
      btn = Container(
          width: width,
          height: height,
          margin: EdgeInsets.all(5),
          child: DecoratedBox(
              decoration: decoration,
              child: ElevatedButton(
                  onPressed: onPressed, child: row, style: buttonStyle)));
    } else {
      btn = Container(
          width: width,
          height: height,
          margin: EdgeInsets.all(5),
          child: DecoratedBox(
              decoration: decoration,
              child: ElevatedButton(
                  onPressed: onPressed, child: text, style: buttonStyle)));
      if (holePunch) {
        // this is a hack, havent figured out how to do the inner drop shadow
        var circle = Container(
            width: 20,
            height: 20,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: textColor));
        var stack = Stack(alignment: AlignmentDirectional.center, children: [
          btn,
          Positioned(child: circle, right: 12),
          Positioned(
              child: Icon(Icons.arrow_forward_ios, size: 14, color: fillColor),
              right: 14)
        ]);
        btn = stack;
      }
    }
    return btn;
  }
}

class SquareButton extends StatelessWidget {
  SquareButton(this.onPressed, this.icon, this.color, this.title, {this.textColor, this.textOutside=true, this.borderSize=5.0}) : super();

  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final String title;
  final Color? textColor;
  final bool textOutside;
  final double borderSize;

  @override
  Widget build(BuildContext context) {
    var text = Column(children: [SizedBox.fromSize(size: Size(1, 12)), Text(title, style: TextStyle(fontSize: 10, color: textColor != null ? textColor : ZapOnSecondary))]);
    return Column(
      children: <Widget>[
        InkWell(
          onTap: onPressed,
          child: DecoratedBox(
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(width: borderSize, color: color),
                  color: color),
              child: Container(
                  width: 150,
                  height: 150,
                  alignment: Alignment.center,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(icon, color: textColor != null ? textColor : ZapOnSecondary),
                    textOutside ? SizedBox() : text
                  ]))
            ),
        ),
        textOutside ? text : SizedBox()
      ],
    );
  }
}

class ListButton extends StatelessWidget {
  ListButton(this.onPressed, this.title) : super();

  final VoidCallback onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: <Widget>[
          Divider(),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(left: 16),
                        child:
                            Text(title, style: TextStyle(color: ZapBlackMed))),
                    Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.chevron_right, color: ZapBlackMed))
                  ])),
        ],
      ),
    );
  }
}

class ListButtonEnd extends StatelessWidget {
  ListButtonEnd() : super();

  @override
  Widget build(BuildContext context) {
    return Divider();
  }
}

class AlertDrawer extends StatelessWidget {
  AlertDrawer(this.onPressed, this.alerts) : super();

  final VoidCallback onPressed;
  final List<String> alerts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: onPressed,
          child: Container(
              color: ZapWarningLight,
              child: Column(
                  children: List<Widget>.generate(alerts.length, (index) {
                return Container(
                    padding: EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: ZapWarning))),
                    child: Text(alerts[index],
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ZapBlackMed)));
              }))),
        ),
      ],
    );
  }
}

class CustomCurve extends CustomPainter {
  CustomCurve(this.color, this.gradient, this.curveStart, this.curveBottom)
      : super();

  final Color color;
  final Gradient? gradient;
  final double curveStart;
  final double curveBottom;

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, curveStart);
    path.quadraticBezierTo(size.width / 2, curveBottom, size.width, curveStart);
    path.lineTo(size.width, 0);
    path.close();
    var paint = Paint();
    if (gradient != null)
      paint.shader = paint.shader =
          gradient!.createShader(Rect.fromLTWH(0, 0, size.width, curveBottom));
    else
      paint.color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
