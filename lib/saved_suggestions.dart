import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hello_me/saved_repository.dart';
import 'package:english_words/english_words.dart';

class SavedSuggestions extends StatelessWidget {
  final _biggerFont = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Consumer<SavedRepository>(builder: (context, savedRepo, _) {
      return StreamBuilder<Set<WordPair>>(
        stream: savedRepo.savedStream,
        builder: (BuildContext context, AsyncSnapshot<Set<WordPair>> snapshot) {
          Set<WordPair> lastSnapshot = snapshot.data ?? {};
          if (snapshot.hasError) {
            return Text('Error has accured');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading data");
          }

          final tiles = lastSnapshot.map(
                (WordPair pair) {
              return ListTile(
                  title: Text(
                    pair.asPascalCase,
                    style: _biggerFont,
                  ),
                  trailing: IconButton(
                      icon: Icon(Icons.delete_outline_rounded),
                      onPressed: () {
                        savedRepo.deleteSuggestion(pair);
                      }));
            },
          );
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: lastSnapshot.isNotEmpty
                ? ListView(children: divided)
                : SafeArea(child: Text('No saved suggestions')),
          );
        },
      );
    });
  }
}
