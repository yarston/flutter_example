import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_list_test/AppState.dart';
import 'package:flutter_list_test/actions/LikeAction.dart';
import 'package:flutter_list_test/actions/LoadImageListAction.dart';
import 'package:flutter_list_test/actions/LoadImageListSuccessAction.dart';
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
    var response = await http.get('https://api.unsplash.com/photos/?client_id=$clientId&page=${store.state.unsplashState.page}');
    if (response.statusCode == 200) {
      // dispatch success loading  ( first load and pagination load )
      store.dispatch(
        new LoadImageListSuccessAction(
          image: (json.decode(response.body) as List).map<UnsplashImage>((i) => UnsplashImage.fromJson(i)).toList(),
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

UnsplashState likeImage(UnsplashState state, LikeAction action) {
  String likedId = action.image.id;
  return state.copyWith(i: state.images.map((e) => e.id == likedId ? e.copyWith(!e.liked_by_user) : e).toList(), uuid: new Uuid().v1());
}

final Reducer<UnsplashState> mainReducer = combineReducers<UnsplashState>([
  new TypedReducer<UnsplashState, LoadImageListSuccessAction>(loadImageListSuccess),
  new TypedReducer<UnsplashState, LoadImageListAction>(loadImageList),
  new TypedReducer<UnsplashState, LikeAction>(likeImage)
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
  Widget _buildRow(UnsplashImage item) {
    return Center(
      child: Card(
        child: new InkWell(
          onTap: () => showItem(context, item),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.network((item.urls == null || item.urls.regular == null)
                  ? 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'
                  : item.urls.regular),
              ListTile(
                //leading: Icon(Icons.album),
                title: Text(
                    (item.user != null && item.user.username != null)
                        ? item.user.username
                        : 'unknow user'),
                subtitle: Text(item.description != null ? item.description :
                (item.alt_description != null ? item.alt_description :
                'no any description')),
              ),
              ButtonTheme.bar( // make buttons use the appropriate styles for cards
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: Text(item.liked_by_user ? 'DISLIKE' : 'LIKE'),
                      onPressed: () {
                        StoreProvider.of<AppState>(context).dispatch(LikeAction(image: item));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
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
        onInit: (store) => store.dispatch(new LoadImageListAction(paginate: false)),
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

class FullScreenView extends StatefulWidget {
  final UnsplashImage item;
  FullScreenView(this.item);
  @override
  _FullScreenViewState createState() => _FullScreenViewState(item);
}

class _FullScreenViewState extends State<FullScreenView> {
  final UnsplashImage item;
  bool isLiked = false;

  _FullScreenViewState(this.item);

  @override
  void initState() {
    isLiked = item.liked_by_user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: new GestureDetector(
        key: new Key(item.urls.regular),
        onTap: () => Navigator.pop(context),
        child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(item.urls.regular),
                      fit: BoxFit.cover
                  ),
                ),
              ),
              Align(
                  alignment: Alignment(0.8, 0.9),
                  child: FloatingActionButton(
                    onPressed: () {
                      StoreProvider.of<AppState>(context).dispatch(LikeAction(image: item));
                      setState(() => isLiked = !isLiked);
                    },
                    child: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                  )
              )
            ]),
      ),
    );
  }
}

void showItem(BuildContext context, UnsplashImage item) {
  Navigator.push(
    context,
    new MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return new FullScreenView(item);
      },
    ),
  );
}