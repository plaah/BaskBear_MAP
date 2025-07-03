import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_functions/cloud_functions.dart';

class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  static StripeService get instance => _instance;

  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required String customerEmail,
    required String customerName,
    required String description,
  }) async {
    try {
      // Call Firebase Cloud Function
      final callable = FirebaseFunctions.instance.httpsCallable(
        'createPaymentIntent',
      );

      final result = await callable.call({
        'amount': amount,
        'currency': currency,
        'customerEmail': customerEmail,
        'customerName': customerName,
        'description': description,
      });

      return result.data;
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }

  Future<bool> makePayment({
    required double amount,
    required String currency,
    required String customerEmail,
    required String customerName,
    required String description,
  }) async {
    try {
      // Step 1: Create Payment Intent via Cloud Function
      final paymentIntentData = await createPaymentIntent(
        amount: amount,
        currency: currency,
        customerEmail: customerEmail,
        customerName: customerName,
        description: description,
      );

      // Step 2: Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['clientSecret'],
          style: ThemeMode.light,
          merchantDisplayName: 'SkillSwap',
          allowsDelayedPaymentMethods: true,
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'MY',
            currencyCode: 'MYR',
            testEnv: true, // Set to false for production
          ),
          applePay: const PaymentSheetApplePay(merchantCountryCode: 'MY'),
        ),
      );

      // Step 3: Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      return true;
    } on StripeException catch (e) {
      print('Stripe error: ${e.error.localizedMessage}');
      return false;
    } catch (e) {
      print('General error: $e');
      return false;
    }
  }
}
