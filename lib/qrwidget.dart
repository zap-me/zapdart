import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrWidget extends StatefulWidget {
  QrWidget(this.data, {this.size = 200, this.version = 4}) : super();

  final String data;
  final double size;
  final int version;

  @override
  _QrWidgetState createState() => _QrWidgetState();
}

class _QrWidgetState extends State<QrWidget> {
  @override
  Widget build(BuildContext context) {
    return QrImage(
        data: widget.data,
        size: widget.size,
        version: widget.version,
        errorCorrectionLevel: QrErrorCorrectLevel.M);
  }
}
