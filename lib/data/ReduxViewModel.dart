import 'package:flutter_list_test/data/UnsplashImage.dart';
import 'package:flutter_list_test/data/UnsplashState.dart';
import 'package:flutter_list_test/actions/LoadImageListAction.dart';
import 'package:flutter_list_test/AppState.dart';
import 'package:redux/redux.dart';

class ReduxViewModel {
  final UnsplashState state;
  final List<UnsplashImage> images;
  final Function onLoad;

  ReduxViewModel({
    this.state,
    this.onLoad,
    this.images,
  });

  static ReduxViewModel fromStore(Store<AppState> store) {
    return new ReduxViewModel(
      state: store.state.unsplashState,
      images: store.state.unsplashState.images,
      onLoad: () => store.dispatch(
        new LoadImageListAction(paginate: false),
      ),
    );
  }
  // method to check if the state changed
  @override
  int get hashCode => state.uuid.hashCode;

  bool operator == (other) {
    bool result = identical(this, other) || other is ReduxViewModel;

    if (result) {
      if (state.uuid != (other as ReduxViewModel).state.uuid) {
        return false;
      }
    }

    return result;
  }
}