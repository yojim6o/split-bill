import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_bill/src/bloc/camera/camera_bloc.dart';
import 'package:split_bill/src/pages/camera_screen.dart';
import 'package:split_bill/src/themes/app_theme.dart';
import 'package:split_bill/src/utils/camera_utils.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        child: BlocProvider(
          create: (_) =>
              CameraBloc(cameraUtils: CameraUtils())..add(CameraInitialized()),
          child: CameraScreen(),
        ),
      ),
      theme: AppTheme.light,
    );
  }
}
