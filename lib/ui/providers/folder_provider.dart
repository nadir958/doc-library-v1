import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/folder_repository.dart';
import '../../data/models/models.dart';
import '../../main.dart';

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return FolderRepository(isar);
});

final folderListProvider = StateNotifierProvider<FolderListNotifier, AsyncValue<List<FolderModel>>>((ref) {
  final repo = ref.watch(folderRepositoryProvider);
  return FolderListNotifier(repo);
});

class FolderListNotifier extends StateNotifier<AsyncValue<List<FolderModel>>> {
  final FolderRepository _repo;

  FolderListNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadFolders();
  }

  Future<void> loadFolders() async {
    state = const AsyncValue.loading();
    try {
      final folders = await _repo.getAllFolders();
      state = AsyncValue.data(folders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<int> createFolder(String name) async {
    try {
      final id = await _repo.createFolder(name);
      await loadFolders();
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFolder(int id) async {
    try {
      await _repo.deleteFolder(id);
      await loadFolders();
    } catch (e) {
      // Gérer l'erreur
    }
  }
}
