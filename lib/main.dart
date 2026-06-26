import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'utils/router.dart';
import 'utils/theme.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase Firestore with platform options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization info: $e");
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Locale? locale;
  const MyApp({super.key, this.locale});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ProjectKu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: goRouter,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id'), // Indonesia (Default)
        Locale('en'), // English
      ],
    );
  }
}
