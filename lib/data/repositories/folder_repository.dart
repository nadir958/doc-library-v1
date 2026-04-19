import 'package:isar/isar.dart';
import '../models/models.dart';

class FolderRepository {
  final Isar isar;

  FolderRepository(this.isar);

  // Récupérer tous les dossiers
  Future<List<FolderModel>> getAllFolders() async {
    return await isar.folderModels.where().sortByCreatedAtDesc().findAll();
  }

  // Créer un dossier
  Future<void> createFolder(String name) async {
    final folder = FolderModel()
      ..name = name
      ..createdAt = DateTime.now();
    
    await isar.writeTxn(() async {
      await isar.folderModels.put(folder);
    });
  }

  // Récupérer les documents d'un dossier
  Future<List<DocumentModel>> getDocumentsInFolder(int folderId) async {
    return await isar.documentModels
        .filter()
        .folder((q) => q.idEqualTo(folderId))
        .sortByCreatedAtDesc()
        .findAll();
  }

  // Assigner un document à un dossier
  Future<void> assignDocumentToFolder(int docId, int folderId) async {
    await isar.writeTxn(() async {
      final doc = await isar.documentModels.get(docId);
      final folder = await isar.folderModels.get(folderId);
      
      if (doc != null && folder != null) {
        doc.folder.value = folder;
        await isar.documentModels.put(doc);
        await doc.folder.save();
      }
    });
  }

  // Supprimer un dossier (sans supprimer les documents)
  Future<void> deleteFolder(int folderId) async {
    await isar.writeTxn(() async {
      // On pourrait aussi mettre à jour les documents pour enlever le lien, 
      // mais Isar le fait automatiquement ou on peut le laisser ainsi.
      await isar.folderModels.delete(folderId);
    });
  }
}
