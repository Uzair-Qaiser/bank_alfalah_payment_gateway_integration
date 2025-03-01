import 'dart:convert';
import 'package:bank_alfalah_payment_gateway_integration/src/models/payment_model.dart';
import 'package:bank_alfalah_payment_gateway_integration/src/utils/costants.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:uuid/uuid.dart';

class PaymentService {
  String _getHashString(Map<String, String?> data, String key1, String key2) {
    final sortedKeys = data.keys.toList()..sort();
    String finalString = sortedKeys.map((key) => '$key=${data[key]}').join('&');

    final key = encrypt.Key.fromUtf8(key1);
    final iv = encrypt.IV.fromUtf8(key2);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(finalString, iv: iv);
    return encrypted.base64;
  }

  Future<void> initiatePayment(
      {required WebViewController controller,
      required String price,
      required MerchantDetails merchantDetails}) async {
    try {
      var uuid = Uuid();
      String transactionRefNo = uuid.v4();
      final transactionReferenceNumber = transactionRefNo;

      var data = {
        'HS_ChannelId': '1001',
        'HS_IsRedirectionRequest': '0',
        'HS_MerchantHash': merchantDetails.merchantHash,
        'HS_MerchantId': merchantDetails.merchantId,
        'HS_MerchantPassword': merchantDetails.merchantPass,
        'HS_MerchantUsername': merchantDetails.merchantUserName,
        'HS_ReturnURL': merchantDetails.returnUrl,
        'HS_StoreId': merchantDetails.storeId,
        'HS_TransactionReferenceNumber': transactionReferenceNumber,
        '__RequestVerificationToken': '',
      };

      final requestHash = _getHashString(
          data, merchantDetails.firstKey, merchantDetails.secondKey);
      data['HS_RequestHash'] = requestHash;

      final response = await http.post(
        Uri.parse(BapgConstants.bapgBaseUrl + BapgConstants.bapgEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == 'true') {
          final prevDataString = data.map((key, value) {
            final stringValue = value.toString();
            return MapEntry(key, stringValue);
          });
          _loadWebView(
              responseData: responseData,
              prevData: prevDataString,
              controller: controller,
              price: price,
              key1: merchantDetails.firstKey,
              key2: merchantDetails.secondKey);
        } else {
          if (kDebugMode) {
            print('HTTP Error: ${response.statusCode}, ${response.body}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  void _loadWebView(
      {required Map<String, dynamic> responseData,
      required Map<String, String> prevData,
      required WebViewController controller,
      required String price,
      required String key1,
      required String key2}) {
    final newData = {
      'AuthToken': responseData['AuthToken'].toString(),
      'RequestHash': '',
      'ChannelId': prevData['HS_ChannelId'],
      'Currency': 'PKR',
      'IsBIN': '0',
      'ReturnURL': prevData['HS_ReturnURL'],
      'MerchantId': prevData['HS_MerchantId'],
      'StoreId': prevData['HS_StoreId'],
      'MerchantHash': prevData['HS_MerchantHash'],
      'MerchantUsername': prevData['HS_MerchantUsername'],
      'MerchantPassword': prevData['HS_MerchantPassword'],
      'TransactionTypeId': '',
      'TransactionReferenceNumber': prevData['HS_TransactionReferenceNumber'],
      'TransactionAmount': price,
    };

    final requestHash = _getHashString(newData, key1, key2);
    newData['RequestHash'] = requestHash;

    final htmlData = '''
<!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta http-equiv="X-UA-Compatible" content="IE=edge">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Form To Submit</title>
    <script>
 document.addEventListener("DOMContentLoaded", function() {
 document.getElementById("PageRedirectionForm").submit();
 });
     </script>
          <style>
            body{
                position: relative;
                
            }
          .ClickBTN{
          background-color: white;
          color: white;
          
          border: none;
         

          
          }
          .ButtonDiv{
           
           
           margin: auto;
           
    text-align: center;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    width: 100vw;
          }
  .loader {
  border: 6px solid #F83649;
  border-radius: 50%;
  border-top: 6px solid #dddddd;
  width: 60px;
  height: 60px;
  -webkit-animation: spin 2s linear infinite; /* Safari */
  animation: spin 2s linear infinite;
}

/* Safari */
@-webkit-keyframes spin {
  0% { -webkit-transform: rotate(0deg); }
  100% { -webkit-transform: rotate(360deg); }
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.btn-custon-four{
display: "none;
}

          </style>
      </head>
     
      <body onload="document.getElementById('PageRedirectionForm').submit();">
        <div class="MainDIv">


          
            <form action="https://payments.bankalfalah.com/SSO/SSO/SSO" id="PageRedirectionForm" method="post" novalidate="novalidate">                                                                                                                                                                 
                <input id="AuthToken" name="AuthToken" type="hidden" value="${responseData['AuthToken']}">                                                                                                                                
                <input id="RequestHash" name="RequestHash" type="hidden" value="$requestHash">                                                                                                                            
                <input id="ChannelId" name="ChannelId" type="hidden" value="${newData['ChannelId']}">                                                                                                                            
                <input id="Currency" name="Currency" type="hidden" value="PKR">                                                                                                                               
                <input id="IsBIN" name="IsBIN" type="hidden" value="0">                                                                                     
                <input id="ReturnURL" name="ReturnURL" type="hidden" value="${newData['ReturnURL']}">                                                                            
                <input id="MerchantId" name="MerchantId" type="hidden" value="${newData['MerchantId']}">                                                                                                                           
                <input id="StoreId" name="StoreId" type="hidden" value="${newData['StoreId']}">                                                                                                                     
                <input id="MerchantHash" name="MerchantHash" type="hidden" value="${newData['MerchantHash']}">                                  
                <input id="MerchantUsername" name="MerchantUsername" type="hidden" value="${newData['MerchantUsername']}">                                                                                                            
                <input id="MerchantPassword" name="MerchantPassword" type="hidden" value="${newData['MerchantPassword']}">                                                                                          
                <input id="TransactionTypeId" name="TransactionTypeId" type="hidden" value="">                                                                                                                                                                                  
                <input autocomplete="off" id="TransactionReferenceNumber" name="TransactionReferenceNumber" placeholder="Order ID" type="hidden" value="${newData['TransactionReferenceNumber']}">                                  
                <input autocomplete="off"  id="TransactionAmount" name="TransactionAmount" placeholder="Transaction Amount" type="hidden" value="${newData['TransactionAmount']}">                                                             
                
                <div class="ButtonDiv ">
                    
                    <button type="submit" class="loader btn btn-custon-four btn-danger ClickBTN" id="run" ></button>                 
                </div>
            </form>                                                                                                                                                                                 
        </div>
        </body>
       </html>
    ''';

    controller.loadHtmlString(htmlData);
  }
}
