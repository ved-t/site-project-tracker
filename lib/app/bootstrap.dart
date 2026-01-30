import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/local_storage_service.dart';
import 'app.dart';

Future<void> bootstrap() async {
  await LocalStorageService.init();
  runApp(const ProviderScope(child: MyApp()));
}
