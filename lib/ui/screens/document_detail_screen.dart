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
import '../providers/scan_provider.dart';
import 'manual_capture_screen.dart';
import 'capture_preview_screen.dart';
import 'package:doc_library/generated/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
        SnackBar(content: Text(l10n.save)),
      );
    }
  }

  Future<void> _updatePageNotes(int pageId, String notes) async {
    final repo = ref.read(documentRepositoryProvider);
    await repo.updatePageNotes(pageId, notes);
    // On n'a pas forcément besoin de rafraîchir tout le provider si on gère l'état localement
    // mais pour être sûr on invalide
    ref.invalidate(documentPagesProvider(widget.document.id!));
  }

  Future<void> _deletePage(int pageId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteDocumentConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete, style: const TextStyle(color: Colors.red))),
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
    final l10n = AppLocalizations.of(context)!;
    // Écouter le provider des pages pour rafraîchir la vue
    final pagesAsync = ref.watch(documentPagesProvider(widget.document.id!));

    return Scaffold(
      appBar: AppBar(
        title: _isEditing
            ? TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: l10n.appTitle,
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
                  title: Text(l10n.deleteDocument),
                  content: Text(l10n.deleteDocumentConfirm),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete, style: const TextStyle(color: Colors.red))),
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
                    text: '${l10n.share}: ${widget.document.title}');
              }
            },
          ),
        ],
      ),
      body: pagesAsync.when(
        data: (pages) => ListView(
          children: [
            if (pages.isEmpty)
              SizedBox(
                height: 200,
                child: Center(child: Text(l10n.noPages)),
              )
            else
              ...pages.map((page) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 400,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: Image.file(
                              File(page.imagePath),
                              fit: BoxFit.contain,
                            ),
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
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notes, size: 16, color: Colors.white70),
                            const SizedBox(width: 8),
                            Text(l10n.notes, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (_isEditing)
                          _NoteEditor(
                            initialNote: page.notes ?? '',
                            onSave: (val) => _updatePageNotes(page.id!, val),
                            hint: l10n.addNote,
                          )
                        else if (page.notes != null && page.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 24.0),
                            child: Text(page.notes!, style: const TextStyle(color: Colors.white)),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(left: 24.0),
                            child: Text(l10n.addNote, style: const TextStyle(color: Colors.white24, fontStyle: FontStyle.italic)),
                          ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white10),
                      ],
                    ),
                  ),
                ],
              )),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags Section
                  Text(
                    l10n.tags,
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
                  const SizedBox(height: 100), // Espace pour le FAB
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
      floatingActionButton: _isEditing ? null : FloatingActionButton(
        onPressed: () => _showAddPageOptions(context),
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  void _showAddTagDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addTag),
        content: TextField(
          controller: _tagController,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.tags),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
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
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  void _showAddPageOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                leading: const Icon(Icons.auto_awesome, color: Colors.amberAccent),
                title: Text(l10n.smartScan),
                subtitle: Text(l10n.smartScanDesc),
                onTap: () async {
                  Navigator.pop(ctx);
                  final images = await ref.read(scanServiceProvider).startSmartScan();
                  if (images != null && images.isNotEmpty && mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CapturePreviewScreen(
                          imagePaths: images,
                          existingDocId: widget.document.id,
                        ),
                      ),
                    ).then((_) {
                       ref.invalidate(documentPagesProvider(widget.document.id!));
                    });
                  }
                },
              ),
              const Divider(color: Colors.white10),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.lightBlueAccent),
                title: Text(l10n.takePhoto),
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
                       ref.invalidate(documentPagesProvider(widget.document.id!));
                    });
                  }
                },
              ),
              const Divider(color: Colors.white10),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.orangeAccent),
                title: Text(l10n.fromGallery),
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

class _NoteEditor extends StatefulWidget {
  final String initialNote;
  final Function(String) onSave;
  final String hint;

  const _NoteEditor({required this.initialNote, required this.onSave, required this.hint});

  @override
  State<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<_NoteEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: widget.hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      maxLines: null,
      controller: _controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      onChanged: widget.onSave,
    );
  }
}
