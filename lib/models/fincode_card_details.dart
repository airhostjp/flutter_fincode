class FincodeCardDetails {
  String? customerId;
  String? defaultFlag;
  String? cardNo;
  String? expire;
  String? holderName;
  String? securityCode;
  String? token;
  String? threeDS2PhoneNo;
  String? threeDS2Email;

  FincodeCardDetails({
    this.customerId,
    this.defaultFlag = '1',
    this.cardNo,
    this.expire,
    this.holderName,
    this.securityCode,
    this.token,
    this.threeDS2PhoneNo,
    this.threeDS2Email,
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
      threeDS2PhoneNo: json['threeDS2PhoneNo'] as String?,
      threeDS2Email: json['threeDS2Email'] as String?,
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
      'threeDS2PhoneNo': threeDS2PhoneNo,
      'threeDS2Email': threeDS2Email,
    };
  }
}