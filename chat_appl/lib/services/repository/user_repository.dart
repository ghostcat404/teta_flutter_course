import 'package:firebase_database/firebase_database.dart';
import 'package:isar/isar.dart';

class UserRepository {
  UserRepository({required this.isar, required this.firebaseDatabase});

  final FirebaseDatabase firebaseDatabase;
  final Isar isar;
}
