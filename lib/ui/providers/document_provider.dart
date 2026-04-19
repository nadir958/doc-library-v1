import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../data/models/models.dart';
import '../../data/repositories/document_repository.dart';

// Provider pour le repository
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return DocumentRepository(isar);
});

// StateNotifier pour la liste des documents
class DocumentListNotifier extends StateNotifier<AsyncValue<List<DocumentModel>>> {
  final DocumentRepository _repository;

  DocumentListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    state = const AsyncValue.loading();
    try {
      final docs = await _repository.getAllDocuments();
      state = AsyncValue.data(docs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      loadDocuments();
      return;
    }
    try {
      final docs = await _repository.searchDocuments(query);
      state = AsyncValue.data(docs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> filterByTag(String? tag) async {
    if (tag == null || tag.isEmpty) {
      loadDocuments();
      return;
    }
    try {
      final docs = await _repository.filterDocumentsByTag(tag);
      state = AsyncValue.data(docs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> filterByFolder(int? folderId) async {
    if (folderId == null) {
      loadDocuments();
      return;
    }
    try {
      final docs = await _repository.filterDocumentsByFolder(folderId);
      state = AsyncValue.data(docs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateMetadata(int id, {String? title, List<String>? tags, int? folderId}) async {
    try {
      await _repository.updateDocumentMetadata(id, title: title, tags: tags, folderId: folderId);
      await loadDocuments(); 
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteDocument(int id) async {
    try {
      await _repository.deleteDocument(id);
      await loadDocuments();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final documentListProvider = StateNotifierProvider<DocumentListNotifier, AsyncValue<List<DocumentModel>>>((ref) {
  final repo = ref.watch(documentRepositoryProvider);
  return DocumentListNotifier(repo);
});

// Provider pour extraire tous les tags uniques
final allTagsProvider = Provider<List<String>>((ref) {
  final docsAsync = ref.watch(documentListProvider);
  return docsAsync.when(
    data: (docs) {
      final tags = docs.expand((doc) => doc.tags).toSet().toList();
      tags.sort();
      return tags;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
