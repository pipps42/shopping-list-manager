class AppConstants {
  static const String appName = 'Lista Spesa Esselunga';
  static const String appVersion = '1.0.0';

  // Colori Esselunga
  static const int esseLungaGreen = 0xFF00A651;
  static const int esseLungaRed = 0xFFE31E24;

  // Dimensioni immagini
  static const int maxImageWidth = 800;
  static const int maxImageHeight = 800;
  static const int imageQuality = 85;

  // Database
  static const String databaseName = 'shopping_list.db';
  static const int databaseVersion = 1;

  // UI Constants
  static const double imageSize = 50.0;
  static const double thumbnailSize = 40.0;
  static const double cardElevation = 2.0;
  static const double borderRadius = 8.0;

  // Cache sizes
  static const int imageCacheWidth = 100;
  static const int imageCacheHeight = 100;
}

class AppStrings {
  // Errors
  static const String genericError = 'Si è verificato un errore';

  // Actions
  static const String add = 'Aggiungi';
  static const String edit = 'Modifica';
  static const String delete = 'Elimina';
  static const String cancel = 'Annulla';
  static const String save = 'Salva';

  // Messages
  static const String productAdded = 'Prodotto aggiunto';
  static const String productDeleted = 'Prodotto eliminato';
  static const String confirmDelete = 'Sei sicuro di voler eliminare';

  // Placeholders
  static const String searchPlaceholder = 'Cerca prodotti...';
  static const String productNamePlaceholder = 'Nome prodotto';
}
