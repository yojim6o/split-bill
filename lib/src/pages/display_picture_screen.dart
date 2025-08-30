import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_bill/src/bloc/ai/ai_bloc.dart';
import 'package:split_bill/src/bloc/ai/ai_event.dart';
import 'package:split_bill/src/bloc/ai/ai_state.dart';
import 'package:split_bill/src/bloc/camera/camera_bloc.dart';
import 'package:split_bill/src/widgets/draggable_scrollable_sheet_response.dart';
import 'package:split_bill/src/widgets/scanning_line.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final Function callback;

  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
    required this.callback,
  });

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  late final StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    final aiBloc = context.read<AIBloc>();

    subscription = aiBloc.stream.listen((state) async {
      if (state is AIInitializedSuccess) {
        final imageBytes = await _processImage();
        if (!mounted) return;

        aiBloc.add(AIQuestion(imageBytes: imageBytes));
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        widget.callback();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 1,
            shadowColor: FlexColor.greyLawDarkPrimary,
          ),
          body: Stack(
            children: [
              Align(
                alignment:
                    AlignmentGeometry.center.add(AlignmentGeometry.xy(0, -.4)),
                child: FractionallySizedBox(
                  widthFactor: .8,
                  heightFactor: .8,
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: Container(
                      decoration: BoxDecoration(
                        //TODO: delete just for testing
                        //color: const Color.fromARGB(215, 7, 255, 106),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: FittedBox(
                          fit: BoxFit.fill,
                          child: Image.file(File(widget.imagePath))),
                    ),
                  ),
                ),
              ),
              BlocBuilder<AIBloc, AIServiceState>(
                builder: (_, AIServiceState state) {
                  if (state is AIResponseReady) {
                    return DraggableScrollableSheetResponse(
                        items: jsonDecode(
                      state.response.replaceAll('`', '').replaceAll('json', ''),
                    )['items']);
                  } else if (state is AIInitializing ||
                      state is AIResponseWaiting) {
                    return ScanningLine();
                  } else {
                    return Text(
                      "An error occured",
                      style: TextStyle(
                          fontSize: 24,
                          color: const Color.fromARGB(255, 222, 57, 16)),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List> _processImage() async {
    //TODO: delete just for testing
    //final byteData = await rootBundle.load("assets/images/ticket_test.jpg");
    //return byteData.buffer.asUint8List();
    final file = File(widget.imagePath);
    return await file.readAsBytes();
  }
}
