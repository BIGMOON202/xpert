import 'package:flutter/material.dart';

class LoaderBox extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  const LoaderBox({
    Key? key,
    required this.isLoading,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Center(
          child: isLoading ? const CircularProgressIndicator() : SizedBox(),
        )
      ],
    );
  }
}
