import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

import 'colors.dart';

enum MessageCategory {
  Info,
  Warning,
}

Widget backButton(BuildContext context, {Color? color, void Function()? onPressed}) {
  if (color == null)
    color = ZapWhite;
  return IconButton(icon: Icon(Icons.arrow_back_ios, color: color), onPressed: onPressed != null ? onPressed : () => Navigator.of(context).pop(false));
}

ButtonStyle raisedButtonStyle({Color? primary, EdgeInsetsGeometry? padding, Size? minSize}) {
  primary ??= Colors.grey[300];
  padding ??= EdgeInsets.symmetric(horizontal: 16);
  minSize ??= Size(88, 36);
  return ElevatedButton.styleFrom(
    onPrimary: Colors.black87,
    primary: primary,
    minimumSize: minSize,
    padding: padding,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
  );
}

Widget raisedButton({required void Function()? onPressed, required Widget? child, Color? primary, EdgeInsetsGeometry? padding, Size? minSize}) {
  return ElevatedButton(onPressed: onPressed, child: child, style: raisedButtonStyle(primary: primary, padding: padding, minSize: minSize));
}

Widget raisedButtonIcon({required void Function()? onPressed, required Widget icon, required Widget label, Color? primary, EdgeInsetsGeometry? padding, Size? minSize}) {
  return ElevatedButton.icon(onPressed: onPressed, icon: icon, label: label, style: raisedButtonStyle(primary: primary, padding: padding, minSize: minSize));
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

Widget flatButton({required void Function()? onPressed, required Widget child}) {
  return TextButton(onPressed: onPressed, child: child, style: flatButtonStyle());
}

Widget flatButtonIcon({required void Function()? onPressed, required Widget icon, required Widget label}) {
  return TextButton.icon(onPressed: onPressed, icon: icon, label: label, style: flatButtonStyle());
}

void flushbarMsg(BuildContext context, String msg, {int seconds = 3, MessageCategory category = MessageCategory.Info}) {
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
    messageText: Text(msg, style: TextStyle(color: ZapBlue)),
    icon: Icon(icon, size: 28.0, color: category == MessageCategory.Info ? ZapBlue : ZapWarning),
    duration: Duration(seconds: seconds),
    leftBarIndicatorColor: ZapBlue,
    backgroundColor: ZapWhite,
  )..show(context);
}

class RoundedButton extends StatelessWidget {
  RoundedButton(this.onPressed, this.textColor, this.fillColor, this.title, {this.icon, this.borderColor, this.minWidth = 88, this.holePunch = false}) : super();

  final VoidCallback onPressed;
  final Color textColor;
  final Color fillColor;
  final String title;
  final IconData? icon;
  final Color? borderColor;
  final double minWidth;
  final bool holePunch;

  @override
  Widget build(BuildContext context) {
    var _borderColor = borderColor != null ? borderColor : fillColor;
    var shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: _borderColor!));
    Widget text = Text(title, style: TextStyle(color: textColor, fontSize: 14));
    Widget btn;
    if (icon != null && holePunch)
      throw ArgumentError('Can only use "icon" parameter OR "fwdArrowColor"');
    if (icon != null)
      btn = RaisedButton.icon(onPressed: onPressed,
        icon: Icon(icon, color: textColor, size: 14), label: text,
        shape: shape, color: fillColor);
    else {
      Widget child = text;
      if (holePunch) {
        // this is a hack, there is no drop shadow in the hole punch, and it is not aligned with the border
        var icon = Container(width: 20, height: 20, decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
          child: Icon(Icons.arrow_forward_ios, size: 14, color: fillColor));
        child = Container(width: minWidth - 16 - 16,
         child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[SizedBox(width: 14), text, icon]));
      }
      btn = RaisedButton(onPressed: onPressed,
        child: child,
        shape: shape, color: fillColor);
    }
    return ButtonTheme(minWidth: minWidth, child: btn);
  }
}

class SquareButton extends StatelessWidget {
  SquareButton(this.onPressed, this.icon, this.color, this.title) : super();

  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: onPressed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 5.0, color: color),
              color: color
            ),
            child: Container(
              padding: EdgeInsets.all(30),
              child: Icon(icon, color: ZapWhite)
            )
          ),
        ),
        SizedBox.fromSize(size: Size(1, 12)),
        Text(title, style: TextStyle(fontSize: 10, color: ZapBlue))
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
          Padding(padding: EdgeInsets.symmetric(vertical: 8), child: 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 16), child: Text(title, style: TextStyle(color: ZapBlackMed))),
                Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.chevron_right, color: ZapBlackMed))
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
          child: Container(color: ZapWarningLight,
            child: Column(
              children: List<Widget>.generate(alerts.length, (index) {
                return Container(
                  padding: EdgeInsets.all(8),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: ZapWarning))),
                  child: Text(alerts[index], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ZapBlackMed))
                );
              })
            )
          ),
        ),
      ],
    );
  }
}

class CustomCurve extends CustomPainter{
  CustomCurve(this.color, this.curveStart, this.curveBottom) : super();

  final Color color;
  final double curveStart;
  final double curveBottom;

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    var paint = Paint();
    path.moveTo(0, 0);
    path.lineTo(0, curveStart);
    path.quadraticBezierTo(size.width / 2, curveBottom, size.width, curveStart);
    path.lineTo(size.width, 0);
    path.close();
    paint.color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

}