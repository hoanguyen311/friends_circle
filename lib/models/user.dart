import 'package:json_annotation/json_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  String nickName;
  String photoUrl;
  String id;
  String aboutMe;

  User({this.nickName, this.photoUrl, this.id, this.aboutMe});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  factory User.fromFirebaseUser(FirebaseUser firebaseUser) => User(
    nickName: firebaseUser.displayName,
    photoUrl: firebaseUser.photoUrl,
    id: firebaseUser.uid,
    aboutMe: ''
  );

  Map<String, dynamic> toJson() => _$UserToJson(this);

  static Future<User> loadUserFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    return User(
      nickName: prefs.getString('nickName'),
      id: prefs.getString('id'),
      photoUrl: prefs.getString('photoUrl'),
      aboutMe: prefs.getString('aboutMe'),
    );
  }

  static Future<void> saveUserToSharedPreferences(User user) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait(
        [
          prefs.setString('id', user.id),
          prefs.setString('nickName', user.nickName),
          prefs.setString('photoUrl', user.photoUrl),
          prefs.setString('aboutMe', user.aboutMe)
        ]
    );
  }
}