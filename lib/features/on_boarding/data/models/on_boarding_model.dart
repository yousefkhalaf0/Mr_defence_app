import 'package:app/core/utils/assets.dart';

class OnBoardingModel {
  String? image;
  String? title;
  String? description;
  String? highlightWord;

  OnBoardingModel({
    this.image,
    this.title,
    this.description,
    this.highlightWord,
  });

  static List<OnBoardingModel> data = [
    OnBoardingModel(
      image: AssetsData.onBoardingImage1,
      title: 'Your safety is Our Priority!',
      highlightWord: 'Priority!',
      description:
          'Stay informed and protected with real-time crime alerts, emergency tools, and community support all in one app.',
    ),
    OnBoardingModel(
      image: AssetsData.onBoardingImage2,
      title: 'Real-Time Alerts at Your Fingertips',
      highlightWord: 'Alerts',
      description:
          'Stay updated on local crimes, fires, and accidents. Report incidents with photos or videos to help keep your community safe.',
    ),
    OnBoardingModel(
      image: AssetsData.onBoardingImage3,
      title: 'Emergency Help, One Tap Away',
      highlightWord: 'Help',
      description:
          'Use the SOS button to instantly notify emergency contacts and authorities. Share your location with trusted circles and set up safe zones for added peace of mind.',
    ),
    OnBoardingModel(
      image: AssetsData.onBoardingImage4,
      title: 'Together, We build a safer Community',
      highlightWord: 'safer Community',
      description:
          'Join a network of users who verify incidents and help filter out false reports. Our AI ensures you get accurate, reliable alerts.',
    ),
  ];
}
