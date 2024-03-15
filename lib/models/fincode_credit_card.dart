class FincodeCreditCard {
  String? id;
  String? customerId;
  String? cardNo;
  String? expire;
  String? holderName;
  String? brand;

  FincodeCreditCard({
    this.id,
    this.customerId,
    this.cardNo,
    this.expire,
    this.holderName,
    this.brand,
  });

  factory FincodeCreditCard.fromJson(Map<String, dynamic> json) {
    return FincodeCreditCard(
      id: json['id'] as String?,
      customerId: json['customerId'] as String?,
      cardNo: json['cardNo'] as String?,
      expire: json['expire'] as String?,
      holderName: json['holderName'] as String?,
      brand: json['brand'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'cardNo': cardNo,
      'expire': expire,
      'holderName': holderName,
      'brand': brand,
    };
  }
}