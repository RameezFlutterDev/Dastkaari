import 'package:dastkaari/firebase_options.dart';
import 'package:dastkaari/provider/adsProvider/ads_provider.dart';
import 'package:dastkaari/provider/languageProvider.dart';
import 'package:dastkaari/views/auth/auth_gate.dart';
import 'package:dastkaari/views/auth/login.dart';
import 'package:dastkaari/views/auth/splash.dart';
import 'package:dastkaari/views/home/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> backgroundMessageHandler(RemoteMessage message) async {
  print("📩 Background Notification: ${message.notification?.title}");
}

// ✅ Request permission for notifications
Future<void> requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('✅ User granted notification permission');
  } else {
    print('❌ User denied notification permission');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔄 Step 1: Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Step 2: Now it's safe to handle messages
  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

  await requestPermission(); // Ask for permission after Firebase is ready

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("📲 Foreground Notification: ${message.notification?.title}");
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ur'),
        Locale('en'),
      ],
      home: SplashScreen(),
    );
  }
}
