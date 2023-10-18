import 'dart:io';
import 'package:how_are_you/util/UtilFunction.dart';
import 'package:mime/mime.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:how_are_you/screen/AppImpression.dart';
import 'package:how_are_you/screen/EditTextPage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../main.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {

  // ---------- Gallery ----------
  final ImagePicker _picker = ImagePicker();

  // ---------- Camera Initial values ----------
  CameraController? controller;
  bool _isCameraInitialized = false;
  List<File> allFileList = [];
  final resolutionPresets = ResolutionPreset.values;
  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // !: No compile error
      // A capture is already pending, do nothing
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print('Error occurred while taking picture: $e');
      return null;
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    while (true) {
      try {
        await cameraController.initialize();
        break;
      } on CameraException catch (e) {
        print('Error initializing camera: $e');
      }
    }

    // Update the Boolean
    if (mounted) {
      await Future.delayed(const Duration(seconds: 2), () {});
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void initState() {
    // Hide the status bar
    SystemChrome.setEnabledSystemUIOverlays([]);
    // Set and initialize the new camera
    onNewCameraSelected(cameras[0]);
    // refreshAlreadyCapturedImages();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isCameraInitialized
            ? AspectRatio(
                aspectRatio: 1 / controller!.value.aspectRatio,
                child: Stack(
                  children: [
                    controller!.buildPreview(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16.0,
                        8.0,
                        16.0,
                        8.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Opacity(
                                opacity: 0.0,
                                child: InkWell(
                                  onTap: () {},
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        color: Colors.black38,
                                        size: 60,
                                      ),
                                      Icon(
                                        Icons.camera_rear,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  try {
                                    XFile? rawImage = await takePicture();
                                    File imageFile = File(rawImage!.path);
                                    int currentUnix =
                                        DateTime.now().millisecondsSinceEpoch;
                                    final directory =
                                        await getApplicationDocumentsDirectory();
                                    String fileFormat =
                                        imageFile.path.split('.').last;
                                    print(fileFormat);
                                    await imageFile.copy(
                                      '${directory.path}/$currentUnix.$fileFormat',
                                    );
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => EditTextPage(
                                          file: imageFile,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    print(e.toString());
                                  }
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: Colors.white38,
                                      size: 80,
                                    ),
                                    Icon(
                                      Icons.circle,
                                      color: Colors.white,
                                      size: 65,
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  try {
                                    XFile? rawImage;
                                    bool isJpg = false;
                                    bool isSized = false;
                                    do {
                                      rawImage = await _picker.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      isJpg = (lookupMimeType(rawImage!.path) == 'image/jpeg');
                                      int bytes = File(rawImage.path).readAsBytesSync().lengthInBytes;
                                      isSized = bytes < 716800; // todo : limit 700 KB
                                      if (isJpg && isSized) {
                                        break;
                                      } else {
                                        await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return fileExceptionDialog();
                                            });
                                      }
                                    } while (!(isJpg&&isSized));
                                    File imageFile = File(rawImage.path);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => EditTextPage(
                                          file: imageFile,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    print(e.toString());
                                  }
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : AppImpression(),
      ),
    );
  }
}
