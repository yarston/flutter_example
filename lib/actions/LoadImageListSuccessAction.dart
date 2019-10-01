import 'package:flutter_list_test/data/UnsplashImage.dart';
import 'package:meta/meta.dart';

class LoadImageListSuccessAction {
  final List<UnsplashImage> image;
  final bool paginate;

  LoadImageListSuccessAction({
    @required this.image,
    this.paginate,
  });
}