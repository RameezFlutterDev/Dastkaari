import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CameraOverlay extends StatefulWidget {
  final CameraController cameraController;
  final String productImageUrl;

  const CameraOverlay({
    required this.cameraController,
    required this.productImageUrl,
    Key? key,
  }) : super(key: key);

  @override
  __CameraOverlayState createState() => __CameraOverlayState();
}

class __CameraOverlayState extends State<CameraOverlay> {
  Offset _position = const Offset(60, 100); // Initial position
  double _scale = 1.0; // Initial scale
  double _rotation = 0.0; // Initial rotation in radians

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height - 200;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: RotatedBox(
              quarterTurns: 1, // Rotate 90 degrees
              child: CameraPreview(widget.cameraController),
            ),
          ),

          // Product image overlay
          Positioned(
            left: _position.dx,
            top: _position.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _position = Offset(
                    (_position.dx + details.delta.dx)
                        .clamp(0, screenWidth - 120),
                    (_position.dy + details.delta.dy)
                        .clamp(0, screenHeight - 120),
                  );
                });
              },
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(_rotation)
                  ..scale(_scale),
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Image.network(
                    widget.productImageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        color: Colors.red,
                        alignment: Alignment.center,
                        child: Text(
                          'Load Failed',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        width: 120,
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Controls at the bottom (scale + rotate)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  "Scale",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Color(0xffD9A441),
                    inactiveTrackColor: Color(0xffD9A441).withOpacity(0.3),
                    thumbColor: Color(0xffD9A441),
                    overlayColor: Color(0xffD9A441).withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _scale,
                    min: 0.5,
                    max: 3.0,
                    divisions: 25,
                    onChanged: (value) {
                      setState(() {
                        _scale = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Rotate",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Color(0xffD9A441),
                    thumbColor: Color(0xffD9A441),
                    overlayColor: Color(0xffD9A441).withOpacity(0.2),
                    inactiveTrackColor: Color(0xffD9A441).withOpacity(0.3),
                  ),
                  child: Slider(
                    value: _rotation,
                    min: -3.14, // -180 degrees
                    max: 3.14, // +180 degrees
                    divisions: 100,
                    label: "${(_rotation * (180 / 3.14)).toStringAsFixed(0)}°",
                    onChanged: (value) {
                      setState(() {
                        _rotation = value;
                      });
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
