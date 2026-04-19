import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../domain/services/scan_service.dart';
import 'capture_preview_screen.dart';
import 'package:doc_library/generated/l10n/app_localizations.dart';

class ManualCaptureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final int? existingDocId;

  const ManualCaptureScreen({super.key, required this.cameras, this.existingDocId});

  @override
  State<ManualCaptureScreen> createState() => _ManualCaptureScreenState();
}

class _ManualCaptureScreenState extends State<ManualCaptureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final ScanService _scanService = ScanService();
  final List<String> _capturedImages = [];

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('${AppLocalizations.of(context)!.takePhoto} (${_capturedImages.length})'),
        backgroundColor: Colors.transparent,
        actions: [
          if (_capturedImages.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CapturePreviewScreen(
                      imagePaths: _capturedImages,
                      existingDocId: widget.existingDocId,
                    ),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.save, style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(child: CameraPreview(_controller));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _scanService.takeManualPhoto(_controller);
            if (image != null && mounted) {
              setState(() {
                _capturedImages.add(image.path);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Page ${_capturedImages.length} capturée'),
                  duration: const Duration(milliseconds: 500),
                ),
              );
            }
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
