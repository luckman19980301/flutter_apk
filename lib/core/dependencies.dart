import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/services/AuthenticationService.dart';

void setupDependencies() {

  INJECTOR.registerSingleton<IAuthenticationService>(AuthenticationService());
}