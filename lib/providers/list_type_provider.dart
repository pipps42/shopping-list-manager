import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider per il tipo di lista attualmente selezionata
final currentListTypeProvider = StateProvider<String>((ref) => 'weekly');

// Helper per ottenere il nome visualizzato del tipo di lista
String getListTypeName(String listType) {
  switch (listType) {
    case 'weekly':
      return 'Spesa Settimanale';
    case 'monthly':
      return 'Spesa Mensile';
    case 'occasional':
      return 'Spesa Occasionale';
    default:
      return 'Lista';
  }
}

// Helper per ottenere l'icona del tipo di lista
IconData getListTypeIcon(String listType) {
  switch (listType) {
    case 'weekly':
      return Icons.today; // Icona giorno del calendario
    case 'monthly':
      return Icons.calendar_month; // Icona calendario mensile
    case 'occasional':
      return Icons.shopping_bag; // Icona busta della spesa
    default:
      return Icons.list;
  }
}