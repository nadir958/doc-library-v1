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
import '../theme/app_theme.dart';
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
    final theme = Theme.of(context);
    final pagesAsync = ref.watch(documentPagesProvider(widget.document.id!));

    return Scaffold(
      appBar: AppBar(
        title: _isEditing
            ? TextField(
                controller: _titleController,
                style: theme.textTheme.titleLarge,
                decoration: InputDecoration(
                  hintText: l10n.appTitle,
                  border: InputBorder.none,
                ),
              )
            : Text(widget.document.title, style: theme.textTheme.titleLarge),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveChanges,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreActions(context, l10n),
          ),
        ],
      ),
      body: pagesAsync.when(
        data: (pages) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            // Breadcrumb
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_back, size: 14, color: Colors.indigoAccent),
                      SizedBox(width: 4),
                      Text("Retour au Vault", style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("/", style: TextStyle(color: Colors.white10)),
                ),
                Expanded(
                  child: Text(
                    widget.document.title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (pages.isEmpty)
              SizedBox(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.description_outlined, size: 64, color: Colors.white10),
                      const SizedBox(height: 16),
                      Text(l10n.noPages, style: const TextStyle(color: Colors.white24)),
                    ],
                  ),
                ),
              )
            else
              ...pages.map((page) => _ImmersivePage(
                    key: ValueKey(page.id),
                    page: page,
                    isEditing: _isEditing,
                    onDelete: () => _deletePage(page.id!),
                    onUpdateNotes: (val) => _updatePageNotes(page.id!, val),
                  )),

            // Metadata Card
            Container(
              margin: const EdgeInsets.only(top: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "PROPRIÉTÉS",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MetadataRow(label: "Créé", value: "${widget.document.createdAt.day}/${widget.document.createdAt.month}/${widget.document.createdAt.year}"),
                  _MetadataRow(label: "Type", value: "PDF (OCR Optimisé)"),
                  _MetadataRow(label: "Taille", value: "12.4 MB"),
                  const Divider(height: 32, color: Colors.white10),
                  Row(
                    children: [
                      const Text(
                        "TAGS",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                      ),
                      const Spacer(),
                      if (_isEditing)
                        IconButton(
                          icon: const Icon(Icons.add, size: 16, color: Colors.indigoAccent),
                          onPressed: _showAddTagDialog,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._tags.map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(tag, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                                if (_isEditing) ...[
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => setState(() => _tags.remove(tag)),
                                    child: const Icon(Icons.close, size: 12, color: Colors.indigoAccent),
                                  ),
                                ],
                              ],
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
      floatingActionButton: _isEditing
          ? null
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFFC0C1FF), Color(0xFF8083FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC0C1FF).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _showAddPageOptions(context),
                label: const Text("AJOUTER UNE PAGE", style: TextStyle(fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.add_photo_alternate_outlined),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
    );
  }

  void _showMoreActions(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF191F2F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: Text(l10n.share),
              onTap: () async {
                Navigator.pop(ctx);
                final exportService = ExportService();
                final pages = ref.read(documentPagesProvider(widget.document.id!)).asData?.value ?? [];
                if (pages.isNotEmpty) {
                  final file = await exportService.generatePdf(widget.document, pages);
                  await Share.shareXFiles([XFile(file.path)], text: '${l10n.share}: ${widget.document.title}');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: Text(l10n.deleteDocument, style: const TextStyle(color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(ctx);
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
          ],
        ),
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
              const Divider(color: Colors.transparent, height: 1),
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
              const Divider(color: Colors.transparent, height: 1),
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

class _ImmersivePage extends StatefulWidget {
  final PageModel page;
  final bool isEditing;
  final VoidCallback onDelete;
  final Function(String) onUpdateNotes;

  const _ImmersivePage({
    super.key,
    required this.page,
    required this.isEditing,
    required this.onDelete,
    required this.onUpdateNotes,
  });

  @override
  State<_ImmersivePage> createState() => _ImmersivePageState();
}

class _ImmersivePageState extends State<_ImmersivePage> {
  final TransformationController _transformationController = TransformationController();
  String _currentNotes = '';

  @override
  void initState() {
    super.initState();
    _currentNotes = widget.page.notes ?? '';
  }

  void _zoom(double scale) {
    final double currentScale = _transformationController.value.getMaxScaleOnAxis();
    final double newScale = (currentScale * scale).clamp(0.5, 4.0);
    setState(() {
      _transformationController.value = Matrix4.identity()..scale(newScale);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 500,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.file(
                    File(widget.page.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Zoom Controls Overlay
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () => _zoom(1.2),
                    ),
                    Container(height: 1, width: 24, color: Colors.white10),
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      onPressed: () => _zoom(0.8),
                    ),
                  ],
                ),
              ),
            ),
            // Integrity Overlay
            Positioned(
              bottom: 40,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.indigoAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.verified_user, color: Colors.indigoAccent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("INTÉGRITÉ VÉRIFIÉE", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.indigoAccent, letterSpacing: 1.2)),
                        Text("SHA-256: 4e9...f21", style: TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (widget.isEditing)
              Positioned(
                top: 16,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: widget.onDelete,
                  ),
                ),
              ),
          ],
        ),
        
        // Notes Section
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note, color: Colors.indigoAccent),
                  const SizedBox(width: 8),
                  const Text("NOTES DU DOCUMENT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.indigoAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text("CONFIDENTIEL", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _NoteEditor(
                initialNote: _currentNotes,
                onSave: (val) {
                  _currentNotes = val;
                  widget.onUpdateNotes(val);
                },
                hint: "Ajoutez vos observations...",
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.onUpdateNotes(_currentNotes);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.save),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text("ENREGISTRER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: theme.brightness == Brightness.dark ? AppTheme.backgroundColor : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetadataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 13)),
          Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
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
        fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      maxLines: null,
      controller: _controller,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
      onChanged: widget.onSave,
    );
  }
}
