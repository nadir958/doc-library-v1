import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../data/models/models.dart';

class ExportService {
  Future<File> generatePdf(DocumentModel document, List<PageModel> pages) async {
    final pdf = pw.Document();

    for (var page in pages) {
      final image = pw.MemoryImage(
        File(page.imagePath).readAsBytesSync(),
      );

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image),
            );
          },
        ),
      );
    }

    final outputDir = await getTemporaryDirectory();
    final file = File("${outputDir.path}/${document.title.replaceAll(' ', '_')}.pdf");
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }
}
