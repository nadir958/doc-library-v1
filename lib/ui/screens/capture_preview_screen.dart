import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/capture_provider.dart';
import '../providers/folder_provider.dart';
import '../../data/models/models.dart';

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
    final captureState = ref.watch(captureProvider);
    final foldersAsync = ref.watch(folderListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingDocId != null ? 'Ajouter des pages' : 'Aperçu des captures'),
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
                child: foldersAsync.when(
                  data: (folders) => DropdownButtonFormField<int>(
                    value: _selectedFolderId,
                    decoration: const InputDecoration(
                      labelText: 'Dossier de destination',
                      filled: true,
                      fillColor: Color(0xFF1E293B),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Aucun dossier (Racine)')),
                      ...folders.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))),
                    ],
                    onChanged: (val) => setState(() => _selectedFolderId = val),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const SizedBox(),
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
                ),
                icon: const Icon(Icons.auto_fix_high),
                label: Text(widget.existingDocId != null ? 'Ajouter au document' : 'Lancer l\'OCR et Sauvegarder'),
              ),
            ),
          ],
        ),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Extraction du texte en cours...",
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        error: (err, st) => Center(child: Text("Erreur: $err")),
      ),
    );
  }
}
