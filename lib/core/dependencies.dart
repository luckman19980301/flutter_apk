import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/services/AuthenticationService.dart';
import 'package:meet_chat/core/services/DatabaseService.dart';
import 'package:meet_chat/core/services/MessagingService.dart';
import 'package:meet_chat/core/services/StorageService.dart';

void setupDependencies() {
  INJECTOR.registerSingleton<IAuthenticationService>(AuthenticationService());
  INJECTOR.registerSingleton<IStorageService>(StorageService());
  INJECTOR.registerSingleton<IDatabaseService>(DatabaseService());
  INJECTOR.registerSingleton<IMessagingService>(MessagingService());

}