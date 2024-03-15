import 'package:flutter_fincode/models/fincode_credit_card.dart';

class FincodeRegisterCardResult {
  bool success;
  FincodeCreditCard? data;
  String? message;
  int? statusCode;

  FincodeRegisterCardResult({
    this.success = false,
    this.data,
    this.message,
    this.statusCode,
  });

  factory FincodeRegisterCardResult.fromJson(Map<String, dynamic> json) {
    return FincodeRegisterCardResult(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? FincodeCreditCard.fromJson(json['data'].cast<String, dynamic>())
          : null,
      message: json['message'],
      statusCode: json['statusCode'] ?? 0,
    );
  }
}