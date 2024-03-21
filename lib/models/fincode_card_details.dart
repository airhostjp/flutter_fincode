class FincodeCardDetails {
  String? customerId;
  String? defaultFlag;
  String? cardNo;
  String? expire;
  String? holderName;
  String? securityCode;
  String? token;

  FincodeCardDetails({
    this.customerId,
    this.defaultFlag = '1',
    this.cardNo,
    this.expire,
    this.holderName,
    this.securityCode,
    this.token,
  });

  factory FincodeCardDetails.fromJson(Map<String, dynamic> json) {
    return FincodeCardDetails(
      customerId: json['customerId'] as String?,
      defaultFlag: json['defaultFlag'] as String?,
      cardNo: json['cardNo'] as String?,
      expire: json['expire'] as String?,
      holderName: json['holderName'] as String?,
      securityCode: json['securityCode'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'defaultFlag': defaultFlag,
      'cardNo': cardNo,
      'expire': expire,
      'holderName': holderName,
      'securityCode': securityCode,
      'token': token,
    };
  }
}