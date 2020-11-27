import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

class PinEntryScreen extends StatefulWidget {
  final String _pin;
  final String _title;

  PinEntryScreen(this._pin, this._title) : super();

  @override
  _PinEntryState createState() => new _PinEntryState();
}

class _PinEntryState extends State<PinEntryScreen> {
  TextEditingController controller = TextEditingController(text: "");
  int _pinLength = 4;
  bool _done = false;
  bool _hasError = false;
  String _errorMessage = 'error';
  FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
              ),
              Container(
                height: 100.0,
                child: PinCodeTextField(
                  autofocus: true,
                  controller: controller,
                  focusNode: focusNode,
                  hideCharacter: true,
                  highlight: true,
                  highlightColor: Colors.blue,
                  defaultBorderColor: Colors.black,
                  hasTextBorderColor: Colors.green,
                  maxLength: _pinLength,
                  hasError: _hasError,
                  maskCharacter: "😎",
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
                    if (widget._pin != null) {
                      if (text != widget._pin) {
                        _done = true;
                        setState(() {
                          _errorMessage = "Invalid pin";
                          _hasError = true;
                        });
                        return;
                      }
                    }
                    Navigator.pop(context, text);
                  },
                  wrapAlignment: WrapAlignment.spaceAround,
                  pinBoxDecoration: ProvidedPinBoxDecoration.defaultPinBoxDecoration,
                  pinTextStyle: TextStyle(fontSize: 30.0),
                  pinTextAnimatedSwitcherTransition: ProvidedPinBoxTextAnimation.scalingTransition,
                  pinTextAnimatedSwitcherDuration: Duration(milliseconds: 300),
                  highlightAnimationBeginColor: Colors.black,
                  highlightAnimationEndColor: Colors.white12,
                  keyboardType: TextInputType.number,
                ),

              ),
              Visibility(
                visible: _hasError,
                child: Text(_errorMessage, style: TextStyle(color: Colors.red),),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  children: <Widget>[
                    MaterialButton(
                      color: Colors.pink,
                      textColor: Colors.white,
                      child: Text("Clear"),
                      onPressed: () {
                        controller.clear();
                        focusNode.requestFocus();
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}