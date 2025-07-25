class AppConstants {
  // App Info
  static const String appName = 'Lista Spesa Esselunga';
  static const String appVersion = '1.0.0';

  // Colori Esselunga
  static const int esseLungaGreen = 0xFF00A651;
  static const int esseLungaRed = 0xFFE31E24;

  // Database
  static const String databaseName = 'shopping_list.db';
  static const int databaseVersion = 1;

  // === DIMENSIONI ===
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;

  // Icon/Image Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;

  static const double imageS = 30.0;
  static const double imageM = 40.0;
  static const double imageL = 50.0;
  static const double imageXL = 60.0;

  // Font Sizes
  static const double fontS = 10.0;
  static const double fontM = 12.0;
  static const double fontL = 14.0;
  static const double fontXL = 16.0;
  static const double fontXXL = 18.0;
  static const double fontXXXL = 20.0;
  static const double fontTitle = 24.0;

  // Elevations
  static const double elevationS = 1.0;
  static const double elevationM = 2.0;
  static const double elevationL = 4.0;
  static const double elevationXL = 8.0;

  // UI Elements
  static const double cardElevation = elevationM;
  static const double borderRadius = radiusM;
  static const double imageSize = imageL;
  static const double thumbnailSize = imageM;

  // Immagini
  static const int maxImageWidth = 300;
  static const int maxImageHeight = 300;
  static const int imageQuality = 85;
  static const int imageCacheWidth = 100;
  static const int imageCacheHeight = 100;

  // Lista Bottom Spacing (per FAB)
  static const double listBottomSpacing = 88.0;

  // Validazione
  static const int productNameMinLength = 2;
  static const int productNameMaxLength = 50;
  static const int departmentNameMinLength = 3;
  static const int departmentNameMaxLength = 30;

  // Timeline constants
  static const double timelineSeparatorMargin =
      8.0; // Spacing dopo i separatori mese
  static const double timelineListItemMargin = 2.0; // Spacing tra le card liste
  static const double timelineHorizontalGap =
      4.0; // Gap tra timeline e label mese
  static const double timelineLineHeight = 60.0; // Altezza linea di connessione
  static const double timelineItemHeight = 85.0; // Altezza elemento lista
  static const double timelineSegmentWidth = 40.0; // Larghezza timeline
  static const double timelineContentPadding =
      6.0; // Padding verticale contenuto
}

class AppStrings {
  // === AZIONI ===
  static const String add = 'Aggiungi';
  static const String edit = 'Modifica';
  static const String delete = 'Elimina';
  static const String cancel = 'Annulla';
  static const String save = 'Salva';
  static const String ok = 'OK';
  static const String close = 'Chiudi';
  static const String confirm = 'Conferma';
  static const String camera = 'Camera';
  static const String gallery = 'Galleria';

  // === ERRORI ===
  static const String genericError = 'Si è verificato un errore';
  static const String loadingError = 'Errore nel caricamento';
  static const String networkError = 'Errore di connessione';

  // === MESSAGGI ===
  static const String productAdded = 'Prodotto aggiunto';
  static const String productDeleted = 'Prodotto eliminato';
  static const String departmentAdded = 'Reparto aggiunto';
  static const String departmentDeleted = 'Reparto eliminato';

  // === CONFERME ===
  static const String confirmDelete = 'Sei sicuro di voler eliminare';
  static const String confirmClearList =
      'Sei sicuro di voler rimuovere tutti i prodotti dalla lista corrente?';
  static const String confirmDeleteDepartment =
      'Tutti i prodotti associati verranno eliminati.';

  // === PLACEHOLDERS ===
  static const String searchPlaceholder = 'Cerca prodotti...';
  static const String searchProductPlaceholder = 'Cerca prodotto...';
  static const String productNamePlaceholder = 'Nome prodotto';
  static const String departmentNamePlaceholder = 'Nome reparto';

  // === TITLES ===
  static const String currentList = 'Lista Corrente';
  static const String departmentManagement = 'Gestione Reparti';
  static const String productManagement = 'Gestione Prodotti';
  static const String addProduct = 'Aggiungi Prodotto';
  static const String editProduct = 'Modifica Prodotto';
  static const String newProduct = 'Nuovo Prodotto';
  static const String addDepartment = 'Nuovo Reparto';
  static const String editDepartment = 'Modifica Reparto';
  static const String loyaltyCards = 'Carte Fedeltà';
  static const String lastLists = 'Ultime Liste';

  // === STATUS ===
  static const String loading = 'Caricamento...';
  static const String loadingProducts = 'Caricamento prodotti...';
  static const String loadingDepartments = 'Caricamento reparti...';
  static const String loadingList = 'Caricamento lista...';

  // === EMPTY STATES ===
  static const String emptyList = 'Lista vuota';
  static const String emptyProducts = 'Nessun prodotto';
  static const String emptyDepartments = 'Nessun reparto';
  static const String emptyListSubtitle = 'Aggiungi prodotti con il pulsante +';
  static const String emptyProductsSubtitle =
      'Aggiungi il primo prodotto con il pulsante +';
  static const String emptyDepartmentsSubtitle =
      'Aggiungi il primo reparto con il pulsante +';

  // === ACTIONS ===
  static const String clearList = 'Svuota lista';
  static const String moveProduct = 'Cambia reparto';
  static const String chooseImage = 'Seleziona un\'immagine';
  static const String removeImage = 'Rimuovi';
  static const String viewProducts = 'Visualizza prodotti';

  // === VALIDATION ===
  static const String fieldRequired = 'Campo obbligatorio';
  static const String productNameRequired =
      'Il nome del prodotto è obbligatorio';
  static const String departmentNameRequired =
      'Il nome del reparto è obbligatorio';
  static const String selectDepartment = 'Seleziona un reparto';

  // === INFO ===
  static const String appFullName = 'Lista Spesa\nAssistente';
  static const String reorderInstructions =
      'Trascina per riordinare i reparti secondo il layout del supermercato';

  // === COMPLETE LIST ===
  static const String completeList = 'Completa Lista';
  static const String howToComplete = 'Come vuoi completare la spesa?';
  static const String markAllAsTaken = 'Ho preso tutto';
  static const String markAllAsTakenSubtitle =
      'Marca tutti i prodotti come acquistati';
  static const String keepCurrentState = 'Ho preso solo i selezionati';
  static const String keepCurrentStateSubtitle =
      'Mantieni lo stato attuale dei prodotti';
  static const String totalCost = 'Totale Spesa';
  static const String enterTotalCost = 'Vuoi registrare quanto hai speso?';
  static const String totalCostHint =
      'Puoi aggiungere o modificare questo importo in seguito.';
  static const String amount = 'Importo (€)';
  static const String optional = 'Opzionale - lascia vuoto per saltare';
  static const String skip = 'Salta';
  static const String listCompleted = 'Lista completata con successo!';
  static const String listIsEmpty =
      'La lista è vuota! Aggiungi prodotti prima di completarla.';
  static const String completionError = 'Errore nel completamento';
  static const String invalidAmount = 'Inserisci un importo valido';
  static const String listCleared = 'Lista svuotata con successo!';
  static const String noItemsSelected =
      'Non hai selezionato nessun prodotto! Seleziona almeno un prodotto o scegli "Ho preso tutto".';
}
