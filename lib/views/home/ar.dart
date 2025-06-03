// import 'dart:io';
// import 'package:ar_flutter_plugin_flutterflow/ar_flutter_plugin.dart';
// import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:remove_background/remove_background.dart';
// import 'package:vector_math/vector_math_64.dart';

// class ARObjectsScreen extends StatefulWidget {
//   const ARObjectsScreen({Key? key, required this.imagePath}) : super(key: key);

//   final String imagePath; // Firebase Storage path

//   @override
//   State<ARObjectsScreen> createState() => _ARObjectsScreenState();
// }

// class _ARObjectsScreenState extends State<ARObjectsScreen> {
//   late ARSessionManager arSessionManager;
//   late ARObjectManager arObjectManager;
//   ARNode? imagePlaneNode;
//   bool isAdded = false;
//   File? _processedImage;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("AR Image Display")),
//       body: ARView(onARViewCreated: onARViewCreated),
//       floatingActionButton: FloatingActionButton(
//         onPressed: fetchAndProcessImage,
//         child: Icon(Icons.image),
//       ),
//     );
//   }

//   void onARViewCreated(
//       ARSessionManager arSessionManager,
//       ARObjectManager arObjectManager,
//       ARAnchorManager arAnchorManager,
//       ARLocationManager arLocationManager) {
//     this.arSessionManager = arSessionManager;
//     this.arObjectManager = arObjectManager;

//     this.arSessionManager.onInitialize(
//           showFeaturePoints: false,
//           showPlanes: true,
//           customPlaneTexturePath: "assets/triangle.png",
//           showWorldOrigin: true,
//           handleTaps: false,
//         );
//     this.arObjectManager.onInitialize();
//   }

//   Future<void> fetchAndProcessImage() async {
//     try {
//       // 1. Get the Firebase image URL
//       String imageUrl = await FirebaseStorage.instance.ref(widget.imagePath).getDownloadURL();

//       // 2. Download the image locally
//       File localImage = await downloadImage(imageUrl);

//       // 3. Remove the background
//       String? outputPath = await RemoveBackground().removeBg(localImage.path);

//       if (outputPath != null) {
//         setState(() {
//           _processedImage = File(outputPath);
//         });

//         addImagePlaneToAR(_processedImage!.path);
//       }
//     } catch (e) {
//       print("Error: $e");
//     }
//   }

//   Future<File> downloadImage(String url) async {
//     final response = await http.get(Uri.parse(url));
//     final directory = await getApplicationDocumentsDirectory();
//     final file = File('${directory.path}/downloaded_image.png');
//     await file.writeAsBytes(response.bodyBytes);
//     return file;
//   }

//   Future<void> addImagePlaneToAR(String imagePath) async {
//     if (imagePlaneNode != null) {
//       arObjectManager.removeNode(imagePlaneNode!);
//       imagePlaneNode = null;
//       isAdded = false;
//     } else {
//       var newNode = ARNode(
//         type: NodeType.webGLB, // Use appropriate type for image plane
//         uri: imagePath, // Image as a texture
//         scale: Vector3(0.5, 0.5, 0.5),
//         position: Vector3(0.0, 0.0, -1.0), // Slightly in front
//       );
//       bool? didAdd = await arObjectManager.addNode(newNode);
//       if (didAdd == true) {
//         setState(() {
//           imagePlaneNode = newNode;
//           isAdded = true;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     arSessionManager.dispose();
//     super.dispose();
//   }
// }

// import 'package:ar_flutter_plugin_flutterflow/ar_flutter_plugin.dart';
// import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
// import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
// import 'package:flutter/material.dart';

// import 'package:vector_math/vector_math_64.dart';

// class ARObjectsScreen extends StatefulWidget {
//   const ARObjectsScreen({Key? key, required this.object, required this.isLocal})
//       : super(key: key);
//   final String object;
//   final bool isLocal;

//   @override
//   State<ARObjectsScreen> createState() => _ARObjectsScreenState();
// }

// class _ARObjectsScreenState extends State<ARObjectsScreen> {
//   late ARSessionManager arSessionManager;
//   late ARObjectManager arObjectManager;
//   ARNode? localObjectNode;
//   ARNode? webObjectNode;
//   bool isAdd = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: ARView(onARViewCreated: onARViewCreated),
//       floatingActionButton: FloatingActionButton(
//         onPressed: widget.isLocal
//             ? onLocalObjectButtonPressed
//             : onWebObjectAtButtonPressed,
//         child: Icon(isAdd ? Icons.remove : Icons.add),
//       ),
//     );
//   }

//   void onARViewCreated(
//       ARSessionManager arSessionManager,
//       ARObjectManager arObjectManager,
//       ARAnchorManager arAnchorManager,
//       ARLocationManager arLocationManager) {
//     this.arSessionManager = arSessionManager;
//     this.arObjectManager = arObjectManager;

//     this.arSessionManager.onInitialize(
//           showFeaturePoints: false,
//           showPlanes: true,
//           customPlaneTexturePath: "assets/triangle.png",
//           showWorldOrigin: true,
//           handleTaps: false,
//         );
//     this.arObjectManager.onInitialize();
//   }

//   Future onLocalObjectButtonPressed() async {
//     if (localObjectNode != null) {
//       arObjectManager.removeNode(localObjectNode!);
//       localObjectNode = null;
//     } else {
//       var newNode = ARNode(
//           type: NodeType.localGLTF2,
//           uri: widget.object,
//           scale: Vector3(0.2, 0.2, 0.2),
//           position: Vector3(0.0, 0.0, 0.0),
//           rotation: Vector4(1.0, 0.0, 0.0, 0.0));
//       bool? didAddLocalNode = await arObjectManager.addNode(newNode);
//       localObjectNode = (didAddLocalNode!) ? newNode : null;
//     }
//   }

//   Future onWebObjectAtButtonPressed() async {
//     setState(() {
//       isAdd = !isAdd;
//     });

//     if (webObjectNode != null) {
//       arObjectManager.removeNode(webObjectNode!);
//       webObjectNode = null;
//     } else {
//       var newNode = ARNode(
//           type: NodeType.webGLB,
//           uri: widget.object,
//           scale: Vector3(0.2, 0.2, 0.2));
//       bool? didAddWebNode = await arObjectManager.addNode(newNode);
//       webObjectNode = (didAddWebNode!) ? newNode : null;
//     }
//   }

//   @override
//   void dispose() {
//     arSessionManager.dispose();
//     super.dispose();
//   }
// }
