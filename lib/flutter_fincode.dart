
import 'package:flutter_fincode/models/errors.dart';
import 'package:flutter_fincode/models/fincode_card_details.dart';
import 'package:flutter_fincode/models/fincode_card_info_result.dart';
import 'package:flutter_fincode/models/fincode_register_card_result.dart';

import 'flutter_fincode_platform_interface.dart';

class FlutterFincode {

  FlutterFincode._();

  static set publishableKey(String value) {
    if (value == instance._publishableKey) {
      return;
    }
    instance._publishableKey = value;
  }

  static set tenantShopId(String value) {
    if (value == instance._tenantShopId) {
      return;
    }
    instance._tenantShopId = value;
  }

  /// Retrieves the publishable API key.
  static String get publishableKey {
    if (instance._publishableKey == null) {
      throw const FincodeConfigException('Publishable key is not set');
    }
    return instance._publishableKey!;
  }

  /// Retrieves the tenant shop ID.
  static String get tenantShopId {
    if (instance._tenantShopId == null) {
      throw const FincodeConfigException('Tenant shop ID is not set');
    }
    return instance._tenantShopId!;
  }

  static final FlutterFincode instance = FlutterFincode._();

  String? _publishableKey;
  String? _tenantShopId;

  Future<String?> getPlatformVersion() {
    return FlutterFincodePlatform.instance.getPlatformVersion();
  }

  Future<FincodeCardInfoResult> cardInfoList(String customerId) {
    return FlutterFincodePlatform.instance.cardInfoList(customerId);
  }

  Future<FincodeRegisterCardResult> registerCard(FincodeCardDetails card) {
    return FlutterFincodePlatform.instance.registerCard(card);
  }

  Future<dynamic> showPaymentSheet() {
    return FlutterFincodePlatform.instance.showPaymentSheet();
  }
}
