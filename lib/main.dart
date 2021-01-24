import 'dart:convert';

import 'package:delivery_app/src/models/user.dart';
import 'package:delivery_app/src/pages/home.dart';

import 'package:delivery_app/src/providers/preferences.dart';
import 'package:delivery_app/src/states/globalState.dart';
import 'package:delivery_app/src/utils/colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

Color colorPrimary = visitColor;
Color colorSecondary = adminColor;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final _preferences = PreferencesUser();
  await _preferences.initPrefs();

  if (_preferences.userData.length != 1) {
    User user = User.fromjson(json.decode(_preferences.userData));

    if (user.type == "admin") {
      colorPrimary = adminColor;
      colorSecondary = visitColor;
    } else if (user.type == "seller") {
      colorPrimary = sellerColor;
    }
  }
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppGlobalState(),
        )
      ],
      child: MaterialApp(
        theme: ThemeData(
          accentColor: colorPrimary,
          textTheme: GoogleFonts.nunitoTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: [
          const Locale('en'), // Inglés
          const Locale('es'), // Español
        ],
        title: 'Guadas',
        home: Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) => HomePage(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
            ),
          ),
        ),
      ),
    );
  }
}
