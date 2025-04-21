import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/styles.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.controller,
    this.validator,
    this.width,
    this.keyboardType,
    this.isDatePicker = false,
    this.onDateSelected,
  });
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final double? width;
  final TextInputType? keyboardType;
  final String hintText;
  final bool isDatePicker;
  final Function(DateTime)? onDateSelected;

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.sizeOf(context).width;
    final TextEditingController textController =
        controller ?? TextEditingController();

    return SizedBox(
      width: width != null ? w * width! : null,
      child: TextFormField(
        controller: textController,
        validator: validator,
        keyboardType: isDatePicker ? null : keyboardType,
        readOnly: isDatePicker,
        style: Styles.textStyle14(
          context,
        ).copyWith(color: kNeutral950, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Styles.textStyle12(context).copyWith(color: kNeutral600),
          errorStyle: Styles.textStyle12(
            context,
          ).copyWith(color: kEmergency500),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kNeutral200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kNeutral950),
          ),
        ),
        onTap:
            isDatePicker
                ? () => _selectDate(context, textController, onDateSelected)
                : null,
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    Function(DateTime)? onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      String formattedDate =
          "${picked.day.toString().padLeft(2, '0')}/"
          "${picked.month.toString().padLeft(2, '0')}/"
          "${picked.year}";

      controller.text = formattedDate;

      if (onDateSelected != null) {
        onDateSelected(picked);
      }
    }
  }
}
