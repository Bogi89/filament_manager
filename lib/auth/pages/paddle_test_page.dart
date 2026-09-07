import 'package:flutter/material.dart';

import '../../services/paddle_subscription_service.dart';

class PaddleTestPage extends StatefulWidget {
  const PaddleTestPage({super.key});

  @override
  State<PaddleTestPage> createState() => _PaddleTestPageState();
}

class _PaddleTestPageState extends State<PaddleTestPage> {
  bool _isLoading = false;

  Future<void> _startPaddleCheckout() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await PaddleSubscriptionService.startYearlySubscription();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Paddle Sandbox Checkout wurde gestartet.',
          ),
        ),
      );
    } on PaddleSubscriptionException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unerwarteter Fehler beim Paddle-Test: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paddle Sandbox Test'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: FilledButton.icon(
              onPressed:
                  _isLoading ? null : _startPaddleCheckout,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.payment),
              label: Text(
                _isLoading
                    ? 'Checkout wird vorbereitet …'
                    : 'Paddle Sandbox Checkout starten',
              ),
            ),
          ),
        ),
      ),
    );
  }
}