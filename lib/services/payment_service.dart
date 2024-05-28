import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  final String apiKey = '4faeaa43021f0db04c8d8824ecfcaf605fe66be2';
  final String paymentUrl = 'https://sandbox.paymee.tn/api/v2/payments/create';

  Future<String?> createPayment(double amount, String firstName, String lastName, String email, String phone) async {
    final response = await http.post(
      Uri.parse(paymentUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $apiKey',
      },
      body: jsonEncode({
        'amount': amount,
        'note': 'Order #123',
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'return_url': 'https://www.return_url.tn',
        'webhook_url': 'https://www.webhook_url.tn',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['payment_url'];
    } else {
      throw Exception('Failed to create payment');
    }
  }
}
