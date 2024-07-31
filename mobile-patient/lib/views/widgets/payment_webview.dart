import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatelessWidget {
  final String authorizationUrl;
  final VoidCallback onPaymentCompleted;

  PaymentWebView({
    required this.authorizationUrl,
    required this.onPaymentCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Paystack Payment')),
      body: WebView(
        initialUrl: authorizationUrl,
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('yourapp://')) {
            final uri = Uri.parse(request.url);
            final reference = uri.queryParameters['reference'];
            if (reference != null) {
              onPaymentCompleted();
            }
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }
}
