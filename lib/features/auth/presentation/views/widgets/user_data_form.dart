import 'package:app/core/utils/assets.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/styles.dart';
import 'package:app/features/auth/data/models/drop_down_menu_item.dart';
import 'package:app/features/auth/presentation/views/widgets/custom_field_label.dart';
import 'package:app/features/auth/presentation/views/widgets/custom_text_form_field.dart';
import 'package:app/features/auth/presentation/views/widgets/drop_down_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserDataForm extends StatelessWidget {
  UserDataForm({super.key});
  final userDataFormKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    var w = MediaQuery.sizeOf(context).width;
    return Form(
      key: userDataFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomFieldLabel(labelText: 'First Name'),
                  CustomTextFormField(
                    hintText: 'Enter your first name',
                    width: 0.42,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[A-Za-z\s'-]"),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomFieldLabel(labelText: 'Last Name'),
                  CustomTextFormField(
                    hintText: 'Enter your last name',
                    width: 0.42,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[A-Za-z\s'-]"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const CustomFieldLabel(
            labelText: 'Email Address',
            icon: AssetsData.emailIcon,
          ),
          CustomTextFormField(
            hintText: 'Enter your Email',
            keyboardType: TextInputType.emailAddress,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9@._-]')),
            ],
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
          const CustomFieldLabel(
            labelText: 'National ID',
            icon: AssetsData.nationalIdIcon,
          ),
          CustomTextFormField(
            hintText: 'Enter your national id number',
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            ],
          ),
          const CustomFieldLabel(
            labelText: 'Passport',
            icon: AssetsData.passportIcon,
          ),
          CustomTextFormField(
            hintText: 'Enter your passport number',
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            ],
          ),
          const CustomFieldLabel(
            labelText: 'Driver License',
            icon: AssetsData.driverLicenseIcon,
          ),
          CustomTextFormField(
            hintText: 'Enter your driver\'s license number',
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomFieldLabel(
                    labelText: 'Height',
                    icon: AssetsData.heightIcon,
                  ),
                  CustomTextFormField(
                    width: 0.42,
                    keyboardType: TextInputType.number,
                    widget: const Text("CM"),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        if (newValue.text.isEmpty) {
                          return newValue;
                        }
                        if (newValue.text.contains('.')) {
                          if (newValue.text.indexOf('.') !=
                              newValue.text.lastIndexOf('.')) {
                            return oldValue;
                          }
                        }
                        return newValue;
                      }),
                    ],
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomFieldLabel(
                    labelText: 'Weight',
                    icon: AssetsData.weightIcon,
                  ),
                  CustomTextFormField(
                    width: 0.42,
                    keyboardType: TextInputType.number,
                    widget: const Text("KG"),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        if (newValue.text.isEmpty) {
                          return newValue;
                        }
                        if (newValue.text.contains('.')) {
                          if (newValue.text.indexOf('.') !=
                              newValue.text.lastIndexOf('.')) {
                            return oldValue;
                          }
                        }
                        return newValue;
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: h * 0.023),
            child: Text(
              'Medical information',
              style: Styles.textStyle18(context).copyWith(color: kMrBlack),
            ),
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
                    labelText: 'Your blood type?',
                    icon: AssetsData.bloodTypeIcon,
                  ),
                  CustomDropDownMenu(items: DropDownMenuItem.bloodTypes),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomFieldLabel(
                    labelText: 'Using a wheelchair?',
                    icon: AssetsData.wheelChairIcon,
                  ),
                  CustomDropDownMenu(items: DropDownMenuItem.yesNo),
                ],
              ),
            ],
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
                    labelText: 'Are you diabetic?',
                    icon: AssetsData.diabetesIcon,
                  ),
                  CustomDropDownMenu(items: DropDownMenuItem.yesNo),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomFieldLabel(
                    labelText: 'Have heart disease?',
                    icon: AssetsData.heartDiseaseIcon,
                  ),
                  CustomDropDownMenu(items: DropDownMenuItem.yesNo),
                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: h * 0.023),
            child: Text(
              'Signs information',
              style: Styles.textStyle18(context).copyWith(color: kMrBlack),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: h * 0.018, left: w * 0.026),
            child: Text(
              'Do you have any scars or tattoos? If so, where are they located?',
              style: Styles.textStyle14(context).copyWith(color: kNeutral600),
            ),
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
                    labelText: 'tattoo',
                    icon: AssetsData.tattooIcon,
                  ),
                  CustomDropDownMenu(items: DropDownMenuItem.tattooPlaces),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomFieldLabel(
                    labelText: 'scar',
                    icon: AssetsData.scarIcon,
                  ),
                  CustomDropDownMenu(items: DropDownMenuItem.tattooPlaces),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
