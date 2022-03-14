import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:get/get.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class FacenetService extends GetxService {
  late Interpreter _interpreter;

  Interpreter get interpreter => _interpreter;

  Future<FacenetService> init() async {
    Delegate delegate = tfl.GpuDelegateV2(
        options: GpuDelegateOptionsV2(
      isPrecisionLossAllowed: false,
      inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
      inferencePriority1: TfLiteGpuInferencePriority.minLatency,
      inferencePriority2: TfLiteGpuInferencePriority.auto,
      inferencePriority3: TfLiteGpuInferencePriority.auto,
    ));
    try {
      if (GetPlatform.isIOS) {
        delegate = tfl.GpuDelegate(
          options: GpuDelegateOptions(
            allowPrecisionLoss: true,
            waitType: TFLGpuDelegateWaitType.active,
          ),
        );
      }

      var interpreterOptions = tfl.InterpreterOptions()..addDelegate(delegate);
      _interpreter = await tfl.Interpreter.fromAsset(
          'models/mobilefacenet.tflite',
          options: interpreterOptions);
    } on Exception {
      if (kDebugMode) {
        print('Failed to load model.');
      }
    }

    return this;
  }
}
