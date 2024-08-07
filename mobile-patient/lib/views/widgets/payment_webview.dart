import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final String authorizationUrl;
  final VoidCallback onPaymentCompleted;

  PaymentWebView({
    required this.authorizationUrl,
    required this.onPaymentCompleted,
  });

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  bool _isLoading = true; // Track loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paystack Payment')),
      body: Stack(
        children: [
          WebView(
            initialUrl: widget.authorizationUrl,
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith('Pharmanathi.com://payment')) {
                final uri = Uri.parse(request.url);
                final reference = uri.queryParameters['reference'];
                if (reference != null) {
                  widget.onPaymentCompleted();
                }
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
