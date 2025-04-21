import 'package:app/core/utils/assets.dart';
import 'package:app/features/auth/data/models/drop_down_menu_item.dart';
import 'package:app/features/auth/presentation/views/widgets/custom_field_label.dart';
import 'package:app/features/auth/presentation/views/widgets/custom_text_form_field.dart';
import 'package:app/features/auth/presentation/views/widgets/drop_down_menu.dart';
import 'package:flutter/material.dart';

class UserDataForm extends StatelessWidget {
  const UserDataForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomFieldLabel(labelText: 'First Name'),
                  CustomTextFormField(
                    hintText: 'Enter your first name',
                    width: 0.42,
                    keyboardType: TextInputType.name,
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomFieldLabel(labelText: 'Last Name'),
                  CustomTextFormField(
                    hintText: 'Enter your last name',
                    width: 0.42,
                    keyboardType: TextInputType.name,
                  ),
                ],
              ),
            ],
          ),
          const CustomFieldLabel(
            labelText: 'Email Address',
            icon: AssetsData.emailIcon,
          ),
          const CustomTextFormField(
            hintText: 'Enter your Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const CustomFieldLabel(
            labelText: 'Birth Of Date',
            icon: AssetsData.dateIcon,
          ),
          CustomTextFormField(
            hintText: '(dd/mm/yyyy)',
            isDatePicker: true,
            onDateSelected: (date) {},
          ),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomFieldLabel(
                    labelText: 'Native Language',
                    icon: AssetsData.languageIcon,
                  ),
                  CustomDropDownMenu(items: DropDownMenuItem.languages),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomFieldLabel(
                    labelText: 'Nationality',
                    icon: AssetsData.nationalityIcon,
                  ),
                  CustomDropDownMenu(items: DropDownMenuItem.nationalities),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
