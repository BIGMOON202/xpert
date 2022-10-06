import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdlook_flutter_app/application/themes/app_colors.dart';

class RegularScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool isVisibleBackButton;
  const RegularScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.isVisibleBackButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: isVisibleBackButton ? null : SizedBox(),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: true,
        bottom: true,
        child: body,
      ),
    );
  }
}
