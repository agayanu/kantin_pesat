import 'package:flutter/material.dart';

// const Widget horizontalSpaceTiny = SizedBox(width: 5);
// const Widget horizontalSpaceSmall = SizedBox(width: 10);
// const Widget horizontalSpaceMedium = SizedBox(width: 25);

// const Widget verticalSpaceTiny = SizedBox(height: 5);
const Widget verticalSpaceSmall = SizedBox(height: 10);
const Widget verticalSpaceMedium = SizedBox(height: 25);
const Widget verticalSpaceLarge = SizedBox(height: 50);
// const Widget verticalSpaceMassive = SizedBox(height: 120);

const double fieldHeight = 55;
const EdgeInsets fieldPadding = EdgeInsets.symmetric(horizontal: 15);

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
// double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

double screenWidthPercent(BuildContext context, {double multipleBy = 1}) =>
    (screenWidth(context) * multipleBy);
// double screenHeightPercent(BuildContext context, {double multipleBy = 1}) =>
//     (screenHeight(context) * multipleBy);
