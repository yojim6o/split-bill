// A screen that allows users to take a picture using a given camera.
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_bill/src/bloc/ai/ai_bloc.dart';
import 'package:split_bill/src/bloc/ai/ai_event.dart';
import 'package:split_bill/src/bloc/camera/camera_bloc.dart';
import 'package:split_bill/src/pages/display_picture_screen.dart';
import 'package:split_bill/src/services/firebase_ai.dart';
import 'package:split_bill/src/widgets/error.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  final globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ignore: close_sinks
    final bloc = BlocProvider.of<CameraBloc>(context);

    // App state changed before we got the chance to initialize.
    if (!bloc.isInitialized()) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      bloc.add(CameraStopped());
    } else if (state == AppLifecycleState.resumed) {
      bloc.add(CameraInitialized());
    }
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<CameraBloc, CameraState>(
        listener: (_, state) async {
          if (state is CameraCaptureSuccess) {
            BlocProvider.of<CameraBloc>(context).getController().pausePreview();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (context) =>
                      AIBloc(service: FirebaseAi())..add(AIInitialized()),
                  child: DisplayPictureScreen(
                    callback: () =>
                        BlocProvider.of<CameraBloc>(context).add(CameraBack()),
                    imagePath: state.path,
                  ),
                ),
              ),
            );
          } else if (state is CameraCaptureFailure) {}
        },
        builder: (_, CameraState state) => Scaffold(
          key: globalKey,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    //padding: EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: state is CameraReady
                        ? CameraPreview(
                            BlocProvider.of<CameraBloc>(context)
                                .getController(),
                          )
                        : state is CameraFailure
                            ? Error(key: Key("value"), message: state.error)
                            : Container(),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: state is CameraReady
              ? FloatingActionButton(
                  shape: CircleBorder(),
                  child: Icon(Icons.camera_sharp),
                  onPressed: () => BlocProvider.of<CameraBloc>(context)
                      .add(CameraCaptured()),
                )
              : Container(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      );
}
