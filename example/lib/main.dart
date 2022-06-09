import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_pay/flutter_pay.dart';
import 'package:flutter_pay/model/wx_pay_request.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await FlutterPay.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text('Running on: $_platformVersion\n'),
            TextButton(
              onPressed: () async {
                WxPayRequest userInfo = WxPayRequest(
                    partnerId: "1584480061",
                    appId: "wxa82f72397ae1a209",
                    nonceStr: "BW4HRCT91uYp3d6g",
                    packageValue: "Sign=WXPay",
                    prepayId: "wx26233056560300f2a36c702c7c06070000",
                    sign: "1C2DCB51C061E2A7CA5EB437F1980AB1",
                    timeStamp: "1603726256");
                await FlutterPay.payWithWechat(userInfo);
              },
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  '微信支付',
                  style: TextStyle(color: Colors.black, fontSize: 16.0),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                String payStr =
                    "alipay_sdk=alipay-sdk-java-dynamicVersionNo&app_id=2016102700769917&biz_content=%7B%22out_trade_no%22%3A%220%22%2C%22product_code%22%3A%22test%22%2C%22subject%22%3A%22%B2%E2%CA%D4%C9%CC%C6%B7%C3%E8%CA%F6%22%2C%22timeout_express%22%3A%2230m%22%2C%22total_amount%22%3A%220.02%22%7D&charset=GBK&format=json&method=alipay.trade.app.pay&notify_url=https%3A%2F%2Fapi.huanyan-inc.com%2Fcallback%2Falipay&sign_type=RSA2&timestamp=2020-10-28+16%3A45%3A16&version=1.0&sign=WpLy4YmQ2wV9k05P1LakVShMjuQdKn8iB9pT6XACMR63t%2BG9MR90l7dgoaW4K0%2Br2HEIyP3%2FfreGoxDcBdx%2B0JvOFG0E9LkKk7S2%2FodY4otxEnvHtv6iPv74i6axL%2BEgbv7eUCgTsk3rm4SgIO24queVDe75y0MMdIOrHkn%2B0OZHEZEd2fXizgSmiUcU2PZoZJ0flSPr%2FXoSHUBrrkvWgmKKaT4wZCpyf0O2BOXoKea6X1Pmv%2BWw2vu2RqtNjGnaTYl0riFMGRYZOBeZZjmOA8FxfmzBlRXUlO3QkvPHCj3zJffJZA6OeyLEKb7hvybacULqE4kPDeFELUYVhG1U9A%3D%3D";
                await FlutterPay.payWithAliPay(payStr);
              },
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  '支付宝支付',
                  style: TextStyle(color: Colors.black, fontSize: 16.0),
                ),
              ),
            ),
            TextButton(
              child: const Text('apply支付'),
              onPressed: () {
                FlutterPay.iapPay(goodsCode: "testDiamond1");
              },
            ),
          ],
        )),
      ),
    );
  }
}
