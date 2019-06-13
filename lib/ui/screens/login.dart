import 'package:flutter/material.dart';
import 'package:friends_circle/ui/widgets/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friends_circle/models/models.dart';
import 'package:friends_circle/ui/screens/screens.dart';

class LoginScreen extends StatefulWidget {
  static final String routeName = '/';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  bool isLoggedIn = false;
  User loggedInUser;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _fireBaseUser = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    checkIsLoggedIn();
  }

  void checkIsLoggedIn() async {
    setState(() {
      isLoading = true;
    });
    final isSignedIn = await _googleSignIn.isSignedIn();

    if (isSignedIn) {
      final loggedInUser = await User.loadUserFromSharedPreferences();

      Navigator.of(context).pushNamed(UsersScreen.routeName, arguments: loggedInUser);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Friends Circle'),
      ),
      body: FullScreenSpinner(
        isLoading: isLoading,
        child: _buildBody(context),
      ),
    );
  }

  Future<Null> _handleSignIn() async {
    setState(() {
      isLoading = true;
    });
    final GoogleSignInAccount googleAccount = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken
    );

    final FirebaseUser firebaseUser = await _fireBaseUser.signInWithCredential(credential);

    if (firebaseUser != null) {
      User currentUser = await isExistedUser(firebaseUser);

      if (currentUser == null) {
        currentUser = createUser(firebaseUser);
      }

      await User.saveUserToSharedPreferences(currentUser);

      Navigator.of(context).pushNamed(UsersScreen.routeName, arguments: currentUser);


      setState(() {
        isLoading = false;
      });


    } else {
      setState(() {
        isLoading = false;
      });
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text('Login Failed!'))
      );
    }

  }

  Future<User> isExistedUser(FirebaseUser user) async {
    final QuerySnapshot querySnapshot = await Firestore
        .instance
        .collection('users')
        .where('id', isEqualTo: user.uid)
        .getDocuments();
    
    if (querySnapshot.documents.length == 0) {
      return null;
    }

    return User.fromJson(querySnapshot.documents[0].data);
  }

  User createUser(FirebaseUser firebaseUser) {
    User user = User.fromFirebaseUser(firebaseUser);

    Firestore.instance
        .collection('users')
        .document(user.id)
        .setData(user.toJson());
    return user;
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: _buildLoginButton(context),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return RaisedButton(
      child: Text(
          'Sign In with Google',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20.0
          )
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
      color: Colors.blue,
      onPressed: _handleSignIn,
    );
  }
}
