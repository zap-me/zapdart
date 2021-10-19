import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField(Widget title, bool initialValue,
      {FormFieldSetter<bool>? onChanged,
      FormFieldSetter<bool>? onSaved,
      FormFieldValidator<bool>? validator,
      bool autovalidate = false})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<bool> state) {
              return CheckboxListTile(
                dense: state.hasError,
                title: title,
                value: state.value,
                onChanged: (value) {
                  state.didChange(value);
                  if (onChanged != null) onChanged(value);
                },
                subtitle: state.hasError
                    ? Builder(
                        builder: (BuildContext context) => Text(
                          '${state.errorText}',
                          style: TextStyle(color: Theme.of(context).errorColor),
                        ),
                      )
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
              );
            });
}

Widget phoneNumberInput(
    TextEditingController controller, ValueChanged<PhoneNumber> onInputChanged, void Function(bool?) onInputValidated,
    {String? Function(String?)? validator,
    PhoneNumber? initialNumber,
    String? countryCode,
    String? initialCountry,
    List<String>? preferredCountries}) {
  var initialValue = initialNumber;
  if (initialValue == null)
    initialValue = countryCode != null
        ? PhoneNumber(isoCode: countryCode)
        : initialCountry != null
            ? PhoneNumber(isoCode: initialCountry)
            : null;
  return InternationalPhoneNumberInput(
      textFieldController: controller,
      initialValue: countryCode != null
          ? PhoneNumber(isoCode: countryCode)
          : initialCountry != null
              ? PhoneNumber(isoCode: initialCountry)
              : null,
      onInputChanged: onInputChanged,
      onInputValidated: onInputValidated,
      validator: validator,
      selectorConfig: SelectorConfig(
          selectorType: PhoneInputSelectorType.DIALOG,
          countryComparator: preferredCountries != null
              ? (a, b) {
                  if (preferredCountries.contains(a.name)) {
                    var aSlot = preferredCountries.indexOf(a.name!);
                    if (preferredCountries.contains(b.name)) {
                      var bSlot = preferredCountries.indexOf(b.name!);
                      if (aSlot < bSlot)
                        return -1;
                      else
                        return 1;
                    } else
                      return -1;
                  }
                  return 0;
                }
              : null));
}
