import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static Future<bool> openWhatsApp({
    required String phoneNumber,
    String? message,
  }) async {
    try {
      // Remove any non-digit characters from phone number
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

      // Add country code if not present (assuming +91 for India)
      if (!cleanPhone.startsWith('91') && cleanPhone.length == 10) {
        cleanPhone = '91$cleanPhone';
      }

      // Construct WhatsApp URL
      String whatsappUrl = 'https://wa.me/$cleanPhone';

      if (message != null && message.isNotEmpty) {
        whatsappUrl += '?text=${Uri.encodeComponent(message)}';
      }

      // Launch WhatsApp
      final Uri uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch WhatsApp');
        return false;
      }
    } catch (e) {
      print('Error opening WhatsApp: $e');
      return false;
    }
  }

  static Future<bool> openWhatsAppWithOrderMessage({
    required String phoneNumber,
    required String productName,
    required int quantity,
    required double totalPrice,
    required String orderId,
  }) async {
    String message = '''
Hello! I have an order for you:

Product: $productName
Quantity: $quantity
Total: ₹${totalPrice.toStringAsFixed(2)}
Order ID: $orderId

Please let me know when you can deliver. Thank you!
''';

    return await openWhatsApp(
      phoneNumber: phoneNumber,
      message: message,
    );
  }

  static Future<bool> openWhatsAppWithDeliveryMessage({
    required String phoneNumber,
    required String productName,
    required int quantity,
    required double totalPrice,
    required String orderId,
    required String deliveryLocation,
  }) async {
    String message = '''
Hello! I have an order for you:

Product: $productName
Quantity: $quantity
Total: ₹${totalPrice.toStringAsFixed(2)}
Order ID: $orderId
Delivery Location: $deliveryLocation

Please confirm when you can deliver. Thank you!
''';

    return await openWhatsApp(
      phoneNumber: phoneNumber,
      message: message,
    );
  }

  static Future<bool> openWhatsAppWithStatusUpdate({
    required String phoneNumber,
    required String orderId,
    required String status,
  }) async {
    String message = '''
Hello! Your order status has been updated:

Order ID: $orderId
Status: $status

Thank you for your business!
''';

    return await openWhatsApp(
      phoneNumber: phoneNumber,
      message: message,
    );
  }
}
