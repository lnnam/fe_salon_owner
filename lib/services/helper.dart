import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:salonapp/constants.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salonapp/model/user.dart';
import 'package:provider/provider.dart';
import 'package:salonapp/provider/setting.provider.dart';

import 'dart:io' show Platform;

String? validateFeild(String? value) {
  if (value?.isEmpty ?? true) {
    return 'feildIsRequired'.tr();
  }
  return null;
}

String? validateName(String? value) {
  String pattern = r'(^[a-zA-Z ]*$)';
  RegExp regExp = RegExp(pattern);
  if (value?.isEmpty ?? true) {
    return 'nameIsRequired'.tr();
  } else if (!regExp.hasMatch(value ?? '')) {
    return 'nameMustBeValid'.tr();
  }
  return null;
}

String? validateSalonID(String? value) {
  String pattern = r'(^[a-zA-Z ]*$)';
  RegExp regExp = RegExp(pattern);
  if (value?.isEmpty ?? true) {
    return 'salonidIsRequired'.tr();
  } else if (!regExp.hasMatch(value ?? '')) {
    return 'salonidMustBeValid'.tr();
  }
  return null;
}

String? validateMobile(String? value) {
  String pattern = r'(^\+?[0-9]*$)';
  RegExp regExp = RegExp(pattern);
  if (value?.isEmpty ?? true) {
    return 'mobileIsRequired'.tr();
  } else if (!regExp.hasMatch(value ?? '')) {
    return 'mobileNumberMustBeDigits'.tr();
  }
  return null;
}

String? validatePassword(String? value) {
  if ((value?.length ?? 0) < 5) {
    return 'passwordLength'.tr();
  } else {
    return null;
  }
}

String? validateEmail(String? value) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(value ?? '')) {
    return 'validEmail'.tr();
  } else {
    return null;
  }
}

String? validateConfirmPassword(String? password, String? confirmPassword) {
  if (password != confirmPassword) {
    return 'passwordNoMatch'.tr();
  } else if (confirmPassword?.isEmpty ?? true) {
    return 'confirmPassReq'.tr();
  } else {
    return null;
  }
}

//helper method to show progress
late ProgressDialog progressDialog;

showProgress(BuildContext context, String message, bool isDismissible) async {
  progressDialog = ProgressDialog(context,
      type: ProgressDialogType.download, isDismissible: isDismissible);
  progressDialog.style(
      message: message,
      borderRadius: 10.0,
      backgroundColor: const Color(COLOR_PRIMARY),
      progressWidget: Container(
          padding: const EdgeInsets.all(8.0),
          child: const CircularProgressIndicator.adaptive(
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
          )),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: const TextStyle(
          color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.w600));
  await progressDialog.show();
}

updateProgress(String message) {
  progressDialog.update(message: message);
}

hideProgress() async {
  await progressDialog.hide();
}

//helper method to show alert dialog
showAlertDialog(BuildContext context, String title, String content) {
  // set up the AlertDialog
  Widget okButton = TextButton(
    child: const Text('ok').tr(),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // Schedule dialog presentation for next frame to avoid mutating the
  // render tree during hit-testing or pointer processing.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!kIsWeb && Platform.isIOS) {
      final CupertinoAlertDialog alert = CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          okButton,
        ],
      );
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => alert,
      );
    } else {
      final AlertDialog alert = AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          okButton,
        ],
      );
      showDialog(
        context: context,
        builder: (BuildContext context) => alert,
      );
    }
  });
}

/// Present a dialog in the next frame to avoid modifying the widget tree
/// while the framework is performing hit-testing/layout.
void safeShowDialog(
    BuildContext context, Widget Function(BuildContext) builder) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(context: context, builder: builder);
  });
}

/// Safe variant for Cupertino dialogs.
void safeShowCupertinoDialog(
    BuildContext context, Widget Function(BuildContext) builder) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showCupertinoDialog(context: context, builder: builder);
  });
}

myPopup(context, txt) {
  showDialog(
      context: context,
      builder: (ctxt) => AlertDialog(
            title: Text(txt),
          ));
}

pushReplacement(BuildContext context, Widget destination) {
  // Delegate to safe navigation to avoid performing route changes during layout
  safePushReplacement(context, destination);
}

push(BuildContext context, Widget destination) {
  // Delegate to safe navigation helper
  safePush(context, destination);
}

pushAndRemoveUntil(BuildContext context, Widget destination, bool predict) {
  // Keep the original signature but delegate to the safe variant. The
  // `predict` boolean is converted into a RoutePredicate that returns the
  // same boolean for any route.
  safePushAndRemoveUntil(
    context,
    destination,
    (Route<dynamic> route) => predict,
  );
}

/// Safe navigation helpers: schedule navigation for the next frame to avoid
/// performing route changes while layout/hit testing is in progress.
void safePush(BuildContext context, Widget destination) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => destination));
  });
}

void safePushReplacement(BuildContext context, Widget destination) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => destination));
  });
}

void safePushAndRemoveUntil(
    BuildContext context, Widget destination, RoutePredicate predicate) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => destination), predicate);
  });
}

// Named-route safe navigation helpers
void safePushNamed(BuildContext context, String routeName,
    {Object? arguments}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  });
}

void safePushReplacementNamed(BuildContext context, String routeName,
    {Object? arguments}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  });
}

void safePushNamedAndRemoveUntil(
    BuildContext context, String routeName, RoutePredicate predicate,
    {Object? arguments}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, predicate,
        arguments: arguments);
  });
}

String formatTimestamp(int timestamp) {
  var format = DateFormat('hh:mm a');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return format.format(date);
}

String setLastSeen(int seconds) {
  var format = DateFormat('hh:mm a');
  var date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  var diff = DateTime.now().millisecondsSinceEpoch - (seconds * 1000);
  if (diff < 24 * HOUR_MILLIS) {
    return format.format(date);
  } else if (diff < 48 * HOUR_MILLIS) {
    return 'yesterdayAtTime'.tr(args: [format.format(date)]);
  } else {
    format = DateFormat('MMM d');
    return format.format(date);
  }
}

Widget displayCircleImage(String picUrl, double size, hasBorder) =>
    CachedNetworkImage(
        height: size,
        width: size,
        imageBuilder: (context, imageProvider) =>
            _getCircularImageProvider(imageProvider, size, false),
        imageUrl: picUrl,
        placeholder: (context, url) =>
            _getPlaceholderOrErrorImage(size, hasBorder),
        errorWidget: (context, url, error) =>
            _getPlaceholderOrErrorImage(size, hasBorder));

Widget _getPlaceholderOrErrorImage(double size, hasBorder) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xff7c94b6),
        borderRadius: BorderRadius.all(Radius.circular(size / 2)),
        border: Border.all(
          color: Colors.white,
          style: hasBorder ? BorderStyle.solid : BorderStyle.none,
          width: 2.0,
        ),
      ),
      child: ClipOval(
          child: Image.asset(
        'assets/images/placeholder.jpg',
        fit: BoxFit.cover,
        height: size,
        width: size,
      )),
    );

Widget _getCircularImageProvider(
    ImageProvider provider, double size, bool hasBorder) {
  return ClipOval(
      child: Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(size / 2)),
        border: Border.all(
          color: Colors.white,
          style: hasBorder ? BorderStyle.solid : BorderStyle.none,
          width: 2.0,
        ),
        image: DecorationImage(
          image: provider,
          fit: BoxFit.cover,
        )),
  ));
}

bool isDarkMode(BuildContext context) {
  if (Theme.of(context).brightness == Brightness.light) {
    return false;
  } else {
    return false;
  }
}

String updateTime(Timer timer) {
  Duration callDuration = Duration(seconds: timer.tick);
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  String twoDigitsHours(int n) {
    if (n >= 10) return '$n:';
    if (n == 0) return '';
    return '0$n:';
  }

  String twoDigitMinutes = twoDigits(callDuration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(callDuration.inSeconds.remainder(60));
  return '${twoDigitsHours(callDuration.inHours)}$twoDigitMinutes:$twoDigitSeconds';
}

String audioMessageTime(Duration? audioDuration) {
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  String twoDigitsHours(int n) {
    if (n >= 10) return '$n:';
    if (n == 0) return '';
    return '0$n:';
  }

  String twoDigitMinutes =
      twoDigits(audioDuration?.inMinutes.remainder(60) ?? 0);
  String twoDigitSeconds =
      twoDigits(audioDuration?.inSeconds.remainder(60) ?? 0);
  return '${twoDigitsHours(audioDuration?.inHours ?? 0)}$twoDigitMinutes:$twoDigitSeconds';
}

logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // Clear ONLY authentication-related data from SharedPreferences
  await prefs.remove('token');
  await prefs.remove('objuser');
  
  // Keep app preferences (but clear user-specific settings)
  // Clear: app settings, booking settings (these are user-specific)
  // Keep: language, theme (these are user preferences)
  await prefs.remove('appSettings');
  await prefs.remove('bookingSettings');
  
  print('[logout] Cleared auth & user-specific data:');
  print('  - token');
  print('  - objuser');
  print('  - appSettings');
  print('  - bookingSettings');
  print('[logout] Preserved user preferences: language, theme, etc');
  
  // Reset provider state if context is still mounted
  if (context.mounted) {
    try {
      final settingProvider = Provider.of<SettingProvider>(context, listen: false);
      settingProvider.resetSettings();
      print('[logout] Reset SettingProvider state');
    } catch (e) {
      print('[logout] Could not reset provider: $e');
    }
  }
  
  if (!context.mounted) return;
  safePushReplacementNamed(context, '/login');
}

Future<User> getCurrentUser() async {
  final prefs = await SharedPreferences.getInstance();
  final userData = prefs.getString('objuser') ?? '{}';
  final userJson = json.decode(userData);
  return User.fromJson(userJson);
}

ImageProvider? getImage(String base64String) {
  // Synchronous decoding can be expensive and cause layout/hittest
  // races when performed during list builds. We avoid decoding here.
  // If the image has already been decoded and cached, return it.
  try {
    if (_imageCache.containsKey(base64String)) return _imageCache[base64String];
  } catch (_) {}
  return null;
}

final Map<String, MemoryImage> _imageCache = {};

/// Decode a base64 image asynchronously and store it in an in-memory cache.
Future<ImageProvider?> decodeBase64Image(String base64String) async {
  try {
    final bytes =
        await Future(() => base64Decode(base64String.split(',').last));
    final image = MemoryImage(bytes);
    _imageCache[base64String] = image;
    return image;
  } catch (e) {
    return null;
  }
}

String formatBookingTime(dynamic bookingTime) {
  try {
    if (bookingTime is DateTime) {
      return DateFormat('HH:mm').format(bookingTime);
    } else if (bookingTime is String && bookingTime.isNotEmpty) {
      try {
        return DateFormat('HH:mm')
            .format(DateFormat('HH:mm').parse(bookingTime));
      } catch (_) {
        return DateFormat('HH:mm').format(DateTime.parse(bookingTime));
      }
    }
  } catch (_) {
    // ignore and fallback
  }
  return bookingTime.toString();
}
