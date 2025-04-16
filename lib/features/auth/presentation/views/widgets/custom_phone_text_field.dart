import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class CustomPhoneTextField extends StatefulWidget {
  const CustomPhoneTextField({super.key, required this.onNumberChanged});
  final ValueChanged<String> onNumberChanged;

  @override
  State<CustomPhoneTextField> createState() => _CustomPhoneTextFieldState();
}

class _CustomPhoneTextFieldState extends State<CustomPhoneTextField> {
  final TextEditingController _controller = TextEditingController();
  PhoneNumber _currentNumber = PhoneNumber(isoCode: 'EG');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    var w = MediaQuery.sizeOf(context).width;
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.02,
            vertical: h * 0.01,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kNeutral400),
          ),
          child: InternationalPhoneNumberInput(
            onInputChanged: (PhoneNumber number) {
              if (number.phoneNumber != _currentNumber.phoneNumber) {
                _currentNumber = number;
                widget.onNumberChanged(number.phoneNumber ?? '');
              }
            },
            initialValue: _currentNumber,
            textFieldController: _controller,
            autoFocus: true,
            textStyle: TextStyle(
              fontSize: Helper.getResponsiveFontSize(context, fontSize: 20),
            ),
            selectorTextStyle: TextStyle(
              fontSize: Helper.getResponsiveFontSize(context, fontSize: 20),
            ),
            selectorConfig: const SelectorConfig(
              useBottomSheetSafeArea: true,
              showFlags: false,
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            ),
            cursorColor: kNeutral950,
            inputDecoration: InputDecoration(
              contentPadding: EdgeInsets.only(bottom: h * 0.01),
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.number,
            formatInput: false,
          ),
        ),
        Positioned(
          left: w * 0.22,
          child: Container(height: h * 0.08, width: 1, color: kNeutral400),
        ),
      ],
    );
  }
}
