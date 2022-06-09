class WxPayRequest {
  String? appId;
  String? partnerId;
  String? prepayId;
  String? nonceStr;
  String? timeStamp;
  String? packageValue;
  String? sign;
  String? extData;

  WxPayRequest(
      {this.appId,
      this.partnerId,
      this.extData,
      this.nonceStr,
      this.packageValue,
      this.prepayId,
      this.sign,
      this.timeStamp});

  factory WxPayRequest.fromJson(Map<String, dynamic> json) {
    return WxPayRequest(
      appId: json['appId'] ?? json['appid'],
      partnerId: json['partnerId'] ?? json['partnerid'],
      extData: json['extData'] ?? json['extdata'],
      nonceStr: json['nonceStr'] ?? json['noncestr'],
      packageValue: json['packageValue'] ?? json['package'],
      prepayId: json['prepayId'] ?? json['prepayid'],
      sign: json['sign'],
      timeStamp: json['timeStamp'] ?? json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['appId'] = this.appId;
    data['partnerId'] = this.partnerId;
    data['extData'] = this.extData;
    data['nonceStr'] = this.nonceStr;
    data['packageValue'] = this.packageValue;
    data['prepayId'] = this.prepayId;
    data['sign'] = this.sign;
    data['timeStamp'] = this.timeStamp;
    return data;
  }
}
