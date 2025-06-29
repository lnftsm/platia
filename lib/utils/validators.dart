import 'package:platia/l10n/app_localizations.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.emailRequired;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return l10n.invalidEmail;
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.passwordRequired;
    }

    if (value.length < 6) {
      return l10n.passwordTooShort;
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.fieldRequired;
    }

    if (value.trim().length < 2) {
      return l10n.nameTooShort;
    }

    // Check for valid characters (letters, spaces, some special chars)
    final nameRegex = RegExp(r'^[a-zA-ZçğıöşüÇĞIİÖŞÜ\s\-\.]+$');
    if (!nameRegex.hasMatch(value)) {
      return l10n.invalidName;
    }

    return null;
  }

  // Phone validation (Turkish format)
  static String? validatePhone(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.fieldRequired;
    }

    // Remove spaces, dashes, parentheses
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Turkish phone number formats:
    // +90 5XX XXX XX XX
    // 0 5XX XXX XX XX
    // 5XX XXX XX XX
    final phoneRegex = RegExp(r'^(\+90|0)?[5][0-9]{9}$');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return l10n.phoneNumberInvalid;
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(
    String? value,
    String? password,
    AppLocalizations l10n,
  ) {
    if (value == null || value.isEmpty) {
      return l10n.passwordRequired;
    }

    if (value != password) {
      return l10n.passwordsDontMatch;
    }

    return null;
  }

  // General field validation
  static String? validateRequired(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.fieldRequired;
    }
    return null;
  }

  // Age validation (for birth date)
  static String? validateAge(DateTime? birthDate, AppLocalizations l10n) {
    if (birthDate == null) {
      return l10n.fieldRequired;
    }

    final now = DateTime.now();
    final age = now.year - birthDate.year;

    if (age < 13) {
      return l10n.ageTooYoung;
    }

    if (age > 120) {
      return l10n.invalidBirthDate;
    }

    return null;
  }

  // KVKK consent validation
  static String? validateKvkkConsent(bool? accepted, AppLocalizations l10n) {
    if (accepted != true) {
      return l10n.acceptTermsRequired;
    }
    return null;
  }
}
