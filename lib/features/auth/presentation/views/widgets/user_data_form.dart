import 'package:app/core/utils/assets.dart';
import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/styles.dart';
import 'package:app/features/auth/data/models/drop_down_menu_item.dart';
import 'package:app/features/auth/data/repos/validation_repos.dart';
import 'package:app/features/auth/presentation/views/widgets/custom_field_label.dart';
import 'package:app/features/auth/presentation/views/widgets/custom_text_form_field.dart';
import 'package:app/features/auth/presentation/views/widgets/drop_down_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserDataForm extends StatefulWidget {
  const UserDataForm({super.key});

  @override
  State<UserDataForm> createState() => UserDataFormState();
}

class UserDataFormState extends State<UserDataForm> {
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  String bloodType = '';
  String wheelchair = 'No';
  String diabetes = 'No';
  String heartDisease = 'No';
  String tattooLocation = 'None';
  String scarLocation = 'None';
  String nativeLanguage = '';
  String nationality = '';
  String gender = '';

  void setGender(String value) {
    setState(() {
      gender = value;
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    dobController.dispose();
    nationalIdController.dispose();
    passportController.dispose();
    driverLicenseController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  Map<String, dynamic> getFormData() {
    return {
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'email': emailController.text,
      'birthDate': dobController.text,
      'nid': nationalIdController.text,
      'passport': passportController.text,
      'driverLicense': driverLicenseController.text,
      'height': heightController.text,
      'weight': weightController.text,
      'bloodType': bloodType,
      'wheelchair': wheelchair == 'Yes',
      'diabetes': diabetes == 'Yes',
      'heartDisease': heartDisease == 'Yes',
      'tattoo': tattooLocation != 'None' ? tattooLocation : '',
      'scar': scarLocation != 'None' ? scarLocation : '',
      'nativeLanguage': nativeLanguage,
      'nationality': nationality,
      'gender': gender,
    };
  }

  bool validateForm() {
    if (autovalidateMode == AutovalidateMode.disabled) {
      setState(() {
        autovalidateMode = AutovalidateMode.onUserInteraction;
      });
    }
    return userDataFormKey.currentState?.validate() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;
    var w = MediaQuery.sizeOf(context).width;

    return Form(
      key: userDataFormKey,
      autovalidateMode: autovalidateMode,
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
                    controller: firstNameController,
                    validator: validateName,
                    hintText: 'Enter your first name',
                    width: 0.42,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[A-Za-z\s'-]"),
                      ),
                    ],
                    onChanged: (value) {
                      if (autovalidateMode ==
                          AutovalidateMode.onUserInteraction) {
                        userDataFormKey.currentState?.validate();
                      }
                    },
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomFieldLabel(labelText: 'Last Name'),
                  CustomTextFormField(
                    controller: lastNameController,
                    validator: validateName,
                    hintText: 'Enter your last name',
                    width: 0.42,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[A-Za-z\s'-]"),
                      ),
                    ],
                    onChanged: (value) {
                      // This will trigger validation if autovalidateMode is onUserInteraction
                      if (autovalidateMode ==
                          AutovalidateMode.onUserInteraction) {
                        userDataFormKey.currentState?.validate();
                      }
                    },
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
            controller: emailController,
            validator: validateEmail,
            hintText: 'Enter your Email',
            keyboardType: TextInputType.emailAddress,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9@._-]')),
            ],
            onChanged: (value) {
              // This will trigger validation if autovalidateMode is onUserInteraction
              if (autovalidateMode == AutovalidateMode.onUserInteraction) {
                userDataFormKey.currentState?.validate();
              }
            },
          ),
          const CustomFieldLabel(
            labelText: 'Birth Of Date',
            icon: AssetsData.dateIcon,
          ),
          CustomTextFormField(
            controller: dobController,
            validator: validateDate,
            hintText: '(dd/mm/yyyy)',
            isDatePicker: true,
            onDateSelected: (date) {
              setState(() {
                dobController.text =
                    "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
              });
            },
            onChanged: (value) {
              if (autovalidateMode == AutovalidateMode.onUserInteraction) {
                userDataFormKey.currentState?.validate();
              }
            },
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomFieldLabel(
                    labelText: 'Native Language',
                    icon: AssetsData.languageIcon,
                  ),
                  CustomDropDownMenu(
                    items: DropDownMenuItem.languages,
                    onChanged: (value) {
                      setState(() {
                        nativeLanguage = value ?? '';
                      });
                    },
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomFieldLabel(
                    labelText: 'Nationality',
                    icon: AssetsData.nationalityIcon,
                  ),
                  CustomDropDownMenu(
                    items: DropDownMenuItem.nationalities,
                    onChanged: (value) {
                      setState(() {
                        nationality = value ?? '';
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const CustomFieldLabel(
            labelText: 'National ID',
            icon: AssetsData.nationalIdIcon,
          ),
          CustomTextFormField(
            controller: nationalIdController,
            validator: validateIdNumber,
            hintText: 'Enter your national id number',
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            ],
            onChanged: (value) {
              if (autovalidateMode == AutovalidateMode.onUserInteraction) {
                userDataFormKey.currentState?.validate();
              }
            },
          ),
          const CustomFieldLabel(
            labelText: 'Passport',
            icon: AssetsData.passportIcon,
          ),
          CustomTextFormField(
            controller: passportController,
            validator: validateIdNumber,
            hintText: 'Enter your passport number',
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            ],
            onChanged: (value) {
              if (autovalidateMode == AutovalidateMode.onUserInteraction) {
                userDataFormKey.currentState?.validate();
              }
            },
          ),
          const CustomFieldLabel(
            labelText: 'Driver License',
            icon: AssetsData.driverLicenseIcon,
          ),
          CustomTextFormField(
            controller: driverLicenseController,
            validator: validateIdNumber,
            hintText: 'Enter your driver\'s license number',
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            ],
            onChanged: (value) {
              if (autovalidateMode == AutovalidateMode.onUserInteraction) {
                userDataFormKey.currentState?.validate();
              }
            },
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
                    controller: heightController,
                    validator: (value) => validateNumeric(value, 'Height'),
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
                    onChanged: (value) {
                      if (autovalidateMode ==
                          AutovalidateMode.onUserInteraction) {
                        userDataFormKey.currentState?.validate();
                      }
                    },
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
                    controller: weightController,
                    validator: (value) => validateNumeric(value, 'Weight'),
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
                    onChanged: (value) {
                      if (autovalidateMode ==
                          AutovalidateMode.onUserInteraction) {
                        userDataFormKey.currentState?.validate();
                      }
                    },
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomFieldLabel(
                    labelText: 'Your blood type?',
                    icon: AssetsData.bloodTypeIcon,
                  ),
                  CustomDropDownMenu(
                    items: DropDownMenuItem.bloodTypes,
                    onChanged: (value) {
                      setState(() {
                        bloodType = value ?? '';
                      });
                    },
                    initialValue:
                        bloodType, // Optional: pass current value to preserve selection
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomFieldLabel(
                    labelText: 'Using a wheelchair?',
                    icon: AssetsData.wheelChairIcon,
                  ),
                  CustomDropDownMenu(
                    items: DropDownMenuItem.yesNo,
                    onChanged: (value) {
                      setState(() {
                        wheelchair = value ?? 'No';
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomFieldLabel(
                    labelText: 'Are you diabetic?',
                    icon: AssetsData.diabetesIcon,
                  ),
                  CustomDropDownMenu(
                    items: DropDownMenuItem.yesNo,
                    onChanged: (value) {
                      setState(() {
                        diabetes = value ?? 'No';
                      });
                    },
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomFieldLabel(
                    labelText: 'Have heart disease?',
                    icon: AssetsData.heartDiseaseIcon,
                  ),
                  CustomDropDownMenu(
                    items: DropDownMenuItem.yesNo,
                    onChanged: (value) {
                      setState(() {
                        heartDisease = value ?? 'No';
                      });
                    },
                  ),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomFieldLabel(
                    labelText: 'tattoo',
                    icon: AssetsData.tattooIcon,
                  ),
                  CustomDropDownMenu(
                    items: DropDownMenuItem.tattooPlaces,
                    onChanged: (value) {
                      setState(() {
                        tattooLocation = value ?? 'None';
                      });
                    },
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomFieldLabel(
                    labelText: 'scar',
                    icon: AssetsData.scarIcon,
                  ),
                  CustomDropDownMenu(
                    items: DropDownMenuItem.tattooPlaces,
                    onChanged: (value) {
                      setState(() {
                        scarLocation = value ?? 'None';
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
