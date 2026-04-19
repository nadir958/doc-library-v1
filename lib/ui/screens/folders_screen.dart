import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/folder_provider.dart';
import '../providers/scan_provider.dart';
import 'dashboard_screen.dart';
import 'manual_capture_screen.dart';
import 'capture_preview_screen.dart';
import '../theme/app_theme.dart';
import 'package:doc_library/generated/l10n/app_localizations.dart';

class FoldersScreen extends ConsumerWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(folderListProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.folders, style: theme.textTheme.titleLarge),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.folders,
                        style: theme.textTheme.headlineLarge,
                      ),
                      IconButton.filled(
                        onPressed: () => _showAddFolderDialog(context, ref),
                        icon: const Icon(Icons.create_new_folder_outlined),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          foregroundColor: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Organisez vos documents sensibles dans des coffres chiffrés. Chaque dossier est protégé.",
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          foldersAsync.when(
            data: (folders) {
              if (folders.isEmpty) {
                return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.folder_copy_outlined, size: 80, color: theme.colorScheme.primary.withOpacity(0.2)),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.noDocuments.toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          letterSpacing: 2,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Créez votre premier dossier pour organiser vos scans.",
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => _showAddFolderDialog(context, ref),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.newFolder),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 120), // Push content up above bottom nav
                    ],
                  ),
                ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final folder = folders[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
                          boxShadow: [
                            BoxShadow(
                              color: theme.brightness == Brightness.dark ? Colors.black.withOpacity(0.2) : theme.colorScheme.primary.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DashboardScreen(folder: folder),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.folder_rounded, size: 32, color: Colors.amber),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      folder.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          l10n.viewDocuments.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.arrow_forward, size: 10, color: theme.colorScheme.primary),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: folders.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Erreur: $err'))),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 110, left: 16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showCaptureOptions(context, ref),
          child: const Icon(Icons.add_a_photo, size: 24),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: theme.brightness == Brightness.dark ? AppTheme.backgroundColor : Colors.white,
          shape: const CircleBorder(),
        ),
      ),
    );
  }

  void _showAddFolderDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.newFolder, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: l10n.folderName,
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(folderListProvider.notifier).createFolder(controller.text);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  void _showCaptureOptions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.auto_awesome, color: Colors.amberAccent),
                title: Text(l10n.smartScan),
                subtitle: Text(l10n.smartScanDesc),
                onTap: () async {
                  Navigator.pop(ctx);
                  final images = await ref.read(scanServiceProvider).startSmartScan();
                  if (images != null && images.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CapturePreviewScreen(imagePaths: images),
                      ),
                    );
                  }
                },
              ),
              Divider(color: theme.colorScheme.onSurface.withOpacity(0.05)),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.lightBlueAccent),
                title: Text(l10n.takePhoto),
                onTap: () async {
                  Navigator.pop(ctx);
                  final cameras = await availableCameras();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManualCaptureScreen(cameras: cameras)),
                  );
                },
              ),
              Divider(color: theme.colorScheme.onSurface.withOpacity(0.05)),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.orangeAccent),
                title: Text(l10n.fromGallery),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final images = await picker.pickMultiImage();
                  if (images.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CapturePreviewScreen(
                          imagePaths: images.map((e) => e.path).toList(),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
