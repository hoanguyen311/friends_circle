import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:friends_circle/ui/widgets/widgets.dart';
import 'package:friends_circle/models/models.dart';
import 'package:friends_circle/ui/screens/screens.dart';

class UsersScreen extends StatefulWidget {

  static final String routeName = '/users';

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final googleSignIn = GoogleSignIn();
  final menuChoices = <MenuPopupChoice>[
    MenuPopupChoice(title: 'Log Out', iconData: Icons.exit_to_app, choiceKey: MenuPopupChoices.logout),
    MenuPopupChoice(title: 'Profile Settings', iconData: Icons.settings, choiceKey: MenuPopupChoices.settings),
  ];
  bool isLoading = false;
  User loggedInUser;

  @override
  void initState() {

    super.initState();

    User.loadUserFromSharedPreferences()
      .then((user) {
        setState(() {
          loggedInUser = user;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopHandler,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Users'),
          actions: <Widget>[
            _renderMenuButton()
          ],
        ),
        body: FullScreenSpinner(
          isLoading: isLoading,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _renderMenuButton() {
    return PopupMenuButton<MenuPopupChoice>(
      onSelected: _onMenuItemSelected,
      itemBuilder: (context) => menuChoices.map((choice) => _buildMenuChoice(choice)).toList(),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || loggedInUser == null) {
          return Spinner();
        }

        final items = snapshot.data.documents
            .where((document) => document.data['id'] != loggedInUser.id)
            .toList();

        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (context, i) => Divider(height: 16,),
          itemBuilder: (context, i) {
            return _buildItem(items[i]);
          },
        );
      },
    );
  }

  Widget _buildItem(DocumentSnapshot document) {
    User user = User.fromJson(document.data);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        title: Text(user.nickName),
        subtitle: user.aboutMe.isEmpty ? null : Text(user.aboutMe),
        leading: Container(
          child: ClipOval(
              child: Image.network(user.photoUrl, fit: BoxFit.fill, height: 96.0, width: 60.0,)
          ),
        ),
      ),
    );
  }

  PopupMenuItem<MenuPopupChoice> _buildMenuChoice(MenuPopupChoice choice) {
    return PopupMenuItem<MenuPopupChoice>(
      value: choice,
      child: Row(
        children: <Widget>[
          Icon(choice.iconData),
          SizedBox(width: 5),
          Text(choice.title)
        ],
      ),
    );
  }

  void _onMenuItemSelected(MenuPopupChoice value) {

    switch (value.choiceKey) {
      case MenuPopupChoices.settings:
          Navigator.of(context).pushNamed(SettingsScreen.routeName);
          break;
      case MenuPopupChoices.logout:

        _handleLogOut()
            .then((_) {
                Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (Route<dynamic> route) => false);
            });
          break;
    }
  }

  Future<Null> _handleLogOut() async {
    setState(() {
      isLoading = false;
    });



    await Future.wait([
      FirebaseAuth.instance.signOut(),
      googleSignIn.disconnect(),
      googleSignIn.signOut(),
    ]);

    setState(() {
      isLoading = false;
    });

  }

  Future<bool> _willPopHandler() async {
    final shouldExit = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Do you want to exit app?'),

          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.blue
                  ),
                  child: SimpleDialogOption(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text('Log Out', style: TextStyle(color: Colors.white),),
                  ),
                ),
                SizedBox(
                  width: 8,
                )
                ,
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      color: Colors.white
                  ),
                  child: SimpleDialogOption(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text('No, stay'),
                  ),
                ),
              ],
            )
          ],
        );
      }
    );

    if (shouldExit) {
      await _handleLogOut();
    }

    return shouldExit;
  }
}
