import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/providers/labels_provider.dart';
import 'package:smart_scanner/providers/language_provider.dart';
import 'package:smart_scanner/providers/translator_provider.dart';
import 'package:smart_scanner/screens/splash_screen.dart';
import 'package:get_storage/get_storage.dart';
import 'providers/bottom_nav_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/question_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'services/notification_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background Message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  final quizProvider = QuizProvider();

  await quizProvider.loadQuestions();
  await GetStorage.init(); // 👈 important
  final box = GetStorage();
  String savedLang = box.read('languageCode') ?? 'en';
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BottomNavProvider()),
        ChangeNotifierProvider(create: (context) => LabelProvider()),
        ChangeNotifierProvider.value(value: quizProvider),
        ChangeNotifierProvider(create: (_) => LanguageProvider(savedLang)),
        ChangeNotifierProvider(create: (_) => TranslatorProvider(savedLang)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  @override
  void initState() {
    super.initState();
    initFCM();
  }

  void initFCM() async {
    await NotificationService.init();

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    String? token = await messaging.getToken();
    print("FCM Token: $token");

    // 🔥 IMPORTANT: Token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print("NEW TOKEN: $newToken");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground Message: ${message.notification?.title}");
      NotificationService.showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("Clicked Notification");
    });
  }
  // This widget is the root of your application.
  // void initFCM() async {
  //   await NotificationService.init();

  //   FirebaseMessaging messaging = FirebaseMessaging.instance;

  //   // Permission (IMPORTANT for Android 13+)
  //   await messaging.requestPermission();

  //   // Get Token (VERY IMPORTANT)
  //   String? token = await messaging.getToken();
  //   print("FCM Token: $token");

  //   // Foreground message
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print("Foreground Message: ${message.notification?.title}");
  //     NotificationService.showNotification(message);
  //   });

  //   // App opened from notification
  //   FirebaseMessaging.onMessageOpenedApp.listen((message) {
  //     print("Clicked Notification");
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Scanner',
      supportedLocales: const [
        Locale('en'),
        Locale('af'),
        Locale('ar'),
        Locale('bn'),
        Locale('zh'), // Chinese Simplified
        Locale('zh', 'TW'), // Chinese Traditional
        Locale('fr'),
        Locale('de'),
        Locale('hi'),
        Locale('id'),
        Locale('it'),
        Locale('ja'),
        Locale('ko'),
        Locale('ms'),
        Locale('fa'),
        Locale('pl'),
        Locale('pt'),
        Locale('ru'),
        Locale('es'),
        Locale('th'),
        Locale('tr'),
        Locale('vi'),
      ],
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffF5F6FA),
        //  scaffoldBackgroundColor:
        //   Color.fromRGBO(255, 255, 255, 1),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
    );
  }
}
