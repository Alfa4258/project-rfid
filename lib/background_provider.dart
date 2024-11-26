import 'dart:io';
import 'package:flutter/foundation.dart';

class BackgroundProvider extends ChangeNotifier {
  File? _homeBannerImage;
  File? _displayBackgroundImage;

  File? get homeBannerImage => _homeBannerImage;
  File? get displayBackgroundImage => _displayBackgroundImage;

  void setHomeBannerImage(File? image) {
    _homeBannerImage = image;
    notifyListeners();
  }

  void setDisplayBackgroundImage(File? image) {
    _displayBackgroundImage = image;
    notifyListeners();
  }
}
