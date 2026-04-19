import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/scan_service.dart';

final scanServiceProvider = Provider<ScanService>((ref) {
  return ScanService();
});
