import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Container+Additions.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/generated/l10n.dart';

class EmptyWidget extends StatelessWidget {
  final String? title;
  final VoidCallback? onRefresh;

  const EmptyWidget({
    super.key,
    this.title,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (title != null) EmptyStateWidget(messageName: title),
        MaterialButton(
          splashColor: Colors.transparent,
          elevation: 0,
          onPressed: onRefresh,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.replay,
                color: SessionParameters().selectionColor,
              ),
              SizedBox(width: 10),
              Container(
                child: Text(
                  S.current.common_refresh,
                  style: TextStyle(color: SessionParameters().selectionColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
