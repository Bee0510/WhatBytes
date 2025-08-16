import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:whatbytes/core/theme/app_color.dart';

class ToastUtils {
  static void showCustomToast(
    String message, {
    ToastGravity gravity = ToastGravity.SNACKBAR,
    Toast toastLength = Toast.LENGTH_SHORT,
    Color backgroundColor = AppColor.primary,
    Color textColor = Colors.white,
    double fontSize = 12.0,
    int timeInSecForIosWeb = 1,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      timeInSecForIosWeb: timeInSecForIosWeb,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }
}
