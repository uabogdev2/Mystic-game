import 'package:flutter/material.dart';

// Spacing
const double kSpacingXXXS = 2.0;
const double kSpacingXXS = 4.0;
const double kSpacingXS = 8.0;
const double kSpacingSmall = 12.0;
const double kSpacingMedium = 16.0;
const double kSpacingLarge = 24.0;
const double kSpacingXL = 32.0;
const double kSpacingXXL = 48.0;

// Padding
const EdgeInsets kPaddingAllXXS = EdgeInsets.all(kSpacingXXS);
const EdgeInsets kPaddingAllXS = EdgeInsets.all(kSpacingXS);
const EdgeInsets kPaddingAllSmall = EdgeInsets.all(kSpacingSmall);
const EdgeInsets kPaddingAllMedium = EdgeInsets.all(kSpacingMedium);
// Directional padding examples (can be expanded)
const EdgeInsets kPaddingHorizontalXS = EdgeInsets.symmetric(horizontal: kSpacingXS);
const EdgeInsets kPaddingHorizontalSmall = EdgeInsets.symmetric(horizontal: kSpacingSmall);
const EdgeInsets kPaddingHorizontalMedium = EdgeInsets.symmetric(horizontal: kSpacingMedium);
const EdgeInsets kPaddingVerticalXS = EdgeInsets.symmetric(vertical: kSpacingXS);
const EdgeInsets kPaddingVerticalSmall = EdgeInsets.symmetric(vertical: kSpacingSmall);
const EdgeInsets kPaddingVerticalMedium = EdgeInsets.symmetric(vertical: kSpacingMedium);


// Border Radius
const double kBorderRadiusSmall = 4.0;
const double kBorderRadiusMedium = 8.0;
const double kBorderRadiusLarge = 16.0;

// Shape Borders (reusable shapes)
const RoundedRectangleBorder kShapeBorderRadiusSmall = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(kBorderRadiusSmall)),
);
const RoundedRectangleBorder kShapeBorderRadiusMedium = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(kBorderRadiusMedium)),
);
const RoundedRectangleBorder kShapeBorderRadiusLarge = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(kBorderRadiusLarge)),
);

// Other constants can be added here as needed
// Example: Icon Sizes
const double kIconSizeSmall = 16.0;
const double kIconSizeMedium = 24.0;
const double kIconSizeLarge = 32.0;
