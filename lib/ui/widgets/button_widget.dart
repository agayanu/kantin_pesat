import 'package:flutter/material.dart';
import 'package:kantin_pesat/ui/style/distance.dart';
import 'package:kantin_pesat/ui/style/style.dart';

class ButtonWidget extends StatelessWidget {
  final String title;
  final VoidCallback onPressedFunction;
  final Color bgColor;
  const ButtonWidget(
      {Key? key,
      required this.title,
      required this.onPressedFunction,
      required this.bgColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: fieldPadding,
      width: screenWidthPercent(context, multipleBy: 0.9),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: TextStyle(
            fontSize: 20,
            color: bgColor,
          ),
        ),
        onPressed: onPressedFunction,
        child: Text(
          title,
          style: textButtonTextStyle,
        ),
      ),
    );
  }
}
