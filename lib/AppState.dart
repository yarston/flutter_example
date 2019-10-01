import 'package:flutter_list_test/data/UnsplashState.dart';
import 'package:meta/meta.dart';

class AppState {
  final UnsplashState unsplashState;

  AppState({
    @required this.unsplashState,
  });

  AppState.initialState({initState})
      : unsplashState = initState ?? UnsplashState.initialState();
}
