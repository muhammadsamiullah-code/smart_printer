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
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // 👈 important
  final box = GetStorage();
  String savedLang = box.read('languageCode') ?? 'en';
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BottomNavProvider()),
        ChangeNotifierProvider(create: (context) => LabelProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider(savedLang)),
        ChangeNotifierProvider(create: (_) => TranslatorProvider(savedLang)),
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Scanner',
      supportedLocales: const [
        Locale('en'),
        Locale('af'),
        // Locale('sq'),
        // Locale('am'),
        Locale('ar'),
        // Locale('hy'),
        // Locale('az'),
        Locale('bn'),
        // Locale('eu'),
        // Locale('be'),
        // Locale('bg'),
        // Locale('my'),
        // Locale('ca'),
        Locale('zh'),  // Chinese Simplified
        Locale('zh', 'TW'), // Chinese Traditional
        // Locale('zh', 'CN'), // Chinese Simplified
        // Locale('zh', 'TW'), // Chinese Traditional
        // Locale('hr'),
        // Locale('cs'),
        // Locale('da'),
        // Locale('nl'),
        // Locale('et'),
        // Locale('fil'),
        // Locale('fi'),
        Locale('fr'),
        // Locale('gl'),
        // Locale('ka'),
        Locale('de'),
        // Locale('el'),
        // Locale('gu'),
        // Locale('he'), // Hebrew (not iw)
        Locale('hi'),
        // Locale('hu'),
        // Locale('is'),
        Locale('id'),
        Locale('it'),
        Locale('ja'),
        // Locale('kn'),
        // Locale('kk'),
        // Locale('km'),
        Locale('ko'),
        // Locale('ky'),
        // Locale('lo'),
        // Locale('lv'),
        // Locale('lt'),
        // Locale('mk'),
        Locale('ms'),
        // Locale('ml'),
        // Locale('mr'),
        // Locale('mn'),
        // Locale('ne'),
        // Locale('no'),
        Locale('fa'),
        Locale('pl'),
        Locale('pt'),
        // Locale('pa'),
        // Locale('ro'),
        // // Locale('rm'),
        Locale('ru'),
        // Locale('sr'),
        // Locale('si'),
        // Locale('sk'),
        // Locale('sl'),
        Locale('es'),
        // Locale('sw'),
        // Locale('sv'),
        // Locale('ta'),
        // Locale('te'),
        Locale('th'),
        Locale('tr'),
        // Locale('uk'),
        // Locale('ur'),
        Locale('vi'),
        // Locale('zu'),
      ],
      localizationsDelegates: const [
         FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
     
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
    );
  }
}