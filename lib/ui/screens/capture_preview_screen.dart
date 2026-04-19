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
    final captureState = ref.watch(captureProvider);
    final foldersAsync = ref.watch(folderListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingDocId != null ? l10n.addPages : l10n.capturePreview),
      ),
      body: captureState.when(
        data: (_) => Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _currentImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(File(_currentImages[index])),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 20),
                            onPressed: () {
                              setState(() {
                                _currentImages.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            // Sélecteur de Dossier
            if (widget.existingDocId == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  children: [
                    foldersAsync.when(
                      data: (folders) => Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedFolderId,
                              decoration: InputDecoration(
                                labelText: l10n.selectFolder,
                                filled: true,
                                fillColor: const Color(0xFF1E293B),
                              ),
                              items: [
                                DropdownMenuItem(value: null, child: Text(l10n.rootFolder)),
                                ...folders.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))),
                              ],
                              onChanged: (val) => setState(() => _selectedFolderId = val),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.create_new_folder, color: Colors.lightBlueAccent),
                            onPressed: () => _showNewFolderDialog(context),
                            tooltip: l10n.newFolder,
                          ),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const SizedBox(),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(24.0),
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
                        
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.auto_fix_high),
                label: Text(widget.existingDocId != null ? l10n.addPages : l10n.addDocument),
              ),
            ),
          ],
        ),
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(l10n.ocrInProgress,
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        error: (err, st) => Center(child: Text("Erreur: $err")),
      ),
    );
  }

  void _showNewFolderDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.newFolder),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l10n.folderName),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final folderId = await ref.read(folderListProvider.notifier).createFolder(controller.text);
                setState(() => _selectedFolderId = folderId);
              }
              if (context.mounted) Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.indigoAccent),
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }
}
