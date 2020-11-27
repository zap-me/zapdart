import 'package:ZapMerchant/utils.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';

import 'merchant.dart';

const zapgrey =         Color(0xFFF8F6F1);
const zapblue =         Color(0xFF3765CB);
const zapyellow =       Color(0xFFFFBB00);
const zapgreen =        Color(0xFF009075);
const zapwarning =      zapyellow;
const zapwarninglight = Color(0x80FFBB00);
const zapblackmed =     Colors.black54;
const zapblacklight =   Colors.black38;

enum MessageCategory {
  Info,
  Warning,
}

Widget backButton(BuildContext context, {Color color = Colors.white}) {
  return IconButton(icon: Icon(Icons.arrow_back_ios, color: color), onPressed: () => Navigator.of(context).pop(false));
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
    messageText: Text(msg, style: TextStyle(color: zapblue)),
    icon: Icon(icon, size: 28.0, color: category == MessageCategory.Info ? zapblue : zapwarning),
    duration: Duration(seconds: seconds),
    leftBarIndicatorColor: zapblue,
    backgroundColor: Colors.white,
  )..show(context);
}

class RoundedButton extends StatelessWidget {
  RoundedButton(this.onPressed, this.textColor, this.fillColor, this.title, {this.icon, this.borderColor, this.minWidth, this.holePunch = false}) : super();

  final VoidCallback onPressed;
  final Color textColor;
  final Color fillColor;
  final String title;
  final IconData icon;
  final Color borderColor;
  final double minWidth;
  final bool holePunch;

  @override
  Widget build(BuildContext context) {
    var _borderColor = borderColor != null ? borderColor : fillColor;
    var shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: _borderColor));
    Widget text = Text(title, style: TextStyle(color: textColor, fontSize: 14));
    RaisedButton btn;
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
    if (minWidth != null)
      return ButtonTheme(minWidth: minWidth, child: btn);
    return btn;
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
              child: Icon(icon, color: Colors.white)
            )
          ),
        ),
        SizedBox.fromSize(size: Size(1, 12)),
        Text(title, style: TextStyle(fontSize: 10, color: zapblue))
      ],
    );
  }
}

class ListButton extends StatelessWidget {
  ListButton(this.onPressed, this.title, this.last) : super();

  final VoidCallback onPressed;
  final String title;
  final bool last;

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
                Padding(padding: EdgeInsets.only(left: 16), child: Text(title, style: TextStyle(color: zapblackmed))),
                Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.chevron_right, color: zapblackmed))
            ])),
          Visibility(
            visible: last,
            child: Divider()
          )
        ],
      ),
    );
  }
}

class ListTx extends StatelessWidget {
  ListTx(this.onPressed, this.date, this.txid, this.amount, this.merchantRates, this.outgoing, {this.last = false}) : super();

  final VoidCallback onPressed;
  final DateTime date;
  final String txid;
  final Decimal amount;
  final Rates merchantRates;
  final bool outgoing;
  final bool last;

  @override
  Widget build(BuildContext context) {
    var color = outgoing ? zapyellow : zapgreen;
    var tsLeft = TextStyle(fontSize: 12, color: zapblacklight);
    var tsRight = TextStyle(fontSize: 12, color: color);
    var amountText = '${amount.toStringAsFixed(2)} ZAP';
    Widget amountWidget = Text(amountText, style: tsRight);
    if (merchantRates != null) {
      var amountNZD = Text(toNZDAmount(amount, merchantRates), style: tsRight);
      amountWidget = Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        amountWidget,
        amountNZD
      ]);
    }
    var icon = outgoing ? MaterialCommunityIcons.chevron_double_up : MaterialCommunityIcons.chevron_double_down;
    return Column(
      children: <Widget>[
        Divider(),
        ListTile(
          onTap: onPressed,
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
          leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Text(DateFormat('d MMM').format(date).toUpperCase(), style: tsLeft),
            Text(DateFormat('yyyy').format(date), style: tsLeft),
          ]),
          title: Text(txid),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Text(outgoing ? '- ' : '+ ', style: tsRight),
            amountWidget, 
            Icon(icon, color: color, size: 14)]
          )
        ),
        Visibility(
          visible: last,
          child: Divider()
        )
      ]
    );
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
          child: Container(color: zapwarninglight,
            child: Column(
              children: List<Widget>.generate(alerts.length, (index) {
                return Container(
                  padding: EdgeInsets.all(8),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: zapwarning))),
                  child: Text(alerts[index], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54))
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