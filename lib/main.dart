import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'utils/app_theme.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/todo_viewmodel.dart';
import 'views/splash_view.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 데이터베이스 서비스 사전 초기화
  final dbService = DatabaseService();
  await dbService.database;
  debugPrint('데이터베이스 초기화 완료');

  // 알림 권한 요청 (Android 13+ 대응)
  if (Platform.isAndroid) {
    await _requestNotificationPermissions();
  }

  await initializeDateFormatting('ko_KR', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => TodoViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

// Android 13 이상에서 알림 권한 요청
Future<void> _requestNotificationPermissions() async {
  try {
    // permission_handler 패키지를 사용하여 알림 권한 요청
    if (await Permission.notification.status.isDenied) {
      await Permission.notification.request();
    }
  } catch (e) {
    debugPrint('알림 권한 요청 중 오류 발생: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '할 일 목록',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const SplashView(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      locale: const Locale('ko', 'KR'),
    );
  }
}
