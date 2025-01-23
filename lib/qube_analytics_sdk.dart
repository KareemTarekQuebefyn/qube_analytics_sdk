library qube_analytics_sdk;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

// User Data Model
class UserData {
  final String userId;
  final String deviceId;
  final String deviceType;
  final int ram;
  final int cpuCores;
  final String ip;
  final String country;

  UserData({
    required this.userId,
    required this.deviceId,
    required this.deviceType,
    required this.ram,
    required this.cpuCores,
    required this.ip,
    required this.country,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'deviceId': deviceId,
        'deviceType': deviceType,
        'ram': ram,
        'cpuCores': cpuCores,
        'ip': ip,
        'country': country,
      };
}

// Screen View Data Model
class ScreenViewData {
  final String screenId;
  final String screenPath;
  final String screenName;
  final DateTime visitDateTime;
  final String sessionId;

  ScreenViewData({
    required this.screenId,
    required this.screenPath,
    required this.screenName,
    required this.visitDateTime,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        'screenId': screenId,
        'screenPath': screenPath,
        'screenName': screenName,
        'visitDateTime': visitDateTime.toIso8601String(),
        'sessionId': sessionId,
      };
}

// Behavior Data Model
class BehaviorData {
  final String actionType;
  final double x;
  final double y;
  final double screenY;
  final DateTime actionDateTime;
  final String sessionId;
  final String userId;
  final String screenId;

  BehaviorData({
    required this.actionType,
    required this.x,
    required this.y,
    required this.screenY,
    required this.actionDateTime,
    required this.sessionId,
    required this.userId,
    required this.screenId,
  });

  Map<String, dynamic> toJson() => {
        'actionType': actionType,
        'x': x,
        'y': y,
        'screenY': screenY,
        'actionDateTime': actionDateTime.toIso8601String(),
        'sessionId': sessionId,
        'userId': userId,
        'screenId': screenId,
      };
}

// Error Data Model
class ErrorData {
  final String sessionId;
  final String userId;
  final String? screenId;
  final String errorMessage;
  final String errorStackTrace;
  final bool isCustom;

  ErrorData({
    required this.sessionId,
    required this.userId,
    this.screenId,
    required this.errorMessage,
    required this.errorStackTrace,
    required this.isCustom,
  });

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'userId': userId,
        'screenId': screenId,
        'errorMessage': errorMessage,
        'errorStackTrace': errorStackTrace,
        'isCustom': isCustom,
      };
}

// Qube Analytics SDK
class QubeAnalyticsSDK {
  static final QubeAnalyticsSDK _instance = QubeAnalyticsSDK._internal();
  factory QubeAnalyticsSDK() => _instance;
  QubeAnalyticsSDK._internal();

  late String sessionId;
  late UserData userData;

  Future<void> initialize(String userId) async {
    sessionId = _generateUniqueId();
    userData = await _collectDeviceData(userId);
    print("SDK Initialized: ${jsonEncode(userData)}");

    // Set error tracking
    FlutterError.onError = (FlutterErrorDetails details) {
      trackError(ErrorData(
        sessionId: sessionId,
        userId: userData.userId,
        errorMessage: details.exceptionAsString(),
        errorStackTrace: details.stack.toString(),
        isCustom: false,
      ));
    };
  }

  String _generateUniqueId() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  Future<UserData> _collectDeviceData(String userId) async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceType = "";
    String deviceId = "";
    int ram = 0;
    int cpuCores = 0;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceType = "Android";
      deviceId = androidInfo.id;
      ram = androidInfo.systemFeatures.length; // Example data
      cpuCores = androidInfo.supported64BitAbis.length; // Example data
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceType = "iOS";
      deviceId = iosInfo.identifierForVendor!;
      ram = 2; // Example data
      cpuCores = 4; // Example data
    }

    return UserData(
      userId: userId,
      deviceId: deviceId,
      deviceType: deviceType,
      ram: ram,
      cpuCores: cpuCores,
      ip: "127.0.0.1",
      country: "Unknown",
    );
  }

  void trackScreenView(ScreenViewData data) {
    print("Screen View: ${jsonEncode(data.toJson())}");
  }

  void trackError(ErrorData data) {
    print("Error: ${jsonEncode(data.toJson())}");
  }

  void trackBehavior(BehaviorData data) {
    print("Behavior: ${jsonEncode(data.toJson())}");
  }
}
