class ChannelResult {
  int? code;
  String? msg;
  dynamic data;

  ChannelResult({
    this.code,
    this.msg,
    this.data,
  });

  factory ChannelResult.fromJson(Map<String, dynamic> json) {
    return ChannelResult(
      code: json['code'] ?? 0,
      msg: json['msg'] ?? "",
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['msg'] = this.msg;
    data['data'] = this.data;
    return data;
  }

  bool isSuccess() {
    return 200 == this.code;
  }
}
