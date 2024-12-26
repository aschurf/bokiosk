import 'package:flutter/material.dart';

class ErrorNotifier {
  static final ErrorNotifier _instance = ErrorNotifier._internal();
  static ErrorNotifier get instance => _instance;

  ErrorNotifier._internal();

  final ValueNotifier<String?> _errorMessage = ValueNotifier(null);

  void showError(String message) {
    _errorMessage.value = message;
  }

  void dismissError() {
    _errorMessage.value = null;
  }

  ValueNotifier<String?> get errorMessage => _errorMessage;
}


class ErrorOverlay extends StatelessWidget {
  final Widget child;

  ErrorOverlay({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        ValueListenableBuilder<String?>(
          valueListenable: ErrorNotifier.instance.errorMessage,
          builder: (context, message, _) {
            if (message == null) return SizedBox.shrink();
            return Positioned.fill(
              child: Material(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'An error occurred:',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        message,
                        style: TextStyle(color: Colors.redAccent, fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: ErrorNotifier.instance.dismissError,
                        child: Text('Dismiss'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}