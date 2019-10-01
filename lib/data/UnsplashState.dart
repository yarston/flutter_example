import 'package:flutter_list_test/data/UnsplashImage.dart';

class UnsplashState {
  final List<UnsplashImage> images;
  final bool loading;
  final bool paginate;
  final int page;
  final String uuid;

  UnsplashState({this.images, this.loading, this.page, this.paginate, this.uuid});

  UnsplashState.initialState()
      : images = List.unmodifiable([]),
        loading = false,
        paginate = false,
        page = 1,
        uuid = '';

  UnsplashState copyWith({i, l, paginate, page, uuid}) => new UnsplashState(
      images: i ?? this.images,
      loading: l ?? this.loading,
      paginate: paginate ?? this.paginate,
      page: page ?? this.page,
      uuid: uuid ?? this.uuid);
}
