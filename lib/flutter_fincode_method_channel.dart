import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fincode/flutter_fincode.dart';
import 'package:flutter_fincode/models/fincode_card_details.dart';
import 'package:flutter_fincode/models/fincode_card_info_result.dart';
import 'package:flutter_fincode/models/fincode_register_card_result.dart';

import 'flutter_fincode_platform_interface.dart';

/// An implementation of [FlutterFincodePlatform] that uses method channels.
class MethodChannelFlutterFincode extends FlutterFincodePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_fincode');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<FincodeCardInfoResult> cardInfoList(String customerId) async {
    final dynamic result = await methodChannel.invokeMethod<dynamic>('cardInfoList', {
      'publicKey': FlutterFincode.publicKey,
      'tenantShopId': FlutterFincode.tenantShopId,
      'customerId': customerId,
    });
    return FincodeCardInfoResult.fromJson(result.cast<String, dynamic>());
  }

  @override
  Future<FincodeRegisterCardResult> registerCard(FincodeCardDetails card) async {
    final dynamic result = await methodChannel.invokeMethod<dynamic>('registerCard', {
      'publicKey': FlutterFincode.publicKey,
      'tenantShopId': FlutterFincode.tenantShopId,
      'params': card.toJson(),
    });
    return FincodeRegisterCardResult.fromJson(result.cast<String, dynamic>());
  }

  @override
  Future<dynamic> showPaymentSheet() async {
    return await methodChannel.invokeMethod<void>('showPaymentSheet');
  }
}
