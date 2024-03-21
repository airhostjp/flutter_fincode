import 'package:flutter_fincode/models/fincode_credit_card.dart';

class FincodeCardInfoResult {
  bool success;
  List<FincodeCreditCard>? data;
  String? message;
  int? statusCode;

  FincodeCardInfoResult({
    this.success = false,
    this.data,
    this.message,
    this.statusCode,
  });

  factory FincodeCardInfoResult.fromJson(Map<String, dynamic> json) {
    return FincodeCardInfoResult(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => FincodeCreditCard.fromJson(e.cast<String, dynamic>()))
              .toList()
          : null,
      message: json['message'],
      statusCode: json['statusCode'] ?? 0,
    );
  }
}