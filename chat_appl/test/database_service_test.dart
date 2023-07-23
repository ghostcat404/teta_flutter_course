import 'package:chat_appl/models/user.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_appl/services/database_service.dart';
import "package:firebase_database_mocks/firebase_database_mocks.dart";

void main() {
  late FirebaseDatabase firebaseDatabase;
  late DatabaseService databaseService;

  const userId = 'userId';
  const userName = 'Elon musk';
  const photoUrl = 'url-to-photo.jpg';
  const fakeData = {
    'users': {
      userId: {
        'displayName': userName,
        'photoUrl': photoUrl,
      },
    }
  };

  MockFirebaseDatabase.instance.ref().set(fakeData);

  setUp(() {
    firebaseDatabase = MockFirebaseDatabase.instance;
    databaseService = DatabaseService(dbInstance: firebaseDatabase);
  });

  test('Get user name from fake database', () async {
    final String userNameFromFakeDatabase = await databaseService.getUserName(userId);
    expect(userNameFromFakeDatabase, equals(userName));
  });

  test('Get user from fake database', () async {
    final User? userFromFakeDatabase = await databaseService.getUser(userId);
    expect(
      userFromFakeDatabase,
      const User(id: userId, displayName: userName, photoUrl: photoUrl)
    );
  });
}