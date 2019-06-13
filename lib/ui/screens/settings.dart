import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friends_circle/models/models.dart';
import 'package:friends_circle/ui/widgets/widgets.dart';

class SettingsScreen extends StatefulWidget {
  static final String routeName = '/settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User currentUser;
  TextEditingController _nickNameController;
  FocusNode _nickNameFocus = new FocusNode();

  TextEditingController _bioController;
  FocusNode _bioFocus = new FocusNode();
  File selectedImageFile;
  bool isLoading = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadUserFromLocal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Profile Settings'),
      ),
      body: currentUser == null ? Spinner() : _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return FullScreenSpinner(
      isLoading: isLoading,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Form(child: Column(
          children: <Widget>[
            _buildImage(),
            SizedBox(height: 10),
            TextField(
              focusNode: _nickNameFocus,
              controller: _nickNameController,
              decoration: InputDecoration(
                labelText: 'Nickname'
              ),
              onChanged: (text) {
                setState(() {
                  currentUser.nickName = text;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              focusNode: _bioFocus,
              controller: _bioController,
              decoration: InputDecoration(
                labelText: 'Bio'
              ),
              onChanged: (text) {
                setState(() {
                  currentUser.aboutMe = text;
                });
              },
            ),
            SizedBox(height: 15),
            RaisedButton(onPressed: _handleUpdate, child: Text('Update', style: TextStyle(color: Colors.white),), color: Colors.blueAccent,)
          ],
        )),
      ),
    );
  }



  Future<void> _loadUserFromLocal() async {
    currentUser = await User.loadUserFromSharedPreferences();

    _nickNameController = TextEditingController(text: currentUser.nickName);
    _bioController = TextEditingController(text: currentUser.aboutMe);

    setState(() {

    });
  }

  @override
  void dispose() {
    super.dispose();
    _nickNameController.dispose();
    _bioController.dispose();
  }

  Widget _buildImage() {


    return Stack(
      alignment: Alignment(10, 10),
      children: <Widget>[
        ClipOval(child: selectedImageFile != null ?
          Image.file(selectedImageFile, width: 96, height: 96, fit: BoxFit.cover,) :
        Image.network(currentUser.photoUrl, width: 96, height: 96, fit: BoxFit.cover)),
        Positioned(
          width: 96,
          bottom: -5,
          left: 0,
          child: Container(
            child: Align(
              child: IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.white),
                onPressed: _handleSelectImage,
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<Null> _handleSelectImage() async {
    selectedImageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {

    });
  }

  void _handleUpdate() async {
    setState(() {
      isLoading = true;
    });

    _nickNameFocus.unfocus();
    _bioFocus.unfocus();

    try {

      await Future.wait([
        _uploadAvatar(),
        Firestore.instance.collection('users').document(currentUser.id)
            .updateData(currentUser.toJson()),
        User.saveUserToSharedPreferences(currentUser)
      ]);

      _showSnackBar('Update success!');
    } catch(e) {
      _showSnackBar('Error!');
    }

    setState(() {
      isLoading = false;
    });

  }

  Future<void> _uploadAvatar() async {
    if (selectedImageFile == null) {
      return;
    }

    try {
      final StorageReference ref = FirebaseStorage.instance.ref().child(currentUser.id);
      final StorageUploadTask uploadTask = ref.putFile(selectedImageFile);
      final StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      final url = await taskSnapshot.ref.getDownloadURL();

      currentUser.photoUrl = url as String;
    } catch(e) {
      _showSnackBar('Error when uploading avatar!');
    }


  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(text)));
  }
}
