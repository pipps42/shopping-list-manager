import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final service = DatabaseService();

  // Il DatabaseService è un singleton che rimane vivo per tutta l'app
  // Cleanup gestito quando l'app si chiude
  return service;
});
