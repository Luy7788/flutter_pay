class AliPayResult {
  String? memo;
  String? result;
  String? resultStatus;

  AliPayResult({
    this.memo,
    this.result,
    this.resultStatus,
  });

  factory AliPayResult.fromJson(Map<String, dynamic> json) {
    return AliPayResult(
      memo: json['memo'],
      result: json['result'],
      resultStatus: json['resultStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['memo'] = memo;
    data['result'] = result;
    data['resultStatus'] = resultStatus;
    return data;
  }

  bool isSuccess() {
    return resultStatus == "9000";
  }
}
