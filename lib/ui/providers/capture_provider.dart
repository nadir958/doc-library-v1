import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../domain/services/ocr_service.dart';
import 'document_provider.dart';

final ocrServiceProvider = Provider<OCRService>((ref) {
  final service = OCRService();
  ref.onDispose(() => service.dispose());
  return service;
});

class CaptureNotifier extends StateNotifier<AsyncValue<void>> {
  final OCRService _ocrService;
  final Ref _ref;

  CaptureNotifier(this._ocrService, this._ref) : super(const AsyncValue.data(null));

  Future<void> processCapture(List<String> imagePaths, {int? folderId}) async {
    state = const AsyncValue.loading();
    try {
      final List<PageModel> pages = [];
      String fullText = "";

      for (int i = 0; i < imagePaths.length; i++) {
        final path = imagePaths[i];
        final text = await _ocrService.recognizeText(path);
        
        final page = PageModel()
          ..imagePath = path
          ..originalPath = path
          ..ocrText = text
          ..order = i;
        
        pages.add(page);
        fullText += "$text\n";
      }

      final doc = DocumentModel()
        ..title = "Scan du ${DateTime.now().day}/${DateTime.now().month}"
        ..createdAt = DateTime.now()
        ..fullOcrSearchText = fullText;

      final repo = _ref.read(documentRepositoryProvider);
      await repo.saveDocument(doc, pages);
      
      if (folderId != null) {
        await repo.updateDocumentMetadata(doc.id!, folderId: folderId);
      }
      
      await _ref.read(documentListProvider.notifier).loadDocuments();
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addPagesToDocument(int docId, List<String> imagePaths) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(documentRepositoryProvider);
      
      final currentPages = await repo.getPagesForDocument(docId);
      int startOrder = currentPages.length;

      String additionalText = "";

      for (int i = 0; i < imagePaths.length; i++) {
        final path = imagePaths[i];
        final text = await _ocrService.recognizeText(path);
        
        final page = PageModel()
          ..imagePath = path
          ..originalPath = path
          ..ocrText = text
          ..order = startOrder + i;
        
        await repo.addPageToDocument(docId, page);
        additionalText += "$text\n";
      }

      final docs = _ref.read(documentListProvider).asData?.value ?? [];
      final doc = docs.firstWhere((d) => d.id == docId);
      
      await repo.updateDocumentMetadata(docId, title: doc.title, tags: doc.tags);
      
      await _ref.read(documentListProvider.notifier).loadDocuments();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final captureProvider = StateNotifierProvider<CaptureNotifier, AsyncValue<void>>((ref) {
  final ocr = ref.watch(ocrServiceProvider);
  return CaptureNotifier(ocr, ref);
});
