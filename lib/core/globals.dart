
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

final GetIt INJECTOR = GetIt.instance;
final FirebaseAuth FIREBASE_INSTANCE = FirebaseAuth.instance;
final FirebaseStorage FIREBASE_STORAGE = FirebaseStorage.instance;
final User? CURRENT_USER = FIREBASE_INSTANCE.currentUser;
final FirebaseFirestore FIREBASE_FIRESTORE = FirebaseFirestore.instance;

