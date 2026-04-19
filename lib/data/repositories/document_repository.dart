import 'package:isar/isar.dart';
import '../models/models.dart';

class DocumentRepository {
  final Isar isar;

  DocumentRepository(this.isar);

  // Récupérer tous les documents par date décroissante
  Future<List<DocumentModel>> getAllDocuments() async {
    return await isar.documentModels.where().sortByCreatedAtDesc().findAll();
  }

  // Recherche par titre ou contenu OCR
  Future<List<DocumentModel>> searchDocuments(String query) async {
    return await isar.documentModels
        .filter()
        .titleContains(query, caseSensitive: false)
        .or()
        .fullOcrSearchTextContains(query, caseSensitive: false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  // Filtrer par tag
  Future<List<DocumentModel>> filterDocumentsByTag(String tag) async {
    return await isar.documentModels
        .filter()
        .tagsElementEqualTo(tag)
        .sortByCreatedAtDesc()
        .findAll();
  }

  // Filtrer par dossier
  Future<List<DocumentModel>> filterDocumentsByFolder(int folderId) async {
    return await isar.documentModels
        .filter()
        .folder((q) => q.idEqualTo(folderId))
        .sortByCreatedAtDesc()
        .findAll();
  }

  // Créer un nouveau document avec ses pages
  Future<void> saveDocument(DocumentModel doc, List<PageModel> pages) async {
    await isar.writeTxn(() async {
      await isar.documentModels.put(doc);
      for (var page in pages) {
        page.document.value = doc;
        await isar.pageModels.put(page);
        await page.document.save();
      }
    });
  }

  // Récupérer les pages d'un document
  Future<List<PageModel>> getPagesForDocument(int docId) async {
    return await isar.pageModels
        .filter()
        .document((q) => q.idEqualTo(docId))
        .sortByOrder()
        .findAll();
  }

  // Supprimer un document et ses pages
  Future<void> deleteDocument(int id) async {
    await isar.writeTxn(() async {
      final pages = await getPagesForDocument(id);
      for (final page in pages) {
        if (page.id != null) {
          await isar.pageModels.delete(page.id!);
        }
      }
      await isar.documentModels.delete(id);
    });
  }

  // Mettre à jour le titre, les tags ou le texte OCR d'un document
  Future<void> updateDocumentMetadata(int id, {String? title, List<String>? tags, String? fullOcrSearchText, int? folderId}) async {
    await isar.writeTxn(() async {
      final doc = await isar.documentModels.get(id);
      if (doc != null) {
        if (title != null) doc.title = title;
        if (tags != null) doc.tags = tags;
        if (fullOcrSearchText != null) doc.fullOcrSearchText = fullOcrSearchText;
        
        if (folderId != null) {
          final folder = await isar.folderModels.get(folderId);
          if (folder != null) {
            doc.folder.value = folder;
            await doc.folder.save();
          }
        }
        
        await isar.documentModels.put(doc);
      }
    });
  }

  // Supprimer une page spécifique
  Future<void> deletePage(int pageId) async {
    await isar.writeTxn(() async {
      await isar.pageModels.delete(pageId);
    });
  }

  // Ajouter une page à un document existant
  Future<void> addPageToDocument(int docId, PageModel page) async {
    await isar.writeTxn(() async {
      final doc = await isar.documentModels.get(docId);
      if (doc != null) {
        page.document.value = doc;
        await isar.pageModels.put(page);
        await page.document.save();
      }
    });
  }

  // Mettre à jour les notes d'une page
  Future<void> updatePageNotes(int pageId, String notes) async {
    await isar.writeTxn(() async {
      final page = await isar.pageModels.get(pageId);
      if (page != null) {
        page.notes = notes;
        await isar.pageModels.put(page);
      }
    });
  }

  // Tout effacer
  Future<void> deleteAllData() async {
    await isar.writeTxn(() async {
      await isar.documentModels.clear();
      await isar.pageModels.clear();
      await isar.folderModels.clear();
    });
  }
}
