import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final String? loadingMessage;
  const Loading({
    Key? key,
    this.loadingMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _message = loadingMessage ?? '';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            _message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
    );
  }
}

class Error extends StatelessWidget {
  final bool showRetry;
  final String? errorMessage;

  final Function? onRetryPressed;

  const Error({
    Key? key,
    this.errorMessage,
    this.onRetryPressed,
    this.showRetry = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _retryWidget() {
      if (this.showRetry == true) {
        return Flexible(
          child: RaisedButton(
            color: Colors.white,
            child: Text('Retry', style: TextStyle(color: Colors.black)),
            onPressed: () => onRetryPressed?.call(),
          ),
        );
      } else {
        return Container();
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Text(
              errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(height: 8),
          _retryWidget()
        ],
      ),
    );
  }
}
