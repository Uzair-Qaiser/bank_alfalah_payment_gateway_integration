import 'dart:developer';
import 'package:bank_alfalah_payment_gateway_integration/src/models/payment_model.dart';
import 'package:bank_alfalah_payment_gateway_integration/src/service/payment_service.dart';
import 'package:bank_alfalah_payment_gateway_integration/src/ui/post_payment_screen.dart';
import 'package:bank_alfalah_payment_gateway_integration/src/utils/costants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A widget that integrates Bank Alfalah's payment gateway.

class AlfalahPaymentIntegration extends StatefulWidget {
  /// - [onSuccess] is called when the payment is successful.
  /// - [onFailure] is called when the payment fails.
  /// - [merchantDetails] contains merchant-specific details required for the payment.
  /// - [transAmount] is the transaction amount.
  const AlfalahPaymentIntegration(
      {super.key,
      required this.onSuccess,
      required this.onFailure,
      required this.merchantDetails,
      required this.transAmount});

  /// Callback function triggered when the payment is successful.
  final VoidCallback onSuccess;

  /// Callback function triggered when the payment fails.
  final VoidCallback onFailure;

  /// Merchant details required for processing the payment.
  final MerchantDetails merchantDetails;

  /// The transaction amount for the payment.
  final String transAmount;
  @override
  AlfalahPaymentIntegrationState createState() =>
      AlfalahPaymentIntegrationState();
}

/// Manages WebView integration and payment process.
class AlfalahPaymentIntegrationState extends State<AlfalahPaymentIntegration> {
  late WebViewController controller;

  /// Service instance for handling payment logic.
  final _paymentService = PaymentService();

  /// Indicates whether the WebView is currently loading.
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (error) => log('Web Resource Error: $error'),
          onNavigationRequest: (request) async {
            if (request.url.contains(BapgConstants.successCode)) {
              if (kDebugMode) {
                print("Success");
              }
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PostPaymentScreen(successful: true)));
              widget.onSuccess();

              return NavigationDecision.prevent;
            } else if (request.url.contains(BapgConstants.failureCode)) {
              if (kDebugMode) {
                print("Failed");
              }
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PostPaymentScreen(successful: false)));
              widget.onFailure();
              return NavigationDecision.prevent;
            }
            if (kDebugMode) {
              print('Navigation Request: ${request.url}');
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    /// Initiates the payment process after a delay of 2 seconds.
    Future.delayed(const Duration(seconds: 2), () {
      _paymentService.initiatePayment(
          controller: controller,
          price: widget.transAmount,
          merchantDetails: widget.merchantDetails);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading) Center(child: const CircularProgressIndicator()),
        ],
      )),
    );
  }
}
