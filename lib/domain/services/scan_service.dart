import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:camera/camera.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

class ScanService {
  // Mode 1: Smart Document Scanner (ML Kit)
  Future<List<String>?> startSmartScan() async {
    try {
      final options = DocumentScannerOptions(
        documentFormat: DocumentFormat.jpeg,
        mode: ScannerMode.full,
        isGalleryImport: true,
        pageLimit: 20,
      );
      final scanner = DocumentScanner(options: options);
      final result = await scanner.scanDocument();
      
      // On pourrait appliquer des filtres OpenCV ici sur chaque image
      // for (var path in result.images) {
      //   await applyBasicCleanup(path);
      // }
      
      return result.images;
    } catch (e) {
      print("Erreur Smart Scan: $e");
      return null;
    }
  }

  // Exemple de nettoyage avec OpenCV
  Future<void> applyBasicCleanup(String imagePath) async {
    try {
      // Lecture de l'image
      final mat = cv.imread(imagePath);
      
      // Conversion en niveaux de gris
      final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);
      
      // Amélioration du contraste (CLAHE ou simple seuillage)
      final processed = cv.adaptiveThreshold(
        gray, 
        255, 
        cv.ADAPTIVE_THRESH_GAUSSIAN_C, 
        cv.THRESH_BINARY, 
        11, 
        2
      );
      
      // Sauvegarde de l'image traitée (écrase l'originale ou nouvelle)
      cv.imwrite(imagePath, processed);
    } catch (e) {
      print("Erreur OpenCV Cleanup: $e");
    }
  }

  // Mode 2: Manual Photo (Camera)
  Future<XFile?> takeManualPhoto(CameraController controller) async {
    if (!controller.value.isInitialized) return null;
    try {
      final XFile file = await controller.takePicture();
      return file;
    } catch (e) {
      print("Erreur Photo Manuelle: $e");
      return null;
    }
  }
}
