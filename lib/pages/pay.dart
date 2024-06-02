import 'package:flutter/material.dart';
import 'package:renting_app/core/constants.dart';
import 'package:renting_app/pages/success_page.dart';
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
          onPageStarted: (String url) {},
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
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, Color.fromARGB(80, 3, 168, 244)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Paymee Payment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _controller,
          ),
          if (loadingPercentage != null && loadingPercentage! < 100)
            Center(
              child: CircularProgressIndicator(
                value: loadingPercentage! / 100.0,
                valueColor: const AlwaysStoppedAnimation<Color>(primary),
              ),
            ),
        ],
      ),
    );
  }
}
