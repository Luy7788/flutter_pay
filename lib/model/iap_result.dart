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
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['params'] = params;
    data['goodsCode'] = goodsCode;
    data['transactionId'] = transactionId;
    data['errorMsg'] = errorMsg;
    return data;
  }
}
