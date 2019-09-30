import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

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
  List<String> dataList = [];

  Widget buildImageCard() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: dataList.length,
        itemBuilder: (context, i) {
          return _buildRow(dataList[i]);
        });
  }
  // #enddocregion _buildSuggestions

  // #docregion _buildRow
  Widget _buildRow(String blabla) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.network('https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
            ListTile(
              //leading: Icon(Icons.album),
              title: Text(blabla),
              subtitle: Text(blabla),
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
    dataList.addAll(['what', 'the', 'fuck']);
    return Scaffold(
      appBar: AppBar(
        title: Text('Unsplash api test'),
      ),
      body: buildImageCard(),
    );
  }
}