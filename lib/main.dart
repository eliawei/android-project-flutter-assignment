import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart'; // Add this line.
import 'package:provider/provider.dart';
import 'login.dart';
import 'auth_repository.dart';
import 'saved_repository.dart';
import 'saved_suggestions.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'grabbing_widget.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthRepository.instance()),
      ChangeNotifierProxyProvider<AuthRepository, SavedRepository>(
          create: (_) => SavedRepository(AuthRepository.instance()),
          update: (_, auth, savedRepo) {
            savedRepo?.update(auth);
            return savedRepo as SavedRepository;
          }),
    ],
    child: App(),
  ));
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthRepository>(builder: (context, auth, _) {
      final bool userLogged = auth.isAuthenticated;
      return MaterialApp(
        title: 'Startup Name Generator',
        theme: ThemeData(
            // Add the 3 lines from here...
            primaryColor: Colors.red),
        home: Scaffold(
          body: auth.isAuthenticated
              ? MySnappingSheet(RandomWords(), _storage)
              : RandomWords(),
        ),
      );
    });
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[]; // NEW
  final _biggerFont = const TextStyle(fontSize: 18); // NEW

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthRepository, SavedRepository>(
        builder: (context, auth, savedRepo, _) {
      return StreamBuilder(
          stream: savedRepo.savedStream,
          builder:
              (BuildContext context, AsyncSnapshot<Set<WordPair>> snapshot) {
            Set<WordPair> savedStream = snapshot.data ?? {};
            return Scaffold(
              appBar: AppBar(
                title: Text('Startup Name Generator'),
                actions: [
                  IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
                  _loginAction(),
                ],
              ),
              body: _buildSuggestions(savedRepo, savedStream),
            );
          });
    });
  }

  Widget _buildSuggestions(
      SavedRepository savedRepo, Set<WordPair> savedStream) {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return Divider();
          }
          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(
              _suggestions[index], savedRepo, savedStream, _context);
        });
  }

  Widget _buildRow(WordPair pair, SavedRepository savedRepo,
      Set<WordPair> savedStream, BuildContext context) {
    final alreadySaved = savedStream.contains(pair); // NEW
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        // NEW from here...
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ), // ... to here.
      onTap: () {
        // NEW lines from here...
        setState(() {
          if (alreadySaved) {
            savedRepo.deleteSuggestion(pair);
          } else {
            savedRepo.saveSuggestion(pair);
          }
        });
      }, // ... to here.
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) => SavedSuggestions()));
  }

  void __login() {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) => LoginPage()));
  }

  Widget _loginAction() {
    return Consumer<AuthRepository>(
        builder: (context, auth, _) => auth.status == Status.Authenticated
            ? IconButton(icon: Icon(Icons.exit_to_app), onPressed: auth.signOut)
            : IconButton(icon: Icon(Icons.login), onPressed: __login));
  }
}
