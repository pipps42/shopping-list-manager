import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

final databaseServiceProvider = Provider.autoDispose<DatabaseService>((ref) {
  final service = DatabaseService();

  // Cleanup se necessario
  ref.onDispose(() {
    // Esegue la chiusura in background senza bloccare il dispose
    service.close();
  });

  return service;
});
