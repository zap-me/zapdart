import 'package:flutter/material.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

import 'colors.dart';

class PinEntryScreen extends StatefulWidget {
  final String _pin;
  final String _title;

  PinEntryScreen(this._pin, this._title) : super();

  @override
  _PinEntryState createState() => new _PinEntryState();
}

class _PinEntryState extends State<PinEntryScreen> {
  final TextEditingController _controller = TextEditingController(text: "");
  final int _pinLength = 5;
  bool _done = false;
  bool _hasError = false;
  String _errorMessage = 'error';
  final _animDelay = 300;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._title),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 60.0),
                ),
                Container(
                  height: 100,
                  child: PinCodeTextField(
                    autofocus: true,
                    controller: _controller,
                    focusNode: _focusNode,
                    hideCharacter: true,
                    highlight: true,
                    highlightColor: ZapSecondary,
                    defaultBorderColor: ZapBlack,
                    hasTextBorderColor: ZapGreen,
                    maxLength: _pinLength,
                    hasError: _hasError,
                    maskCharacter: "*",
                    onTextChanged: (text) {
                      if (_done) {
                        _done = false;
                      } else {
                        setState(() {
                          _hasError = false;
                        });
                      }
                    },
                    onDone: (text) {
                      if (widget._pin.isNotEmpty) {
                        if (text != widget._pin) {
                          _done = true;
                          setState(() {
                            _errorMessage = "Invalid pin";
                            _hasError = true;
                          });
                          return;
                        }
                      }
                      Future.delayed(Duration(milliseconds: _animDelay), () {
                        Navigator.pop(context, text);
                      });
                    },
                    wrapAlignment: WrapAlignment.spaceAround,
                    pinBoxDecoration:
                        ProvidedPinBoxDecoration.defaultPinBoxDecoration,
                    pinTextStyle: TextStyle(fontSize: 30.0),
                    pinTextAnimatedSwitcherTransition:
                        ProvidedPinBoxTextAnimation.scalingTransition,
                    pinTextAnimatedSwitcherDuration:
                        Duration(milliseconds: _animDelay),
                    highlightAnimationBeginColor: ZapBlack,
                    highlightAnimationEndColor: ZapPrimary,
                    keyboardType: TextInputType.number,
                    pinBoxWidth: 50,
                    pinBoxHeight: 50,
                  ),
                ),
                Visibility(
                  visible: _hasError,
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: ZapRed),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    children: <Widget>[
                      MaterialButton(
                        color: ZapYellow,
                        textColor: ZapPrimary,
                        child: Text("Clear"),
                        onPressed: () {
                          _controller.clear();
                          _focusNode.requestFocus();
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
