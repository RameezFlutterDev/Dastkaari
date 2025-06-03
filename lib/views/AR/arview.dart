import 'package:camera/camera.dart';
import 'package:dastkaari/adHelper/instertitial_ad_helper.dart';
import 'package:dastkaari/views/AR/cameraoverlay.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ARViewScreen extends StatefulWidget {
  final String productImageUrl;
  const ARViewScreen({Key? key, required this.productImageUrl})
      : super(key: key);

  @override
  _ARViewScreenState createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isAdShown = false;

  @override
  void initState() {
    super.initState();
    InterstitialAdHelper.showAd(() {
      _initializeCamera(); // Only start camera after ad
    });
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;

    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      return;
    }

    _cameraController = CameraController(
      _cameras![0],
      ResolutionPreset.ultraHigh,
    );

    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CameraOverlay(
        cameraController: _cameraController!,
        productImageUrl: widget.productImageUrl,
      ),
    );
  }
}
