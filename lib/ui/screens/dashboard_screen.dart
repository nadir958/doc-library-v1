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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.folder != null ? '${l10n.folders}: ${widget.folder!.name}' : l10n.appTitle, 
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        actions: [
          if (widget.folder == null)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
            ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
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
                        }
                      ) 
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
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
          
          // Organisation par Tags (Filtres)
          if (allTags.isNotEmpty && widget.folder == null)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: allTags.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: const Text("Tous"),
                        selected: _selectedTag == null,
                        onSelected: (selected) {
                          setState(() => _selectedTag = null);
                          ref.read(documentListProvider.notifier).loadDocuments();
                        },
                      ),
                    );
                  }
                  final tag = allTags[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(tag),
                      selected: _selectedTag == tag,
                      onSelected: (selected) {
                        setState(() => _selectedTag = selected ? tag : null);
                        ref.read(documentListProvider.notifier).filterByTag(_selectedTag);
                      },
                    ),
                  );
                },
              ),
            ),

          Expanded(
            child: docsAsync.when(
              data: (docs) {
                if (docs.isEmpty) {
                  return Center(child: Text(l10n.noDocuments));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.indigoAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.description, color: Colors.indigoAccent),
                        ),
                        title: Text(doc.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${doc.tags.length} tags • ${doc.createdAt.day}/${doc.createdAt.month}/${doc.createdAt.year}'),
                            if (doc.tags.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Wrap(
                                  spacing: 4,
                                  children: doc.tags.take(3).map((t) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(t, style: const TextStyle(fontSize: 10)),
                                  )).toList(),
                                ),
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DocumentDetailScreen(document: doc)),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCaptureOptions(context),
        label: Text(l10n.addDocument),
        icon: const Icon(Icons.add_a_photo),
        backgroundColor: Colors.indigoAccent,
      ),
    );
  }

  void _showCaptureOptions(BuildContext context) {
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
                title: const Text('Smart Scan'),
                subtitle: const Text('Détection automatique et correction'),
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
                      MaterialPageRoute(builder: (context) => ManualCaptureScreen(cameras: cameras)),
                    );
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
