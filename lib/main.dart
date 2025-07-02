import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'utils/app_theme.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/todo_viewmodel.dart';
import 'views/splash_view.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 데이터베이스 초기화 문제 해결을 위해 기존 데이터베이스 삭제 (개발 중에만 사용)
  try {
    String path = join(await getDatabasesPath(), 'todo_database.db');
    await deleteDatabase(path);
    debugPrint('기존 데이터베이스 삭제 완료');
  } catch (e) {
    debugPrint('데이터베이스 삭제 중 오류: $e');
  }

  // 데이터베이스 서비스 사전 초기화
  final dbService = DatabaseService();
  await dbService.database;
  debugPrint('데이터베이스 초기화 완료');

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
