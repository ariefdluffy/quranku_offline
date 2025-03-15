// import 'dart:async';
// import 'package:flutter_background_service/flutter_background_service.dart';

// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();

//   await service.configure(
//     iosConfiguration: IosConfiguration(),
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       isForegroundMode: true,
//     ),
//   );

//   service.startService();
// }

// void onStart(ServiceInstance service) {
//   if (service is AndroidServiceInstance) {
//     service.setAsForegroundService();
//   }

//   Timer.periodic(const Duration(seconds: 20), (timer) {
//     service.invoke("update");
//   });
// }
