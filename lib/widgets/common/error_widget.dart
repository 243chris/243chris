import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? customTitle;

  const ErrorDisplay({
    Key? key,
    required this.message,
    this.onRetry,
    this.customTitle,
  }) : super(key: key);

  factory ErrorDisplay.network({VoidCallback? onRetry}) {
    return ErrorDisplay(
      message: 'Vérifiez votre connexion internet et réessayez.',
      onRetry: onRetry,
      customTitle: 'Erreur de connexion',
    );
  }

  factory ErrorDisplay.generic({VoidCallback? onRetry}) {
    return ErrorDisplay(
      message: 'Une erreur est survenue. Veuillez réessayer.',
      onRetry: onRetry,
    );
  }

  String _getTitle() {
    if (customTitle != null) return customTitle!;
    if (message.contains('network') || message.contains('connexion')) {
      return 'Erreur de connexion';
    }
    if (message.contains('permission') || message.contains('accès')) {
      return 'Accès refusé';
    }
    return 'Erreur';
  }

  @override
  Widget build(BuildContext context) {
    final title = _getTitle();
    final isNetworkError = title == 'Erreur de connexion';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isNetworkError ? Icons.wifi_off : Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}