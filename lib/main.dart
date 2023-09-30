import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:the_natures_app/home.dart';
import 'firebase_options.dart';

import 'package:the_natures_app/resource/intl_resource.dart';
import 'package:the_natures_app/resource/theme_resource.dart';

import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: '.env');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: I18n().appName,
        theme: NatureTheme.getDefaultTheme(),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            User? currentUser = FirebaseAuth.instance.currentUser;

            if (currentUser == null) {
              return FutureBuilder<UserCredential>(
                future: FirebaseAuth.instance.signInAnonymously(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SplashScreen();
                  }
                  return const Home();
                },
              );
            }
            return const Home();
          },
        ));
  }
}
