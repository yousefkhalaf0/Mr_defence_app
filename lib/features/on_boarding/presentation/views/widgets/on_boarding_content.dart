import 'package:app/core/utils/constants.dart';
import 'package:app/core/utils/helper.dart';
import 'package:app/features/on_boarding/data/models/on_boarding_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class OnBoardingContent extends StatelessWidget {
  const OnBoardingContent({super.key, required this.onBoardingModel});
  final OnBoardingModel onBoardingModel;
  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.sizeOf(context).height;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: SvgPicture.asset(onBoardingModel.image!),
        ),
        SizedBox(height: h * 0.05),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text.rich(
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kTextLightColor,
              fontWeight: FontWeight.bold,
              fontSize: Helper.getResponsiveFontSize(context, fontSize: 32),
            ),
            _buildHighlightedTitle(
              onBoardingModel.title!,
              onBoardingModel.highlightWord,
            ),
          ),
        ),
        SizedBox(height: h * 0.02),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35.5),
          child: Text(
            onBoardingModel.description!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kNeutral200,
              fontSize: Helper.getResponsiveFontSize(context, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

TextSpan _buildHighlightedTitle(String title, String? highlightWord) {
  if (highlightWord == null || !title.contains(highlightWord)) {
    return TextSpan(text: title);
  }

  final parts = title.split(highlightWord);

  return TextSpan(
    children: [
      TextSpan(text: parts[0]),
      TextSpan(
        text: highlightWord,
        style: const TextStyle(color: kTextRedColor),
      ),
      if (parts.length > 1) TextSpan(text: parts[1]),
    ],
  );
}
