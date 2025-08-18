import 'tutorial_config.dart';
import 'tutorial_page.dart';

class TutorialConfigs {
  static final Map<String, TutorialConfig> _configs = {
    'current_list': TutorialConfig(
      sectionKey: 'current_list',
      title: 'Gestione della Lista',
      subtitle: 'Impara a gestire la tua lista della spesa',
      pages: [
        const TutorialPage(
          title: 'Benvenuto nella Lista Corrente',
          description:
              'Qui puoi gestire la tua lista della spesa organizzata per reparti.\n'
              'Ogni reparto raggruppa i prodotti per facilitare la spesa nel tuo supermercato.',
          mediaAsset: 'assets/tutorials/current_list/current_list.jpg',
          mediaType: MediaType.image,
        ),
        const TutorialPage(
          title: 'Aggiungere Prodotti',
          description:
              'Tocca il pulsante "+" per aggiungere un nuovo prodotto.\n'
              'Puoi cercarlo tra quelli esistenti. Potrai creare nuovi prodotti nelle apposite sezioni.',
          mediaAsset: 'assets/tutorials/current_list/add-product.webm',
          mediaType: MediaType.webm,
        ),
        const TutorialPage(
          title: 'Aggiungere Prodotti',
          description:
              'Puoi anche aggiungere prodotti tramite comando vocale. Tocca il bottone col microfono ed elenca i prodotti.',
          mediaAsset: 'assets/tutorials/current_list/voice-command.webm',
          mediaType: MediaType.webm,
        ),
        const TutorialPage(
          title: 'Fare la Spesa',
          description:
              'Mentre fai la spesa, trascina a destra un prodotto per segnarlo come "Preso".\n'
              'Trascina a sinistra per segnarlo nuovamente come "Da Prendere".\n'
              'Trascina a sinistra fino in fondo per rimuovere il prodotto dalla lista.',
          mediaAsset: 'assets/tutorials/current_list/check-uncheck.webm',
          mediaType: MediaType.webm,
        ),
        const TutorialPage(
          title: 'Completare la Lista',
          description:
              'Quando hai finito la spesa, tocca il pulsante "Completa Lista" per archiviare la lista con tutti i prodotti presenti o solo con quelli che hai spuntato.\n'
              'Una nuova lista verrà creata automaticamente, vuota o con i prodotti che hai lasciato in sospeso.',
          mediaAsset: 'assets/tutorials/current_list/complete-list.webm',
          mediaType: MediaType.webm,
        ),
      ],
    ),

    'departments_management': TutorialConfig(
      sectionKey: 'departments_management',
      title: 'Gestione Reparti',
      subtitle: 'Personalizza i reparti del tuo supermercato',
      pages: [
        const TutorialPage(
          title: 'Organizzazione per Reparti',
          description:
              'I reparti aiutano a organizzare la lista seguendo la configurazione del tuo supermercato.',
          mediaAsset: 'assets/tutorials/departments/departments.jpg',
          mediaType: MediaType.image,
        ),
        const TutorialPage(
          title: 'Ordinare i Reparti',
          description:
              'Tieni premuto un reparto e trascinalo in alto o in basso per riordinarlo.\n'
              'Ordina i reparti in base al percorso che fai nel tuo supermercato.',
          mediaAsset: 'assets/tutorials/departments/reorder.webm',
          mediaType: MediaType.webm,
        ),
        const TutorialPage(
          title: 'Aggiungere Reparti',
          description:
              'Tocca il pulsante "+" per aggiungere un nuovo reparto.\n'
              'Il nuovo reparto verrà aggiunto alla fine della lista.',
          mediaAsset: 'assets/tutorials/departments/add-department.webm',
          mediaType: MediaType.webm,
        ),
        const TutorialPage(
          title: 'Modificare Reparti',
          description:
              'Puoi modificare le informazioni base di un reparto tramite l\'apposito bottone.',
          mediaAsset: 'assets/tutorials/departments/edit-department.webm',
          mediaType: MediaType.webm,
        ),
        const TutorialPage(
          title: 'Ispezionare un Reparto',
          description:
              'Tocca un reparto per visualizzare i prodotti al suo interno.\n'
              'Puoi aggiungere nuovi prodotti al reparto o modificare quelli esistenti.',
          mediaAsset: 'assets/tutorials/departments/edit-products.webm',
          mediaType: MediaType.webm,
        ),
      ],
    ),

    'products_management': TutorialConfig(
      sectionKey: 'products_management',
      title: 'Gestione Prodotti',
      subtitle: 'Organizza il tuo database di prodotti',
      pages: [
        const TutorialPage(
          title: 'Database Prodotti',
          description:
              'Qui puoi gestire tutti i prodotti disponibili, organizzati per reparto.',
          mediaAsset: 'assets/tutorials/products/products.jpg',
          mediaType: MediaType.image,
        ),
        const TutorialPage(
          title: 'Filtrare e Cercare',
          description:
              'Usa i filtri per trovare rapidamente i prodotti nel tuo database.',
          mediaAsset: 'assets/tutorials/products/search-products.webm',
          mediaType: MediaType.webm,
        ),
        const TutorialPage(
          title: 'Spostare Prodotti',
          description:
              'Puoi spostare i prodotti tra reparti per una migliore organizzazione.',
          mediaAsset: 'assets/tutorials/products/move-department.webm',
          mediaType: MediaType.webm,
        ),
        const TutorialPage(
          title: 'Creare Prodotti',
          description:
              'Tocca il pulsante "+" per aggiungere un nuovo prodotto.',
          mediaAsset: 'assets/tutorials/products/add-product.webm',
          mediaType: MediaType.webm,
        ),
      ],
    ),

    'loyalty_cards': TutorialConfig(
      sectionKey: 'loyalty_cards',
      title: 'Carte Fedeltà',
      subtitle: 'Tieni sempre con te le tue carte',
      pages: [
        const TutorialPage(
          title: 'Le Tue Carte',
          description:
              'Salva le immagini delle tue carte fedeltà per averle sempre con te quando fai la spesa.',
          mediaAsset: 'assets/tutorials/loyalty_cards/loyalty_cards.jpg',
          mediaType: MediaType.image,
        ),
        const TutorialPage(
          title: 'Aggiungere una Carta',
          description:
              'Tocca "+" per aggiungere una nuova carta.\n'
              'Puoi scattare una foto o selezionarla dalla galleria.',
          mediaAsset: 'assets/tutorials/loyalty_cards/add-card.webm',
          mediaType: MediaType.webm,
        ),
      ],
    ),

    'recipes': TutorialConfig(
      sectionKey: 'recipes',
      title: 'Gestione Ricette',
      subtitle: 'Scopri come organizzare le tue ricette',
      pages: [
        const TutorialPage(
          title: 'Le Tue Ricette',
          description:
              'Qui puoi salvare le tue ricette preferite con gli ingredienti necessari a realizzarle.',
          mediaAsset: 'assets/tutorials/recipes/recipes.jpg',
          mediaType: MediaType.image,
        ),
        const TutorialPage(
          title: 'Creare una Ricetta',
          description:
              'Tocca il pulsante "+" per aggiungere una nuova ricetta.',
          mediaAsset: 'assets/tutorials/recipes/add-edit-recipe.webm',
          mediaType: MediaType.webm,
        ),
        const TutorialPage(
          title: 'Gestire gli Ingredienti',
          description:
              'Tocca il pulsante "Gestisci Ingredienti" per gestire gli ingredienti di una ricetta.\n'
              'Usa i filtri per trovare rapidamente gli ingredienti che ti servono.\n',
          mediaAsset: 'assets/tutorials/recipes/edit-ingredients.webm',
          mediaType: MediaType.webm,
        ),
        const TutorialPage(
          title: 'Aggiungere Ingredienti alla Lista',
          description:
              'Tocca una ricetta e seleziona gli ingredienti da aggiungere direttamente alla tua lista della spesa.\n'
              'Puoi scegliere a quale lista aggiungerli tramite il menù a tendina.\n'
              'Se gli ingredienti sono già presenti nella lista, appariranno in verde.',
          mediaAsset: 'assets/tutorials/recipes/ingredients-to-list.webm',
          mediaType: MediaType.webm,
        ),
      ],
    ),

    'completed_lists': TutorialConfig(
      sectionKey: 'completed_lists',
      title: 'Storico delle Liste',
      subtitle: 'Rivedi le tue spese precedenti',
      pages: [
        const TutorialPage(
          title: 'Storico delle Spese',
          description:
              'Qui trovi tutte le liste della spesa che hai già completato, dalla più recente alla più datata.',
          mediaAsset: 'assets/tutorials/completed_lists/completed_lists.jpg',
          mediaType: MediaType.image,
        ),
        const TutorialPage(
          title: 'Riepilogo delle Spese',
          description:
              'Tocca una lista per visualizzare il riepilogo di quella spesa.\n'
              'Nota: il riepilogo è solo per visualizzazione, non puoi modificare le liste già completate. '
              'Inoltre, se elimini un reparto o un prodotto, non potrai più visualizzarlo nel riepilogo.',
          mediaAsset:
              'assets/tutorials/completed_lists/completed_list_detail.jpg',
          mediaType: MediaType.image,
        ),
        const TutorialPage(
          title: 'Modificare il Prezzo',
          description:
              'Non avevi segnato il prezzo di una spesa? Nessun problema, puoi modificarlo in qualsiasi momento.\n',
          mediaAsset: 'assets/tutorials/completed_lists/edit-price.webm',
          mediaType: MediaType.webm,
        ),
        const TutorialPage(
          title: 'Riutilizzare Liste',
          description: 'Work in Progress...',
        ),
        const TutorialPage(
          title: 'Statistiche delle Spese',
          description: 'Work in Progress...',
        ),
      ],
    ),
  };

  static TutorialConfig? getConfig(String sectionKey) {
    return _configs[sectionKey];
  }

  static Map<String, TutorialConfig> getAllConfigs() {
    return Map.from(_configs);
  }

  static List<String> getAvailableSections() {
    return _configs.keys.toList();
  }

  static void registerCustomConfig(TutorialConfig config) {
    _configs[config.sectionKey] = config;
  }
}
