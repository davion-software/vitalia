import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vitalia/routing/routes.dart';

final class ErrorScreen extends StatelessWidget {
  const ErrorScreen({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'That page is unavailable.',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => context.go(Routes.today),
                  child: const Text('Go to Today'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
