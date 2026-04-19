import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/models.dart';
import '../../domain/services/export_service.dart';
import '../../domain/services/scan_service.dart';
import '../providers/document_provider.dart';
import '../providers/capture_provider.dart';
import 'manual_capture_screen.dart';
import 'capture_preview_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final documentPagesProvider = FutureProvider.family<List<PageModel>, int>((ref, docId) async {
  final repo = ref.watch(documentRepositoryProvider);
  return repo.getPagesForDocument(docId);
});

class DocumentDetailScreen extends ConsumerStatefulWidget {
  final DocumentModel document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  ConsumerState<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _tagController;
  bool _isEditing = false;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.document.title);
    _tagController = TextEditingController();
    _tags = List.from(widget.document.tags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    await ref.read(documentListProvider.notifier).updateMetadata(
          widget.document.id!,
          title: _titleController.text,
          tags: _tags,
        );
    setState(() {
      _isEditing = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.save)),
      );
    }
  }

  Future<void> _deletePage(int pageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.delete),
        content: Text(AppLocalizations.of(context)!.deleteDocumentConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(documentRepositoryProvider);
      await repo.deletePage(pageId);
      ref.invalidate(documentPagesProvider(widget.document.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Écouter le provider des pages pour rafraîchir la vue
    final pagesAsync = ref.watch(documentPagesProvider(widget.document.id!));

    return Scaffold(
      appBar: AppBar(
        title: _isEditing
            ? TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.appTitle,
                  border: InputBorder.none,
                ),
              )
            : Text(widget.document.title),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveChanges,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Supprimer le document ?'),
                  content: const Text('Toutes les pages seront supprimées.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirmed == true && mounted) {
                await ref.read(documentListProvider.notifier).deleteDocument(widget.document.id!);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final exportService = ExportService();
              final pages = pagesAsync.asData?.value ?? [];
              if (pages.isNotEmpty) {
                final file = await exportService.generatePdf(widget.document, pages);
                await Share.shareXFiles([XFile(file.path)],
                    text: '${AppLocalizations.of(context)!.share}: ${widget.document.title}');
              }
            },
          ),
        ],
      ),
      body: pagesAsync.when(
        data: (pages) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pages.isEmpty)
                SizedBox(
                  height: 200,
                  child: Center(child: Text(AppLocalizations.of(context)!.noPages)),
                )
              else
                SizedBox(
                  height: 400,
                  child: PageView.builder(
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      final page = pages[index];
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(File(page.imagePath)),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              top: 20,
                              right: 30,
                              child: CircleAvatar(
                                backgroundColor: Colors.red,
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.white),
                                  onPressed: () => _deletePage(page.id!),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags Section
                    Text(
                      AppLocalizations.of(context)!.tags,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ..._tags.map((tag) => Chip(
                              label: Text(tag),
                              onDeleted: _isEditing
                                  ? () {
                                      setState(() {
                                        _tags.remove(tag);
                                      });
                                    }
                                  : null,
                            )),
                        if (_isEditing)
                          ActionChip(
                            label: const Icon(Icons.add, size: 18),
                            onPressed: () {
                              _showAddTagDialog();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Le texte OCR est conservé dans le modèle pour la recherche mais n'est pas affiché à l'utilisateur.
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
      floatingActionButton: _isEditing ? null : FloatingActionButton(
        onPressed: () => _showAddPageOptions(context),
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  void _showAddTagDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addTag),
        content: TextField(
          controller: _tagController,
          autofocus: true,
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.tags),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              if (_tagController.text.isNotEmpty) {
                setState(() {
                  _tags.add(_tagController.text);
                  _tagController.clear();
                });
              }
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );
  }

  void _showAddPageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.lightBlueAccent),
                title: Text(AppLocalizations.of(context)!.takePhoto),
                onTap: () async {
                  Navigator.pop(ctx);
                  final cameras = await availableCameras();
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManualCaptureScreen(
                          cameras: cameras,
                          existingDocId: widget.document.id,
                        ),
                      ),
                    ).then((_) {
                       // Rafraîchir les pages au retour
                       ref.invalidate(documentPagesProvider(widget.document.id!));
                    });
                  }
                },
              ),
              const Divider(color: Colors.white10),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.orangeAccent),
                title: Text(AppLocalizations.of(context)!.fromGallery),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final images = await picker.pickMultiImage();
                  if (images.isNotEmpty && mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CapturePreviewScreen(
                          imagePaths: images.map((e) => e.path).toList(),
                          existingDocId: widget.document.id,
                        ),
                      ),
                    ).then((_) {
                       // Rafraîchir les pages au retour
                       ref.invalidate(documentPagesProvider(widget.document.id!));
                    });
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
