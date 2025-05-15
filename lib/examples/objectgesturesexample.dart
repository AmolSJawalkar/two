import 'dart:ffi';
import 'package:ar_flutter_plugin_2/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_2/models/ar_anchor.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_2/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_2/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_2/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_2/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin_2/models/ar_node.dart';
import 'package:ar_flutter_plugin_2/models/ar_hittest_result.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math';

class ObjectGesturesWidget extends StatefulWidget {
  const ObjectGesturesWidget({super.key});
  @override
  _ObjectGesturesWidgetState createState() => _ObjectGesturesWidgetState();
}

class _ObjectGesturesWidgetState extends State<ObjectGesturesWidget> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  List<ARNode> nodes = [];
  List<ARAnchor> anchors = [];
  double _lastRotation = 0.0;
  late ARNode _newNode;
  double _currentScale = 1.0;

  @override
  void dispose() {
    super.dispose();
    arSessionManager!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Object Transformation Gestures')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onScaleUpdate: (details) {
                // Only rotate if there is at least one node
                if (nodes.isNotEmpty) {
                  // Horizontal drag delta controls rotation
                  // double rotationDelta =
                  //     details.delta.dx * 0.001; // Adjust sensitivity as needed
                  //_rotateLastNode(0.0);

                  if (nodes.isNotEmpty) {
                    _updateLastNodeScale(details.scale);
                  }
                }
              },

              // onScaleEnd: (details) {
              //   if (nodes.isNotEmpty) {
              //     _currentScale = nodes.last.scale?.x ?? 1.0;
              //   }
              // },
              child: ARView(
                onARViewCreated: onARViewCreated,
                planeDetectionConfig:
                    PlaneDetectionConfig.horizontalAndVertical,
              ),
            ),
            // Align(
            //   alignment: FractionalOffset.bottomCenter,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       ElevatedButton(
            //         onPressed: onRemoveEverything,
            //         child: Text("Remove Everything"),
            //       ),
            //     ],
            //   ),
            // ),
          ),
        ],
      ),
    );
  }

  void _updateLastNodeScale(double scaleFactor) async {
    //on node
    // ARNode node = nodes.last;
    // double newScale = (_currentScale * scaleFactor).clamp(0.05, 3.0);

    //using trasform

    _newNode = nodes.last;
    double scale = 1.3;
    var _currentTrasform = _newNode.transform;

    //case1
    //_currentTrasform.scale(12, 12, 12);
    //case2
    // _currentTrasform.setFromTranslationRotationScale(
    //   Vector3(0, 0, 0),
    //   Quaternion(0, 0, 0, 0),
    //   Vector3(1.2, 1.2, 1.2),
    // );
    //_newNode.transform = _currentTrasform;
    //case3
    final currentScale = nodes.scale ?? Vector3(1.0, 1.0, 1.0);
    final newScale = currentScale * 12.0;

    Matrix3 rotationMatrix = _newNode.rotation;
    Quaternion q = Quaternion.fromRotation(rotationMatrix);
    Vector3 axis = Vector3.zero();
    // double angle = q.getAxisAngle(axis);
    Vector4 axisAngle = Vector4(axis.x, axis.y, axis.z, 0);

    await arObjectManager!.removeNode(_newNode);
    final newNode = ARNode(
      type: NodeType.localGLTF2,
      uri: "Models/BoxModel/BoxInBox.gltf",
      scale: newScale,
      position: _newNode.position,
      rotation: axisAngle,
    );

    await arObjectManager!.addNode(_newNode);
    planeanchor:
    anchors.isNotEmpty ? anchors.last : null;

    nodes[nodes.length - 1] = _newNode;
    setState(() {});
  }

  void onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: "Images/triangle.png",
      showWorldOrigin: true,
      handlePans: true,
      handleRotation: true,
    );
    this.arObjectManager!.onInitialize();

    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
  }

  // double getAxisAngle(Vector3 axis) {
  //   if (w > 1.0) {
  //     normalize();
  //   }
  //   double angle = 2.0 * acos(w);
  //   double s = sqrt(1.0 - w * w);

  //   if (s < 0.0001) {
  //     axis.setValues(1.0, 0.0, 0.0);
  //   } else {
  //     axis.setValues(x / s, y / s, z / s);
  //   }
  //   return angle;
  // }

  Future<void> onRemoveEverything() async {
    /*nodes.forEach((node) {
      this.arObjectManager.removeNode(node);
    });*/
    anchors.forEach((anchor) {
      this.arAnchorManager!.removeAnchor(anchor);
    });
    anchors = [];
  }

  Future<void> onPlaneOrPointTapped(
    List<ARHitTestResult> hitTestResults,
  ) async {
    var singleHitTestResult = hitTestResults.firstWhere(
      (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane,
    );
    var newAnchor = ARPlaneAnchor(
      transformation: singleHitTestResult.worldTransform,
    );
    bool? didAddAnchor = await arAnchorManager!.addAnchor(newAnchor);
    if (didAddAnchor!) {
      anchors.add(newAnchor);

      _newNode = ARNode(
        type: NodeType.localGLTF2,
        uri: "Models/BoxModel/BoxInBox.gltf",
        scale: Vector3(0.2, 0.2, 0.2),
        position: Vector3(0.0, 0.0, 0.0),
        rotation: Vector4(1.0, 0.0, 0.0, 0.0),
      );

      print("Trying to add node");
      bool? didAddNodeToAnchor = await arObjectManager!.addNode(
        _newNode,
        planeAnchor: newAnchor,
      );
      if (didAddNodeToAnchor!) {
        nodes.add(_newNode);
      } else {
        arSessionManager!.onError!("Adding Node to Anchor failed");
      }
    } else {
      arSessionManager!.onError!("Adding Anchor failed");
    }
  }
}

extension on List<ARNode> {
  get scale => null;
}
