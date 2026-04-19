import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/capture_provider.dart';
import '../providers/folder_provider.dart';
import '../../data/models/models.dart';
import 'package:doc_library/generated/l10n/app_localizations.dart';

class CapturePreviewScreen extends ConsumerStatefulWidget {
  final List<String> imagePaths;
  final int? existingDocId;

  const CapturePreviewScreen({
    super.key, 
    required this.imagePaths, 
    this.existingDocId,
  });

  @override
  ConsumerState<CapturePreviewScreen> createState() => _CapturePreviewScreenState();
}

class _CapturePreviewScreenState extends ConsumerState<CapturePreviewScreen> {
  late List<String> _currentImages;
  int? _selectedFolderId;

  @override
  void initState() {
    super.initState();
    _currentImages = List.from(widget.imagePaths);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final captureState = ref.watch(captureProvider);
    final foldersAsync = ref.watch(folderListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingDocId != null ? l10n.addPages : l10n.capturePreview, style: theme.textTheme.titleLarge),
      ),
      body: captureState.when(
        data: (_) => Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: _currentImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1)),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.file(
                            File(_currentImages[index]),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => setState(() => _currentImages.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Save Area
            Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.existingDocId == null) ...[
                    foldersAsync.when(
                      data: (folders) => Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _selectedFolderId,
                                  isExpanded: true,
                                  dropdownColor: theme.colorScheme.surface,
                                  hint: Text(l10n.selectFolder, style: const TextStyle(fontSize: 14)),
                                  items: [
                                    DropdownMenuItem(value: null, child: Text(l10n.rootFolder)),
                                    ...folders.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))),
                                  ],
                                  onChanged: (val) => setState(() => _selectedFolderId = val),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton.filled(
                            onPressed: () => _showNewFolderDialog(context),
                            icon: const Icon(Icons.create_new_folder_outlined),
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.1),
                              foregroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ],
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer.withOpacity(1.0)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _currentImages.isEmpty
                          ? null
                          : () async {
                              if (widget.existingDocId != null) {
                                await ref
                                    .read(captureProvider.notifier)
                                    .addPagesToDocument(widget.existingDocId!, _currentImages);
                              } else {
                                await ref
                                    .read(captureProvider.notifier)
                                    .processCapture(_currentImages, folderId: _selectedFolderId);
                              }
                              if (mounted) Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: theme.brightness == Brightness.dark ? AppTheme.backgroundColor : Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.auto_fix_high_outlined),
                      label: Text(
                        (widget.existingDocId != null ? l10n.addPages : l10n.addDocument).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 32),
              Text(l10n.ocrInProgress.toUpperCase(), style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12)),
              const SizedBox(height: 8),
              Text("Sécurisation de vos données...", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.24), fontSize: 12)),
            ],
          ),
        ),
        error: (err, st) => Center(child: Text("Erreur: $err")),
      ),
    );
  }

  void _showNewFolderDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.newFolder, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: l10n.folderName,
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: TextStyle(color: theme.colorScheme.onSurfaceVariant))),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final folderId = await ref.read(folderListProvider.notifier).createFolder(controller.text);
                setState(() => _selectedFolderId = folderId);
              }
              if (context.mounted) Navigator.pop(context);
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
}
