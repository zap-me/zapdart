import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image/image.dart' as img;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:intl_phone_number_input/src/utils/phone_number/phone_number_util.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'widgets.dart';
import 'addr_search.dart';
import 'autocomplete_service.dart';
import 'form_ui.dart';

class AccountRegistration {
  final String firstName;
  final String lastName;
  final String email;
  final String mobileNumber;
  final String address;
  final String currentPassword;
  final String newPassword;
  final String? photo;
  final String? photoType;

  AccountRegistration(
      this.firstName,
      this.lastName,
      this.email,
      this.mobileNumber,
      this.address,
      this.currentPassword,
      this.newPassword,
      this.photo,
      this.photoType);
}

class AccountLogin {
  final String email;
  final String password;
  final String tfCode;

  AccountLogin(this.email, this.password, this.tfCode);
}

class AccountRequestApiKey {
  final String email;
  final String deviceName;

  AccountRequestApiKey(this.email, this.deviceName);
}

class ColumnView extends StatelessWidget {
  final Widget? child;
  final bool scrollChild;
  final double maxColumnWidth;
  ColumnView({this.child, this.scrollChild = false, this.maxColumnWidth = 900});

  @override
  Widget build(BuildContext context) {
    var center = Center(
        child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxColumnWidth),
            child: child));
    if (scrollChild) return SingleChildScrollView(child: center);
    return center;
  }
}

Widget accountImage(String? imgString, String? imgType,
    {double size = 70,
    double borderRadius = 10,
    double dropShadowOffsetX = 0,
    double dropShadowOffsetY = 3,
    double dropShadowSpreadRadius = 5,
    double dropShadowBlurRadius = 7}) {
  if (imgString != null && imgString.isNotEmpty) {
    if (imgType == 'raster')
      // if image is raster then apply corner radius and drop shadow
      return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: dropShadowSpreadRadius,
                blurRadius: dropShadowBlurRadius,
                offset: Offset(dropShadowOffsetX, dropShadowOffsetY),
              )
            ],
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              //TODO: BoxFit.cover should not be necesary if the crop aspect ratio is 1/1 (*shrug*)
              child: Image.memory(
                base64Decode(imgString),
                width: size,
                height: size,
                fit: BoxFit.cover,
              )));
    if (imgType == 'svg')
      return SvgPicture.string(imgString, width: size, height: size);
  }
  return SvgPicture.asset('assets/user.svg',
      package: 'zapdart', width: size, height: size);
}

class AccountImageUpdate extends StatelessWidget {
  final Function(String? img, String imgType) _imageUpdate;
  final String? _imgString;
  final String? _imgType;
  final double maxColumnWidth;

  AccountImageUpdate(this._imgString, this._imgType, this._imageUpdate, {this.maxColumnWidth = 900})
      : super();

  Future<String?> _imgDataEdited(BuildContext context, XFile file) async {
    final editorKey = GlobalKey<ExtendedImageEditorState>();
    final imageEditor = ExtendedImage.memory(
      await file.readAsBytes(),
      fit: BoxFit.contain,
      mode: ExtendedImageMode.editor,
      extendedImageEditorKey: editorKey,
      initEditorConfigHandler: (state) {
        return EditorConfig(
            maxScale: 8.0,
            cropRectPadding: EdgeInsets.all(20.0),
            hitTestSize: 20.0,
            cropAspectRatio: CropAspectRatios.ratio1_1);
      },
    );
    await showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.6),
      barrierDismissible: false,
      pageBuilder: (context, __, ___) {
        return SizedBox.expand(
            child: Scaffold(
                body: ColumnView(maxColumnWidth: maxColumnWidth, child: Column(children: [
          Expanded(child: imageEditor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.flip),
                onPressed: () {
                  editorKey.currentState?.flip();
                },
              ),
              IconButton(
                icon: const Icon(Icons.rotate_left),
                onPressed: () {
                  editorKey.currentState?.rotate(right: false);
                },
              ),
              IconButton(
                icon: const Icon(Icons.rotate_right),
                onPressed: () {
                  editorKey.currentState?.rotate(right: true);
                },
              ),
              IconButton(
                icon: const Icon(Icons.restore),
                onPressed: () {
                  editorKey.currentState?.reset();
                },
              ),
              IconButton(
                icon: const Icon(Icons.done),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ]))));
      },
    );
    var editorKeyState = editorKey.currentState;
    if (editorKeyState == null) return null;
    var editAction = editorKeyState.editAction;
    var cropRect = editorKeyState.getCropRect();
    var src = img.decodeImage(editorKeyState.rawImageData);
    if (src == null) return null;
    if (editAction != null && cropRect != null) {
      if (editAction.needCrop)
        src = img.copyCrop(src, cropRect.left.toInt(), cropRect.top.toInt(),
            cropRect.width.toInt(), cropRect.height.toInt());
      if (editAction.needFlip) {
        var mode = img.Flip.horizontal;
        if (editAction.flipY && editAction.flipX)
          mode = img.Flip.both;
        else if (editAction.flipY)
          mode = img.Flip.horizontal;
        else if (editAction.flipX) mode = img.Flip.vertical;
        src = img.flip(src, mode);
      }
      if (editAction.hasRotateAngle)
        src = img.copyRotate(src, editAction.rotateAngle);
    }
    src = img.copyResize(src, width: 200, height: 200);
    var jpgBytes = img.encodeJpg(src, quality: 50);
    return base64Encode(jpgBytes);
  }

  void _imgFromCamera(BuildContext context) async {
    var file = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);
    if (file == null) return;
    var imgString = await _imgDataEdited(context, file);
    _imageUpdate(imgString, 'raster');
  }

  void _imgFromGallery(BuildContext context) async {
    var file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (file == null) return;
    var imgString = await _imgDataEdited(context, file);
    _imageUpdate(imgString, 'raster');
  }

  Widget _imageSizeWidget() {
    if (_imgString == null || _imgString!.isEmpty) return SizedBox();
    var kib = (_imgString!.length / 1000.0).ceil();
    return Text('$kib KiB');
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: 'Profile Image'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            accountImage(_imgString, _imgType),
            SizedBox(width: 25),
            IconButton(
                icon: Icon(Icons.folder_open),
                onPressed: () => _imgFromGallery(context)),
            IconButton(
                icon: Icon(Icons.camera),
                onPressed: () => _imgFromCamera(context)),
            _imageSizeWidget(),
          ]),
        ],
      ),
    );
  }
}

class AccountRegisterForm extends StatefulWidget {
  final AccountRegistration? registration;
  final String? instructions;
  final bool showName;
  final bool showImage;
  final bool showEmail;
  final bool showMobileNumber;
  final bool requireMobileNumber;
  final String? initialMobileCountry;
  final List<String>? preferredMobileCountries;
  final bool showAddress;
  final bool requireAddress;
  final String? googlePlaceApiKey;
  final String? locationIqApiKey;
  final bool showCurrentPassword;
  final bool showNewPassword;
  final double maxColumnWidth;

  AccountRegisterForm(this.registration,
      {this.instructions,
      this.showName: true,
      this.showImage: true,
      this.showEmail: true,
      this.showMobileNumber: false,
      this.requireMobileNumber: false,
      this.initialMobileCountry,
      this.preferredMobileCountries,
      this.showAddress: false,
      this.requireAddress: false,
      this.googlePlaceApiKey,
      this.locationIqApiKey,
      this.showCurrentPassword: false,
      this.showNewPassword: true,
      this.maxColumnWidth: 900})
      : super();

  @override
  AccountRegisterFormState createState() {
    return AccountRegisterFormState();
  }
}

class AccountRegisterFormState extends State<AccountRegisterForm> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _dialCode;
  String? _isoCode;
  bool _valid = false;
  String? _countryCode;
  String? _imgString;
  String? _imgType;

  @protected
  @mustCallSuper
  void initState() {
    super.initState();

    if (widget.registration != null) {
      _firstNameController.text = widget.registration!.firstName;
      _lastNameController.text = widget.registration!.lastName;
      _emailController.text = widget.registration!.email;
      if (widget.registration!.mobileNumber.isNotEmpty)
        PhoneNumber.getRegionInfoFromPhoneNumber(
                widget.registration!.mobileNumber)
            .then((value) {
          setState(() {
            _dialCode = '+${value.dialCode}';
            _countryCode = value.isoCode;
          });
          if (value.phoneNumber != null)
            _mobileNumberController.text =
                value.phoneNumber!.replaceFirst('+${value.dialCode}', '');
        });
      _addressController.text = widget.registration!.address;
      _currentPasswordController.text = widget.registration!.currentPassword;
      _newPasswordController.text = widget.registration!.newPassword;
      _passwordConfirmController.text = widget.registration!.newPassword;
      _imgType = widget.registration!.photoType;
      _imgString = widget.registration!.photo;
    }
  }

  void searchAddr() async {
    final apiClient =
        createPlaceApi(widget.googlePlaceApiKey, widget.locationIqApiKey);
    if (apiClient != null) {
      final Suggestion? result = await showSearch<Suggestion?>(
        context: context,
        delegate: AddressSearch(apiClient),
      );
      if (result != null) _addressController.text = result.description;
    }
  }

  void manualAddr() async {
    var place = await Navigator.push<Place?>(
      context,
      MaterialPageRoute(builder: (context) => AddressForm()),
    );
    if (place != null) _addressController.text = place.toString();
  }

  Future<bool> isValidPhoneNumber(
      String phoneNumber, String? isoCode) async {
    if (phoneNumber.isNotEmpty && isoCode != null) {
      try {
        bool? isValidPhoneNumber = await PhoneNumberUtil.isValidNumber(
            phoneNumber: phoneNumber, isoCode: isoCode);
        if (isValidPhoneNumber == null)
          return false;
        return isValidPhoneNumber;
      } on Exception {
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          child: Container(),
          preferredSize: Size(0, 0),
        ),
        body: ColumnView(scrollChild: true, maxColumnWidth: widget.maxColumnWidth,
            child: Form(
                key: _formKey,
                child: Container(
                    padding: EdgeInsets.all(20),
                    child: Center(
                        child: Column(children: [
                      Text(widget.instructions == null
                          ? 'Enter your details to register'
                          : widget.instructions!),
                      Visibility(
                          visible: widget.showName,
                          child: TextFormField(
                              controller: _firstNameController,
                              decoration:
                                  InputDecoration(labelText: 'First Name'),
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value != null && value.isEmpty)
                                  return 'Please enter a first name';
                                return null;
                              })),
                      Visibility(
                          visible: widget.showName,
                          child: TextFormField(
                              controller: _lastNameController,
                              decoration:
                                  InputDecoration(labelText: 'Last Name'),
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter a last name';
                                return null;
                              })),
                      Visibility(
                          visible: widget.showImage,
                          child: AccountImageUpdate(
                              _imgString,
                              _imgType,
                              (img, imgType) => setState(() {
                                    _imgString = img;
                                    _imgType = imgType;
                                  }))),
                      Visibility(
                          visible: widget.showEmail,
                          child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(labelText: 'Email'),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                value = value?.trim();
                                if (value == null || value.isEmpty)
                                  return 'Please enter an email';
                                if (!EmailValidator.validate(value))
                                  return 'Invalid email';
                                return null;
                              })),
                      Visibility(
                          visible: widget.showMobileNumber,
                          child: phoneNumberInput(_mobileNumberController,
                              (number) {
                                _dialCode = number.dialCode;
                                _isoCode = number.isoCode;
                              },
                              (valid) {
                                if (valid != null)
                                  _valid = valid;
                              },
                              countryCode: _countryCode,
                              initialCountry: widget.initialMobileCountry,
                              preferredCountries:
                                  widget.preferredMobileCountries,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  if (widget.requireMobileNumber)
                                    return 'Invalid phone number';
                                  return null;
                                }
                                if (_isoCode == null || !_valid)
                                  return 'Invalid phone number';
                                return null;
                              })),
                      Visibility(
                          visible: widget.showAddress,
                          child: TextFormField(
                            controller: _addressController,
                            readOnly: true,
                            decoration: InputDecoration(
                                labelText: 'Address',
                                suffix: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      availablePlaceApi(
                                              widget.googlePlaceApiKey,
                                              widget.locationIqApiKey)
                                          ? IconButton(
                                              icon: Icon(Icons.search),
                                              onPressed: searchAddr)
                                          : SizedBox(),
                                      IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: manualAddr),
                                    ])),
                          )),
                      Visibility(
                          visible: widget.showCurrentPassword,
                          child: TextFormField(
                              controller: _currentPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                  labelText: 'Current Password'),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter your current password';
                                return null;
                              })),
                      Visibility(
                          visible: widget.showNewPassword,
                          child: TextFormField(
                              controller: _newPasswordController,
                              obscureText: true,
                              decoration:
                                  InputDecoration(labelText: 'New Password'),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter a new password';
                                return null;
                              })),
                      Visibility(
                          visible: widget.showNewPassword,
                          child: TextFormField(
                              controller: _passwordConfirmController,
                              obscureText: true,
                              decoration: InputDecoration(
                                  labelText: 'Password Confirmation'),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please confirm your password';
                                if (value != _newPasswordController.text)
                                  return 'Password does not match';
                                return null;
                              })),
                      SizedBox(height: 15),
                      raisedButton(
                        child: Text("Ok"),
                        onPressed: () async {
                          if (_formKey.currentState == null) return;
                          if (_formKey.currentState!.validate()) {
                            var accountReg = AccountRegistration(
                                _firstNameController.text,
                                _lastNameController.text,
                                _emailController.text.trim(),
                                '$_dialCode ${_mobileNumberController.text}',
                                _addressController.text,
                                _currentPasswordController.text,
                                _newPasswordController.text,
                                _imgString,
                                _imgType);
                            Navigator.of(context).pop(accountReg);
                          }
                        },
                      ),
                      SizedBox(height: 15),
                      raisedButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ]))))));
  }
}

class AccountLoginForm extends StatefulWidget {
  final AccountLogin? login;
  final String? instructions;
  final bool showTwoFactorCode;
  final double maxColumnWidth;

  AccountLoginForm(this.login, {this.instructions, this.showTwoFactorCode = false, this.maxColumnWidth = 900}) : super();

  @override
  AccountLoginFormState createState() {
    return AccountLoginFormState();
  }
}

class AccountLoginFormState extends State<AccountLoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _tfCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @protected
  @mustCallSuper
  void initState() {
    super.initState();

    if (widget.login != null) {
      _emailController.text = widget.login!.email;
      _passwordController.text = widget.login!.password;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          child: Container(),
          preferredSize: Size(0, 0),
        ),
        body: ColumnView(scrollChild: true, maxColumnWidth: widget.maxColumnWidth, child: Form(
            key: _formKey,
            child: Container(
                padding: EdgeInsets.all(20),
                child: Center(
                    child: Column(
                  children: <Widget>[
                    Text(widget.instructions == null
                        ? "Enter your email and password to login"
                        : widget.instructions!),
                    TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          value = value?.trim();
                          if (value == null || value.isEmpty)
                            return 'Please enter an email';
                          if (!EmailValidator.validate(value))
                            return 'Invalid email';
                          return null;
                        }),
                    TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Password'),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please enter a password';
                          return null;
                        }),
                    Visibility(
                      visible: widget.showTwoFactorCode,
                      child: TextFormField(
                          controller: _tfCodeController,
                          obscureText: true,
                          decoration: InputDecoration(labelText: 'Two Factor Code')
                      )
                    ),
                    SizedBox(height: 15),
                    raisedButton(
                      child: Text("Ok"),
                      onPressed: () {
                        if (_formKey.currentState == null) return;
                        if (_formKey.currentState!.validate()) {
                          var accountLogin = AccountLogin(
                              _emailController.text.trim(), _passwordController.text, _tfCodeController.text);
                          Navigator.of(context).pop(accountLogin);
                        }
                      },
                    ),
                    SizedBox(height: 15),
                    raisedButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ))))));
  }
}

class AccountRequestApiKeyForm extends StatefulWidget {
  final String deviceName;
  final String? instructions;
  final double maxColumnWidth;

  AccountRequestApiKeyForm(this.deviceName, {this.instructions, this.maxColumnWidth = 900}) : super();

  @override
  AccountRequestApiKeyFormState createState() {
    return AccountRequestApiKeyFormState();
  }
}

class AccountRequestApiKeyFormState extends State<AccountRequestApiKeyForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _deviceNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    _deviceNameController.text = widget.deviceName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          child: Container(),
          preferredSize: Size(0, 0),
        ),
        body: ColumnView(scrollChild: true, maxColumnWidth: widget.maxColumnWidth, child: Form(
            key: _formKey,
            child: Container(
                padding: EdgeInsets.all(20),
                child: Center(
                    child: Column(
                  children: <Widget>[
                    Text(widget.instructions == null
                        ? "Enter your email and device name to login via email link"
                        : widget.instructions!),
                    TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          value = value?.trim();
                          if (value == null || value.isEmpty)
                            return 'Please enter an email';
                          if (!EmailValidator.validate(value))
                            return 'Invalid email';
                          return null;
                        }),
                    TextFormField(
                        controller: _deviceNameController,
                        decoration: InputDecoration(labelText: 'Device Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please enter a device name';
                          return null;
                        }),
                    SizedBox(height: 15),
                    raisedButton(
                      child: Text("Ok"),
                      onPressed: () {
                        if (_formKey.currentState == null) return;
                        if (_formKey.currentState!.validate()) {
                          var req = AccountRequestApiKey(_emailController.text.trim(),
                              _deviceNameController.text);
                          Navigator.of(context).pop(req);
                        }
                      },
                    ),
                    SizedBox(height: 15),
                    raisedButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ))))));
  }
}

class AccountUpdateEmailForm extends StatefulWidget {
  final String? instructions;
  final double maxColumnWidth;

  AccountUpdateEmailForm({this.instructions, this.maxColumnWidth = 900}) : super();

  @override
  AccountUpdateEmailFormState createState() {
    return AccountUpdateEmailFormState();
  }
}

class AccountUpdateEmailFormState extends State<AccountUpdateEmailForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _emailController2 = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @protected
  @mustCallSuper
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          child: Container(),
          preferredSize: Size(0, 0),
        ),
        body: ColumnView(scrollChild: true, maxColumnWidth: widget.maxColumnWidth, child: Form(
            key: _formKey,
            child: Container(
                padding: EdgeInsets.all(20),
                child: Center(
                    child: Column(
                  children: <Widget>[
                    Text(widget.instructions == null
                        ? 'Enter your new email address'
                        : widget.instructions!),
                    TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'New Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please enter an email';
                          if (!EmailValidator.validate(value))
                            return 'Invalid email';
                          return null;
                        }),
                    TextFormField(
                        controller: _emailController2,
                        decoration:
                            InputDecoration(labelText: 'New Email Again'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          value = value?.trim();
                          if (value != _emailController.text)
                            return 'Email does not match';
                          return null;
                        }),
                    SizedBox(height: 15),
                    raisedButton(
                      child: Text('Ok'),
                      onPressed: () {
                        if (_formKey.currentState == null) return;
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).pop(_emailController.text.trim());
                        }
                      },
                    ),
                    SizedBox(height: 15),
                    raisedButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ))))));
  }
}
