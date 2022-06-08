
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPay {
  static const MethodChannel _channel = MethodChannel('flutter_pay');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
