import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:doc_library/generated/l10n/app_localizations.dart';
import 'data/models/models.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/main_navigation_screen.dart';
import 'ui/providers/settings_provider.dart';

// Provider pour l'instance Isar
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError("Isar n'a pas été initialisé");
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  
  // Initialisation d'Isar
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [DocumentModelSchema, PageModelSchema, FolderModelSchema],
    directory: dir.path,
  );

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const DocLibraryApp(),
    ),
  );
}

class DocLibraryApp extends ConsumerWidget {
  const DocLibraryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Doc Library',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('ar'),
      ],
      home: const MainNavigationScreen(),
    );
  }
}
