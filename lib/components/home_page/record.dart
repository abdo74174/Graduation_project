// import 'package:flutter/material.dart';
// import 'package:wave/wave.dart';
// import 'package:wave/config.dart';

// class VoiceRecordingWave extends StatelessWidget {
//   final bool isRecording;

//   const VoiceRecordingWave({Key? key, required this.isRecording})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (!isRecording) {
//       return const SizedBox(); // لو مش بيسجل مفيش حاجة تظهر
//     }

//     return SizedBox(
//       height: 100,
//       child: WaveWidget(
//         config: CustomConfig(
//           gradients: [
//             [Colors.blue, Colors.lightBlueAccent],
//             [Colors.blueAccent, Colors.blue],
//           ],
//           durations: [35000, 19440],
//           heightPercentages: [0.25, 0.30],
//           blur: const MaskFilter.blur(BlurStyle.solid, 5),
//           gradientBegin: Alignment.bottomLeft,
//           gradientEnd: Alignment.topRight,
//         ),
//         waveAmplitude: 0,
//         size: const Size(double.infinity, double.infinity),
//       ),
//     );
//   }
// }
