import 'package:flutter/cupertino.dart';
import 'package:hello_me/auth_repository.dart';
import 'package:english_words/english_words.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavedRepository with ChangeNotifier {
  final AuthRepository _auth;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final Set<WordPair> _personalWordsLocal = <WordPair>{};

  SavedRepository(this._auth);

  void update(AuthRepository currAuth) async {
    if (_auth.user != currAuth.user) {
      if (currAuth.isAuthenticated) {
        DocumentReference userReference =
        users.doc(currAuth.user?.uid);

        Set<WordPair> userWordPairs = await __getUserPersonalWords();
        _personalWordsLocal.addAll(userWordPairs);

        await userReference.set({
          'suggestions': _personalWordsLocal
              .map((e) => {'first': e.first, 'second': e.second})
              .toList()
        });
      } else {
        _personalWordsLocal.clear();
      }
      notifyListeners();
    }
  }

  Set<WordPair> get saved {
    return _personalWordsLocal;
  }

  Stream<Set<WordPair>> get _personalSavedStream async* {
    yield _personalWordsLocal;
  }

  Stream<Set<WordPair>> get savedStream {
    if (_auth.isAuthenticated) {
      return users
          .doc(_auth.user?.uid)
          .snapshots()
          .map<Set<WordPair>>((snapshot) {
        Map<String, dynamic>? userData = snapshot.data();
        return userData?['suggestions']
            .map<WordPair>((e) => WordPair(e['first'], e['second']))
            .toSet();
      });
    }
    return _personalSavedStream;
  }

  Future<Set<WordPair>> __getUserPersonalWords() async {
    DocumentReference userReference = users.doc(_auth.user?.uid);
    DocumentSnapshot userSnapshot = await userReference.get();

    Set<WordPair> userWords = {};
    if (userSnapshot.exists) {
      Map<String, dynamic>? userData = userSnapshot.data();
      Set<WordPair> userWordPairs = userData?['suggestions']
          .map<WordPair>((e) => WordPair(e['first'], e['second']))
          .toSet();
      userWords.addAll(userWordPairs);
    }
    return userWords;
  }

  void saveSuggestion(WordPair suggestion) async {
    if (_auth.isAuthenticated) {
      DocumentReference userReference = users.doc(_auth.user?.uid);

      Set<WordPair> userPersonalWords = await __getUserPersonalWords();
      userPersonalWords.add(suggestion);

      await userReference.set({
        'suggestions': userPersonalWords
            .map(
                (WordPair pair) => {'first': pair.first, 'second': pair.second})
            .toList()
      });
    } else {
      _personalWordsLocal.add(suggestion);
    }
    notifyListeners();
  }

  void deleteSuggestion(WordPair suggestion) async {
    if (_auth.isAuthenticated) {
      DocumentReference userReference = users.doc(_auth.user?.uid);

      Set<WordPair> userWords = await __getUserPersonalWords();
      userWords.remove(suggestion);

      await userReference.set({
        'suggestions': userWords
            .map((e) => {'first': e.first, 'second': e.second})
            .toList()
      });
    } else {
      _personalWordsLocal.remove(suggestion);
    }
    notifyListeners();
  }
}
