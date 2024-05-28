import 'package:flutter/material.dart';
//import'web_view_stack.dart';
import 'package:webview_flutter/webview_flutter.dart';




class PaymentPage extends StatefulWidget {
  final String paymentUrl;

  const PaymentPage({super.key, required this.paymentUrl});

  @override
  PaymentPageState createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  late WebViewController _controller;
  double? loadingPercentage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              loadingPercentage = progress.toDouble();
            });
          },
          onPageStarted: (String url) {
           
          },
          onPageFinished: (String url) {
            setState(() {
              loadingPercentage = null;
            });
            if (url.contains('https://www.return_url.tn')) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const SuccessPage(),
                ),
              );
            }

          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('/loader')) {
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paymee Payment'),
      ),
      body: 
      Stack(
      children: [
        WebViewWidget(
          controller: _controller,
        ),
        if (loadingPercentage != null && loadingPercentage! < 100)
          LinearProgressIndicator(
            value: loadingPercentage! / 100.0,
          ),
      ],
    )
     
    );
  }
}

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Successful'),
      ),
      body: const Center(
        child: Text('Your payment has been processed successfully.'),
      ),
    );
  }
}