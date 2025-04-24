// Name validation
String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'This field is required';
  }
  if (value.length < 2) {
    return 'Name must be at least 2 characters';
  }
  return null;
}

// Email validation
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

// Date validation (simple format check)
String? validateDate(String? value) {
  if (value == null || value.isEmpty) {
    return 'Date is required';
  }
  // Add more comprehensive date validation if needed
  return null;
}

// ID/Passport validation
String? validateIdNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'This field is required';
  }
  if (value.length < 5) {
    return 'Enter a valid ID number';
  }
  return null;
}

// Numeric validation (for height/weight)
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
