import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_list_test/AppState.dart';
import 'package:flutter_list_test/actions/LoadImageListAction.dart';
import 'package:flutter_list_test/actions/LoadImageListSuccessAction.dart';
import 'package:flutter_list_test/actions/ViewImageAction.dart';
import 'package:flutter_list_test/data/ReduxViewModel.dart';
import 'package:flutter_list_test/data/UnsplashImage.dart';
import 'package:flutter_list_test/data/UnsplashState.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';
import 'package:uuid/uuid.dart';

var clientId = '5e23ff0ddcb2c357b87f2f9ca557744dffc35aa0d12b7fb38ff759de35720e54';

void main() {
  final loadRequest = _createLoadmagesRequest();
  final store = new Store<AppState>(
      rootReducer,
      initialState: AppState.initialState(
        initState: UnsplashState.initialState(),
      ),
      middleware: [
        TypedMiddleware<AppState, LoadImageListAction>(loadRequest)
      ]);
  runApp(MyApp(store));
}

AppState rootReducer(AppState state, action) {
  return AppState(
    unsplashState: mainReducer(state.unsplashState, action),
  );
}

Middleware<AppState> _createLoadmagesRequest() {
  return (Store<AppState> store, action, NextDispatcher next) async {
    // Propagate the action first for show loading indicator ( global and pagination )
    next(action);
    var raw = await http.get('https://api.unsplash.com/photos/?client_id=$clientId&page=${store.state.unsplashState.page}');
    if (raw.statusCode == 200) {
      // dispatch success loading  ( first load and pagination load )
      store.dispatch(
        new LoadImageListSuccessAction(
          image: (json.decode(raw.body) as List).map<UnsplashImage>((i) => UnsplashImage.fromJson(i)).toList(),
          paginate: action.paginate,
        ),
      );
    } else {
      throw Exception('Failed to load post');
    }
  };
}

UnsplashState loadImageList(UnsplashState state, LoadImageListAction action) {
  return state.copyWith(
    // activate global loading only if not pagination active
    l: action.paginate ? false : true,
    paginate: action.paginate,
    uuid: new Uuid().v1(),
    // reset page if use RefreshIndicator or first loadind
    page: action.paginate ? state.page : 1,
  );
}

UnsplashState loadImageListSuccess(UnsplashState state, LoadImageListSuccessAction action) {
  return state.copyWith(
    l: false,
    // if pagination its actived i include the new items to the existing
    i: [
      if (action.paginate) ...state.images,
      ...action.image,
    ],
    page: state.page + 1,
    // forcing  to change the state and execute StoreConector builder function
    uuid: new Uuid().v1(),
    paginate: false,
  );
}

UnsplashState viewImage(UnsplashState state, ViewImageAction action) {
  return state.copyWith(i: action.image, uuid: new Uuid().v1());
}

final Reducer<UnsplashState> mainReducer = combineReducers<UnsplashState>([
  new TypedReducer<UnsplashState, LoadImageListSuccessAction>(loadImageListSuccess),
  new TypedReducer<UnsplashState, LoadImageListAction>(loadImageList),
  new TypedReducer<UnsplashState, ViewImageAction>(viewImage)
]);

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  MyApp(this.store);

  @override
  Widget build(BuildContext context) {

    return StoreProvider<AppState>(
      store: store,
      child: new MaterialApp(
        title: 'Unsplash API test',
        home: UnsplashImageView(),
      )
    );
  }
}

class UnsplashImageView extends StatefulWidget {
  @override
  UnsplashCardsListState createState() => UnsplashCardsListState();
}

class UnsplashCardsListState extends State<UnsplashImageView> {
  List<UnsplashImage> dataList = [];
  final ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // only execute pagination event if it's the last item
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        var store = StoreProvider.of<AppState>(context);
        store.dispatch(new LoadImageListAction(paginate: true));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget buildImageCard() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        //itemCount: dataList.length,
        itemBuilder: (context, i) {
          //if (i >= dataList.length) dataList.add('other word № ${i}');
          return _buildRow(dataList[i]);
        });
  }
  // #enddocregion _buildSuggestions

  // #docregion _buildRow
  Widget _buildRow(UnsplashImage blabla) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.network((blabla.urls == null || blabla.urls.regular == null) ? 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg' : blabla.urls.regular),
            ListTile(
              //leading: Icon(Icons.album),
              title: Text((blabla.user != null && blabla.user.username != null ) ? blabla.user.username : 'unknow user'),
              subtitle: Text(blabla.description != null ? blabla.description :
              (blabla.alt_description != null ? blabla.alt_description :
              'no any description')),
            ),
            ButtonTheme.bar( // make buttons use the appropriate styles for cards
              child: ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: const Text('LIKE'),
                    onPressed: () { /* ... */ },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unsplash api test'),
      ),
      body: StoreConnector<AppState, ReduxViewModel>(
        distinct: true,
        converter: (store) => ReduxViewModel.fromStore(store),
        onInit: (store) =>
            store.dispatch(new LoadImageListAction(paginate: false)),
        builder: (_, vm) {
          // global and first loading indicator
          if (vm.state.loading) {
            return Center(
              child: Theme(
                data: Theme.of(context).copyWith(accentColor: Colors.blue),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              vm.onLoad();
              await Future.delayed(Duration(seconds: 2));
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: vm.images.length,
              itemBuilder: (_, int index) {
                // show pagination loading indicator at the bottom of the list
                if (vm.state.paginate && vm.images.length - 1 == index) {
                  return Container(
                    height: 50,
                    child: Center(
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(accentColor: Colors.blue),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                return _buildRow(vm.images[index]);
              },
            ),
          );
        },
      ),
    );
  }
}