
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

final GetIt INJECTOR = GetIt.instance;
final FirebaseAuth FIREBASE_INSTANCE = FirebaseAuth.instance;
final User? CURRENT_USER = FIREBASE_INSTANCE.currentUser;