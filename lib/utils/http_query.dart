import 'dart:convert';
import 'package:cafe5_mworker/main.dart';
import 'package:cafe5_mworker/utils/prefs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class HttpQuery {

  final String route;
  final int timeout;
  HttpQuery(this.route, {this.timeout = 10});

  Future<Map<String, dynamic>> request(Map<String, dynamic> inData) async {
    inData['apikey'] = prefs.apiKey();
    inData['sessionkey'] = prefs.string('sessionkey');
    inData['config'] = prefs.string('config');
    inData['language'] = 'am';

    Map<String, Object?> outData = {};
    String strBody = jsonEncode(inData);
    if (kDebugMode) {
      print('request ${prefs.string("serveraddress")}/$route: $strBody');
    }
    try {
      var response = await http
          .post(
              Uri.https(prefs.string("serveraddress"), route),
              headers: {
                'Content-Type': 'application/json',
              },
              body: utf8.encode(strBody))
          .timeout(Duration(seconds: timeout), onTimeout: () {
        return http.Response('Timeout', 408);
      });
      String strResponse = utf8.decode(response.bodyBytes);
      if (kDebugMode) {
        print('Row body $strResponse');
      }
      if (response.statusCode < 299) {
        try {
          outData = jsonDecode(strResponse);
          if (!outData.containsKey('status')) {
            outData['status'] = 0;
            if (!outData.containsKey('data')) {
              outData['data'] = jsonEncode(outData);
            }
          }
        } catch (e) {
          outData['status'] = 0;
          outData['data'] = '${e.toString()} $strResponse';
        }
      } else {
        outData['status'] = 0;
        outData['error'] = response.statusCode;
        outData['data'] = strResponse;
        if (response.statusCode == 401) {
          prefs.setString('sessionkey', '');
          Prefs.navigatorKey = GlobalKey<NavigatorState>();
          Navigator.pushAndRemoveUntil(prefs.context(), MaterialPageRoute(builder: (builder)=> App()), (route) => false);
        }
      }
    } catch (e) {
      outData['status'] = 0;
      outData['data'] = e.toString();
    }
    if (kDebugMode) {
      print('Output $outData');
    }
    return outData;
  }
}
