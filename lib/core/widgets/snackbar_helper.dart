import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class SnackbarHelper {
  static void show(BuildContext context, String message, {bool isError = false}) {
    toastification.show(
      context: context,
      title: Text(message),
      icon: Icon(isError ? Icons.error_outline : Icons.check_circle_outline, size: 20),
      autoCloseDuration: const Duration(seconds: 3),
      type: isError ? ToastificationType.error : ToastificationType.success,
      style: ToastificationStyle.flat,
      alignment: Alignment.topRight,
      showProgressBar: false,
    );
  }
}
