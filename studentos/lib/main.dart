import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; // Import Intl
import 'package:intl/date_symbol_data_local.dart'; // Import locale data
import 'package:studentos/config/routes.dart';
import 'package:studentos/config/theme.dart';
import 'package:studentos/services/notification_service.dart';
import 'package:studentos/domain/models/task_model.dart';
import 'package:studentos/domain/models/note_model.dart';
import 'package:studentos/domain/models/stats_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Force English Locale
  Intl.defaultLocale = 'en_US';
  await initializeDateFormatting('en_US', null);

  // 2. Init Local Database
  await Hive.initFlutter();
  
  Hive.registerAdapter(TaskAdapter()); 
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(NoteBlockAdapter());
  Hive.registerAdapter(FocusSessionAdapter());

  await Hive.openBox<Task>('tasks');
  await Hive.openBox<Note>('notes');
  await Hive.openBox<FocusSession>('sessions');
  await Hive.openBox('settings');

  // 3. Init Notifications
  await NotificationService.init();

  runApp(const ProviderScope(child: StudentOSApp()));
}

class StudentOSApp extends ConsumerWidget {
  const StudentOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'StudentOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      // Explicitly set locale
      locale: const Locale('en', 'US'), 
    );
  }
}