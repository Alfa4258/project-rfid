import 'dart:io';
import 'package:flutter/foundation.dart';

class BackgroundProvider extends ChangeNotifier {
  File? _homeBannerImage;
  File? _bibDisplayBackgroundImage;

  File? get homeBannerImage => _homeBannerImage;
  File? get bibDisplayBackgroundImage => _bibDisplayBackgroundImage;

  void setHomeBannerImage(File? image) {
    _homeBannerImage = image;
    notifyListeners();
  }

  void setBibDisplayBackgroundImage(File? image) {
    _bibDisplayBackgroundImage = image;
    notifyListeners();
  }
}
