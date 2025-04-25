String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'This field is required';
  }
  if (value.length < 2) {
    return 'At least 2 characters';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Enter a valid email address';
  }
  return null;
}

String? validateDate(String? value) {
  if (value == null || value.isEmpty) {
    return 'Date is required';
  }
  return null;
}

String? validateIdNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'This field is required';
  }
  if (value.length < 5) {
    return 'Enter a valid ID number';
  }
  return null;
}

String? validateNumeric(String? value, String fieldName) {
  if (value == null || value.isEmpty) {
    return '$fieldName is required';
  }
  final numericValue = double.tryParse(value);
  if (numericValue == null) {
    return 'Enter a valid number';
  }
  if (numericValue <= 0) {
    return 'Value must be greater than 0';
  }
  return null;
}
