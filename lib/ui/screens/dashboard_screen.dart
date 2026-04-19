import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/document_provider.dart';
import '../providers/scan_provider.dart';
import '../../data/models/models.dart';
import 'document_detail_screen.dart';
import 'manual_capture_screen.dart';
import 'capture_preview_screen.dart';
import 'settings_screen.dart';
import '../theme/app_theme.dart';
import 'package:doc_library/generated/l10n/app_localizations.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final FolderModel? folder;
  const DashboardScreen({super.key, this.folder});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _selectedTag;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.folder != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(documentListProvider.notifier).filterByFolder(widget.folder!.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(documentListProvider);
    final allTags = ref.watch(allTagsProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.folder != null ? '${l10n.folders}: ${widget.folder!.name}' : l10n.appTitle,
          style: theme.textTheme.titleLarge,
        ),
        actions: [
          if (widget.folder == null)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Editorial Header
                  if (widget.folder == null) ...[
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.headlineLarge?.copyWith(height: 1.1),
                        children: [
                          const TextSpan(text: "Gérez votre "),
                          TextSpan(
                            text: "empreinte digitale",
                            style: TextStyle(
                              foreground: Paint()
                                ..shader = LinearGradient(
                                  colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                                ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                            ),
                          ),
                          const TextSpan(text: " en toute sécurité."),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: theme.brightness == Brightness.dark ? Colors.black.withOpacity(0.2) : theme.colorScheme.primary.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: l10n.searchHint,
                        prefixIcon: const Icon(Icons.search, color: Colors.indigoAccent),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  if (widget.folder != null) {
                                    ref.read(documentListProvider.notifier).filterByFolder(widget.folder!.id);
                                  } else {
                                    ref.read(documentListProvider.notifier).search("");
                                  }
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      onChanged: (val) {
                        if (val.isEmpty && widget.folder != null) {
                          ref.read(documentListProvider.notifier).filterByFolder(widget.folder!.id);
                        } else {
                          ref.read(documentListProvider.notifier).search(val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tag Filters
                  if (allTags.isNotEmpty && widget.folder == null)
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: allTags.length + 1,
                        itemBuilder: (context, index) {
                          final isSelected = index == 0 ? _selectedTag == null : _selectedTag == allTags[index - 1];
                          final label = index == 0 ? l10n.all : allTags[index - 1];

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(label),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (index == 0) {
                                  setState(() => _selectedTag = null);
                                  ref.read(documentListProvider.notifier).loadDocuments();
                                } else {
                                  final tag = allTags[index - 1];
                                  setState(() => _selectedTag = selected ? tag : null);
                                  ref.read(documentListProvider.notifier).filterByTag(_selectedTag);
                                }
                              },
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              selectedColor: theme.colorScheme.secondary,
                              labelStyle: TextStyle(
                                color: isSelected ? theme.colorScheme.onSecondary : theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              side: BorderSide.none,
                              showCheckmark: false,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          docsAsync.when(
            data: (docs) {
              if (docs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_off_outlined, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.05)),
                        const SizedBox(height: 16),
                        Text(l10n.noDocuments, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.2))),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doc = docs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
                        ),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DocumentDetailScreen(document: doc)),
                          ),
                          onLongPress: () => _showDeleteDialog(context, doc, l10n),
                          borderRadius: BorderRadius.circular(20),
                          child: Row(
                            children: [
                              // Thumbnail Placeholder
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant,
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      theme.colorScheme.surfaceVariant,
                                      theme.colorScheme.surfaceVariant.withOpacity(0.5),
                                    ],
                                  ),
                                ),
                                child: const Icon(Icons.description_outlined, color: Colors.indigoAccent),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              doc.title,
                                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.1)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 4,
                                        children: [
                                          ...doc.tags.take(2).map((t) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.surfaceVariant,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                                          )),
                                          if (doc.tags.length > 2)
                                            Text("+${doc.tags.length - 2}", style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.24))),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 12, color: Colors.indigoAccent),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${doc.createdAt.day}/${doc.createdAt.month}/${doc.createdAt.year}',
                                            style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: docs.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Erreur: $err'))),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer.withOpacity(1.0)],
          ),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showCaptureOptions(context),
          label: Text(l10n.addDocument, style: const TextStyle(fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.add_a_photo),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: theme.brightness == Brightness.dark ? AppTheme.backgroundColor : Colors.white,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, DocumentModel doc, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDocument),
        content: Text(l10n.deleteDocumentConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(documentListProvider.notifier).deleteDocument(doc.id!);
    }
  }

  void _showCaptureOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ManualCaptureScreen(cameras: cameras)),
                    );
                  }
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
                  if (images.isNotEmpty && mounted) {
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
