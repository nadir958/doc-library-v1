import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/folder_provider.dart';
import 'dashboard_screen.dart';
import 'package:doc_library/generated/l10n/app_localizations.dart';

class FoldersScreen extends ConsumerWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(folderListProvider);

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.folders, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: foldersAsync.when(
        data: (folders) {
          if (folders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(l10n.noDocuments, style: const TextStyle(color: Colors.white54)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddFolderDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.newFolder),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardScreen(folder: folder),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder, size: 48, color: Colors.amberAccent),
                      const SizedBox(height: 12),
                      Text(
                        folder.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      // Pour une version plus complexe, on pourrait utiliser un StreamProvider pour compter
                      const SizedBox(height: 4),
                      Text(
                        l10n.viewDocuments,
                        style: const TextStyle(fontSize: 12, color: Colors.indigoAccent),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFolderDialog(context, ref),
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.create_new_folder),
      ),
    );
  }

  void _showAddFolderDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(l10n.newFolder),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: l10n.folderName,
            filled: true,
            fillColor: Colors.black12,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(folderListProvider.notifier).createFolder(controller.text);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigoAccent,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }
}
