class IapResult {
  bool? success;
  Map? params;
  String? goodsCode;
  String? transactionId;
  String? errorMsg;

  IapResult({
    this.success,
    this.params,
    this.goodsCode,
    this.transactionId,
    this.errorMsg,
  });

  factory IapResult.fromJson(Map<String, dynamic> json) {
    return IapResult(
      success: json['success'],
      params: json['params'],
      goodsCode: json['goodsCode'],
      transactionId: json['transactionId'],
      errorMsg: json["errorMsg"],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['params'] = this.params;
    data['goodsCode'] = this.goodsCode;
    data['transactionId'] = this.transactionId;
    data['errorMsg'] = this.errorMsg;
    return data;
  }
}
