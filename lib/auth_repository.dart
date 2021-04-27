import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class AuthRepository with ChangeNotifier {
  FirebaseAuth _auth;
  User? _user;
  Status _status = Status.Uninitialized;
  String _avatarURL = "";


  AuthRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _user = _auth.currentUser;
    _onAuthStateChanged(_user);
  }

  Status get status => _status;

  User? get user => _user;

  bool get isAuthenticated => status == Status.Authenticated;

  String? get avatarURL => _avatarURL;

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print(e);
      _status = Status.Unauthenticated;
      notifyListeners();
      return null;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    _avatarURL="";

    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _avatarURL="";
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }

  void changeAvatarURL(String url){
    _avatarURL = url;
    notifyListeners();
  }
}

