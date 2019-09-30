import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_list_test/data/UnsplashImage.dart';

var clientId = '5e23ff0ddcb2c357b87f2f9ca557744dffc35aa0d12b7fb38ff759de35720e54';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unsplash API test',
      home: UnsplashImageView(),
    );
  }
}

class UnsplashImageView extends StatefulWidget {
  @override
  UnsplashCardsListState createState() => UnsplashCardsListState();
}

class UnsplashCardsListState extends State<UnsplashImageView> {
  List<UnsplashImage> dataList = [];

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
    dataList.clear();
    for(int i = 0; i < 6; i++) dataList.add(new UnsplashImage('id', 'dscr', 'adscr', 'color', 100, 100, null, null));
    Future<List<UnsplashImage>> post = fetchImages();
    post.then((List<UnsplashImage> result) => dataList.addAll(result));
    return Scaffold(
      appBar: AppBar(
        title: Text('Unsplash api test'),
      ),
      body: buildImageCard(),
    );
  }
}

Future<List<UnsplashImage>> fetchImages() async {
  final response = await  http.get('https://api.unsplash.com/photos/?client_id=' + clientId);
  if (response.statusCode == 200) {
    return (json.decode(response.body) as List).map<UnsplashImage>((i) => UnsplashImage.fromJson(i)).toList();
  } else {
    throw Exception('Failed to load post');
  }
}