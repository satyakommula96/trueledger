import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trueledger/l10n/app_localizations.dart';
import 'package:trueledger/core/theme/theme.dart';

Widget wrapWidget(Widget child,
    {List overrides = const [],
    List<NavigatorObserver> navigatorObservers = const [],
    ThemeData? theme}) {
  return ProviderScope(
    overrides: List.from(overrides),
    child: MaterialApp(
      theme: theme ?? AppTheme.darkTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('te', ''),
      ],
      home: child,
      navigatorObservers: navigatorObservers,
    ),
  );
}
