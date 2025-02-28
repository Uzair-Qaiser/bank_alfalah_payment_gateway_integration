import 'package:bank_alfalah_payment_gateway_integration/alfalah_payment.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
        ),
        home: ProcessPayment()
    );
  }
}

class ProcessPayment extends StatelessWidget {
  const ProcessPayment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:AlfalahPaymentIntegration(
          onSuccess: () {
            print("Transaction Succeed");
          },
          onFailure: () {
            print("Transaction Failed");
          },
          merchantDetails: MerchantDetails(
              firstKey: 'Enter first key here', //You will get keys from bank alfalah
              secondKey: 'Enter second key here',
              merchantId: 'Enter your merchant id',
              storeId: 'Enter your store id',
              returnUrl: 'Enter your return url',
              merchantHash: 'Enter your merchant hash',
              merchantPass: 'Enter merchant pass here',
              merchantUserName: 'Enter merchant username here'),
          transAmount: "Enter transaction amount here") ,
    );
  }
}
