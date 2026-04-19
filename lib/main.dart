import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'data/models/models.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/main_navigation_screen.dart';

// Provider pour l'instance Isar
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError("Isar n'a pas été initialisé");
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
      ],
      child: const DocLibraryApp(),
    ),
  );
}

class DocLibraryApp extends StatelessWidget {
  const DocLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doc Library',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}
