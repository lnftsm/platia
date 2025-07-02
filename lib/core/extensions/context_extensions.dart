import 'package:flutter/material.dart';
import 'package:platia/l10n/app_localizations.dart';

extension ContextExtensions on BuildContext {
  // Theme extensions
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  // MediaQuery extensions
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => mediaQuery.padding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  // Navigation extensions
  NavigatorState get navigator => Navigator.of(this);
  void pop<T>([T? result]) => navigator.pop(result);
  Future<T?> push<T>(Widget page) =>
      navigator.push<T>(MaterialPageRoute(builder: (_) => page));
  Future<T?> pushReplacement<T>(Widget page) =>
      navigator.pushReplacement<T, T>(MaterialPageRoute(builder: (_) => page));

  // Localization extensions
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  String get languageCode => Localizations.localeOf(this).languageCode;

  // Snackbar extensions
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }

  void showErrorSnackBar(String message) =>
      showSnackBar(message, isError: true);

  // Dialog extensions
  Future<T?> showAlertDialog<T>({
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
  }) {
    return showDialog<T>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () => context.pop(false),
              child: Text(cancelText),
            ),
          if (confirmText != null)
            TextButton(
              onPressed: () {
                context.pop(true);
                onConfirm?.call();
              },
              child: Text(confirmText),
            ),
        ],
      ),
    );
  }

  // Loading dialog
  void showLoadingDialog({String? message}) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message ?? context.l10n.loading),
            ],
          ),
        ),
      ),
    );
  }

  void hideLoadingDialog() => pop();
}
