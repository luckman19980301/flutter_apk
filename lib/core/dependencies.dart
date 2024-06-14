import 'package:get_it/get_it.dart';
import 'package:meet_chat/core/services/AuthenticationService.dart';

import 'globals.dart';


void setupDependencies() {

  injector.registerSingleton<IAuthenticationService>(AuthenticationService());

}