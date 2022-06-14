///
///android;
//   request.appId = "wxd930ea5d5a258f4f";
//   request.partnerId = "1900000109";
//   request.prepayId= "1101000000140415649af9fc314aa427",;
//   request.packageValue = "Sign=WXPay";
//   request.nonceStr= "1101000000140429eb40476f8896f4c9";
//   request.timeStamp= "1398746574";
//   request.sign= "7FFECB600D7157C5AA49810D2D8F28BC2811827B";
/// IOS
// request.partnerId = @"10000100";
// request.prepayId= @"1101000000140415649af9fc314aa427";
// request.package = @"Sign=WXPay";
// request.nonceStr= @"a462b76e7436e98e0ed6e13c64b4fd1c";
// request.timeStamp= @"1397527777";
// request.sign= @"582282D72DD2B03AD892830965F428CB16E7A256";
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
    final Map<String, dynamic> data = {};
    data['appId'] = appId;
    data['partnerId'] = partnerId;
    data['extData'] = extData;
    data['nonceStr'] = nonceStr;
    data['packageValue'] = packageValue;
    data['prepayId'] = prepayId;
    data['sign'] = sign;
    data['timeStamp'] = timeStamp;
    return data;
  }
}
