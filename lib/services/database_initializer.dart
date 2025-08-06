import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Servizio dedicato all'inizializzazione dei dati di default del database
class DatabaseInitializer {
  /// Inizializza tutti i dati di default nel database
  static Future<void> initializeDefaultData(Database db) async {
    await _insertDefaultDepartments(db);
    await _insertDefaultProducts(db);
    await _insertDefaultLists(db);
  }

  /// Inserisce i reparti di default con icone copiate dagli asset
  static Future<void> _insertDefaultDepartments(Database db) async {
    // Reparti Esselunga in ordine tipico con mapping delle icone
    final departments = [
      {
        'name': 'Frutta e Verdura',
        'order_index': 1,
        'asset_icon': 'assets/icons/vegetable.png',
      },
      {
        'name': 'Salumeria e Formaggi',
        'order_index': 2,
        'asset_icon': 'assets/icons/cheese.png',
      },
      {
        'name': 'Latticini e Uova',
        'order_index': 3,
        'asset_icon': 'assets/icons/eggs-milk.png',
      },
      {
        'name': 'Carne',
        'order_index': 4,
        'asset_icon': 'assets/icons/meat.png',
      },
      {
        'name': 'Pesce',
        'order_index': 5,
        'asset_icon': 'assets/icons/fish.png',
      },
      {
        'name': 'Pane e Panetteria',
        'order_index': 6,
        'asset_icon': 'assets/icons/bread.png',
      },
      {
        'name': 'Pasta, Riso e Cereali',
        'order_index': 7,
        'asset_icon': 'assets/icons/pasta.png',
      },
      {
        'name': 'Conserve e Scatolame',
        'order_index': 8,
        'asset_icon': 'assets/icons/canned-food.png',
      },
      {
        'name': 'Olio, Aceto e Condimenti',
        'order_index': 9,
        'asset_icon': 'assets/icons/condiment.png',
      },
      {
        'name': 'Biscotti e Dolciumi',
        'order_index': 10,
        'asset_icon': 'assets/icons/cookie.png',
      },
      {
        'name': 'Detersivi e Pulizia',
        'order_index': 11,
        'asset_icon': 'assets/icons/cleaning-service.png',
      },
      {
        'name': 'Igiene Personale',
        'order_index': 12,
        'asset_icon': 'assets/icons/hand-wash.png',
      },
      {
        'name': 'Animali Domestici',
        'order_index': 13,
        'asset_icon': 'assets/icons/pet-food.png',
      },
      {
        'name': 'Bevande',
        'order_index': 14,
        'asset_icon': 'assets/icons/bottles.png',
      },
      {
        'name': 'Vini e Alcolici',
        'order_index': 15,
        'asset_icon': 'assets/icons/alcohols.png',
      },
      {
        'name': 'Surgelati',
        'order_index': 16,
        'asset_icon': 'assets/icons/freeze.png',
      },
    ];

    // Ottieni la directory per salvare le icone
    final appDir = await getApplicationDocumentsDirectory();
    final iconsDir = Directory('${appDir.path}/department_icons');
    if (!await iconsDir.exists()) {
      await iconsDir.create(recursive: true);
    }

    for (final dept in departments) {
      String? localImagePath;

      try {
        // Carica l'asset come bytes
        final ByteData data = await rootBundle.load(
          dept['asset_icon'] as String,
        );
        final Uint8List bytes = data.buffer.asUint8List();

        // Crea il nome del file locale
        final String fileName = (dept['asset_icon'] as String).split('/').last;
        final File localFile = File('${iconsDir.path}/$fileName');

        // Salva il file localmente
        await localFile.writeAsBytes(bytes);
        localImagePath = localFile.path;
      } catch (e) {
        // Se c'è un errore nel caricamento dell'asset, usa null (icona di default)
        print('Errore nel caricare l\'icona per ${dept['name']}: $e');
        localImagePath = null;
      }

      // Inserisci il reparto con il percorso dell'icona locale
      await db.insert('departments', {
        'name': dept['name'],
        'order_index': dept['order_index'],
        'image_path': localImagePath,
      });
    }
  }

  /// Inserisce un set completo di prodotti strategici (~100 prodotti)
  static Future<void> _insertDefaultProducts(Database db) async {
    final products = [
      // === FRUTTA E VERDURA (id: 1) - 20 prodotti ===
      {'name': 'Mele', 'department_id': 1},
      {'name': 'Banane', 'department_id': 1},
      {'name': 'Arance', 'department_id': 1},
      {'name': 'Limoni', 'department_id': 1},
      {'name': 'Pomodori', 'department_id': 1},
      {'name': 'Pomodorini', 'department_id': 1},
      {'name': 'Carote', 'department_id': 1},
      {'name': 'Cipolle', 'department_id': 1},
      {'name': 'Aglio', 'department_id': 1},
      {'name': 'Patate', 'department_id': 1},
      {'name': 'Lattuga', 'department_id': 1},
      {'name': 'Insalata', 'department_id': 1},
      {'name': 'Spinaci', 'department_id': 1},
      {'name': 'Zucchine', 'department_id': 1},
      {'name': 'Melanzane', 'department_id': 1},
      {'name': 'Peperoni', 'department_id': 1},
      {'name': 'Broccoli', 'department_id': 1},
      {'name': 'Cavolfiore', 'department_id': 1},
      {'name': 'Basilico', 'department_id': 1},
      {'name': 'Prezzemolo', 'department_id': 1},
      {'name': 'Cetrioli', 'department_id': 1},
      {'name': 'Funghi', 'department_id': 1},

      // === SALUMERIA E FORMAGGI (id: 2) - 15 prodotti ===
      {'name': 'Prosciutto Crudo', 'department_id': 2},
      {'name': 'Prosciutto Cotto', 'department_id': 2},
      {'name': 'Salame', 'department_id': 2},
      {'name': 'Mortadella', 'department_id': 2},
      {'name': 'Bresaola', 'department_id': 2},
      {'name': 'Speck', 'department_id': 2},
      {'name': 'Parmigiano Reggiano', 'department_id': 2},
      {'name': 'Gorgonzola', 'department_id': 2},
      {'name': 'Mozzarella', 'department_id': 2},
      {'name': 'Ricotta', 'department_id': 2},
      {'name': 'Stracchino', 'department_id': 2},
      {'name': 'Pecorino', 'department_id': 2},
      {'name': 'Grana Padano', 'department_id': 2},
      {'name': 'Provolone', 'department_id': 2},
      {'name': 'Taleggio', 'department_id': 2},

      // === LATTICINI E UOVA (id: 3) - 8 prodotti ===
      {'name': 'Latte', 'department_id': 3},
      {'name': 'Latte di Soia', 'department_id': 3},
      {'name': 'Yogurt', 'department_id': 3},
      {'name': 'Uova', 'department_id': 3},
      {'name': 'Burro', 'department_id': 3},
      {'name': 'Panna da Cucina', 'department_id': 3},
      {'name': 'Mascarpone', 'department_id': 3},
      {'name': 'Philadelphia', 'department_id': 3},

      // === CARNE (id: 4) - 10 prodotti ===
      {'name': 'Petto di Pollo', 'department_id': 4},
      {'name': 'Cosce di Pollo', 'department_id': 4},
      {'name': 'Fesa di Tacchino', 'department_id': 4},
      {'name': 'Carne Macinata', 'department_id': 4},
      {'name': 'Bistecca di Manzo', 'department_id': 4},
      {'name': 'Scaloppine', 'department_id': 4},
      {'name': 'Salsiccia', 'department_id': 4},
      {'name': 'Pancetta', 'department_id': 4},
      {'name': 'Guanciale', 'department_id': 4},
      {'name': 'Costolette', 'department_id': 4},

      // === PESCE (id: 5) - 9 prodotti ===
      {'name': 'Salmone', 'department_id': 5},
      {'name': 'Tonno Fresco', 'department_id': 5},
      {'name': 'Branzino', 'department_id': 5},
      {'name': 'Orata', 'department_id': 5},
      {'name': 'Merluzzo', 'department_id': 5},
      {'name': 'Gamberetti', 'department_id': 5},
      {'name': 'Calamari', 'department_id': 5},
      {'name': 'Cozze', 'department_id': 5},
      {'name': 'Vongole', 'department_id': 5},

      // === PANE E PANETTERIA (id: 6) - 8 prodotti ===
      {'name': 'Pane Integrale', 'department_id': 6},
      {'name': 'Pane Bianco', 'department_id': 6},
      {'name': 'Pane di Segale', 'department_id': 6},
      {'name': 'Pan Carrè', 'department_id': 6},
      {'name': 'Focaccia', 'department_id': 6},
      {'name': 'Grissini', 'department_id': 6},
      {'name': 'Crackers', 'department_id': 6},
      {'name': 'Fette Biscottate', 'department_id': 6},

      // === PASTA, RISO E CEREALI (id: 7) - 8 prodotti ===
      {'name': 'Spaghetti', 'department_id': 7},
      {'name': 'Penne', 'department_id': 7},
      {'name': 'Fusilli', 'department_id': 7},
      {'name': 'Rigatoni', 'department_id': 7},
      {'name': 'Riso Carnaroli', 'department_id': 7},
      {'name': 'Riso Basmati', 'department_id': 7},
      {'name': 'Farro', 'department_id': 7},
      {'name': 'Orzo', 'department_id': 7},
      {'name': 'Quinoa', 'department_id': 7},

      // === CONSERVE E SCATOLAME (id: 8) - 12 prodotti ===
      {'name': 'Pelati', 'department_id': 8},
      {'name': 'Passata di Pomodoro', 'department_id': 8},
      {'name': 'Tonno in Scatola', 'department_id': 8},
      {'name': 'Fagioli', 'department_id': 8},
      {'name': 'Ceci', 'department_id': 8},
      {'name': 'Lenticchie', 'department_id': 8},
      {'name': 'Mais', 'department_id': 8},
      {'name': 'Piselli', 'department_id': 8},
      {'name': 'Olive Nere', 'department_id': 8},
      {'name': 'Olive Verdi', 'department_id': 8},
      {'name': 'Capperi', 'department_id': 8},
      {'name': 'Acciughe', 'department_id': 8},

      // === OLIO, ACETO E CONDIMENTI (id: 9) - 10 prodotti ===
      {'name': 'Olio EVO', 'department_id': 9},
      {'name': 'Olio di Semi', 'department_id': 9},
      {'name': 'Aceto Balsamico', 'department_id': 9},
      {'name': 'Aceto di Vino', 'department_id': 9},
      {'name': 'Sale Fino', 'department_id': 9},
      {'name': 'Sale Grosso', 'department_id': 9},
      {'name': 'Pepe Nero', 'department_id': 9},
      {'name': 'Origano', 'department_id': 9},
      {'name': 'Rosmarino', 'department_id': 9},
      {'name': 'Peperoncino', 'department_id': 9},
      {'name': 'Cannella', 'department_id': 9},

      // === BISCOTTI E DOLCIUMI (id: 10) - 6 prodotti ===
      {'name': 'Biscotti', 'department_id': 10},
      {'name': 'Cioccolata', 'department_id': 10},
      {'name': 'Nutella', 'department_id': 10},
      {'name': 'Miele', 'department_id': 10},
      {'name': 'Merendine', 'department_id': 10},
      {'name': 'Zucchero', 'department_id': 10},
      {'name': 'Farina 00', 'department_id': 10},

      // === DETERSIVI E PULIZIA (id: 11) - 8 prodotti ===
      {'name': 'Detersivo Piatti', 'department_id': 11},
      {'name': 'Detersivo Lavatrice', 'department_id': 11},
      {'name': 'Detersivo Lavastoviglie', 'department_id': 11},
      {'name': 'Ammorbidente', 'department_id': 11},
      {'name': 'Candeggina', 'department_id': 11},
      {'name': 'Sgrassatore', 'department_id': 11},
      {'name': 'Spugne', 'department_id': 11},
      {'name': 'Carta Assorbente', 'department_id': 11},
      {'name': 'Panno Microfibra', 'department_id': 11},

      // === IGIENE PERSONALE (id: 12) - 8 prodotti ===
      {'name': 'Carta Igienica', 'department_id': 12},
      {'name': 'Shampoo', 'department_id': 12},
      {'name': 'Balsamo', 'department_id': 12},
      {'name': 'Sapone', 'department_id': 12},
      {'name': 'Dentifricio', 'department_id': 12},
      {'name': 'Spazzolino', 'department_id': 12},
      {'name': 'Deodorante', 'department_id': 12},
      {'name': 'Collutorio', 'department_id': 12},
      {'name': 'Filo Interdentale', 'department_id': 12},

      // === ANIMALI DOMESTICI (id: 13) - 5 prodotti ===
      {'name': 'Crocchette', 'department_id': 13},
      {'name': 'Scatolette', 'department_id': 13},
      {'name': 'Lettiera', 'department_id': 13},
      {'name': 'Shampoo Animali', 'department_id': 13},
      {'name': 'Giocattoli Animali', 'department_id': 13},

      // === BEVANDE (id: 14) - 10 prodotti ===
      {'name': 'Acqua', 'department_id': 14},
      {'name': 'Aranciata', 'department_id': 14},
      {'name': 'Coca-Cola', 'department_id': 14},
      {'name': 'Thé Freddo', 'department_id': 14},
      {'name': 'Red Bull', 'department_id': 14},
      {'name': 'Succo d\'Arancia', 'department_id': 14},
      {'name': 'Succo di Mela', 'department_id': 14},
      {'name': 'ACE', 'department_id': 14},

      // === VINI E ALCOLICI (id: 15) - 7 prodotti ===
      {'name': 'Vino Bianco', 'department_id': 15},
      {'name': 'Vino Rosso', 'department_id': 15},
      {'name': 'Birra', 'department_id': 15},
      {'name': 'Gin', 'department_id': 15},
      {'name': 'Rum', 'department_id': 15},
      {'name': 'Vodka', 'department_id': 15},
      {'name': 'Whiskey', 'department_id': 15},

      // === SURGELATI (id: 16) - 9 prodotti ===
      {'name': 'Piselli Surgelati', 'department_id': 16},
      {'name': 'Pizza Surgelata', 'department_id': 16},
      {'name': 'Gelato', 'department_id': 16},
      {'name': 'Merluzzo Surgelato', 'department_id': 16},
      {'name': 'Funghi Surgelati', 'department_id': 16},
      {'name': 'Verdure Grigliate', 'department_id': 16},
      {'name': 'Spinaci Surgelati', 'department_id': 16},
      {'name': 'Burger Vegetali', 'department_id': 16},
      {'name': 'Patatine Fritte', 'department_id': 16},
    ];

    for (final product in products) {
      await db.insert('products', product);
    }
  }

  /// Inserisce le liste correnti iniziali vuote
  static Future<void> _insertDefaultLists(Database db) async {
    final now = DateTime.now();

    // Crea le tre liste correnti vuote
    await db.insert('shopping_lists', {
      'name': 'Spesa Settimanale',
      'created_at': now.millisecondsSinceEpoch,
      'list_type': 'weekly',
    });

    await db.insert('shopping_lists', {
      'name': 'Spesa Mensile',
      'created_at': now.millisecondsSinceEpoch,
      'list_type': 'monthly',
    });

    await db.insert('shopping_lists', {
      'name': 'Spesa Occasionale',
      'created_at': now.millisecondsSinceEpoch,
      'list_type': 'occasional',
    });
  }
}
