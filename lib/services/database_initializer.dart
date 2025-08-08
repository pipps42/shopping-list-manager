import 'package:sqflite/sqflite.dart';

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
        'asset_icon': 'assets/icons/departments/vegetable.png',
      },
      {
        'name': 'Salumeria e Formaggi',
        'order_index': 2,
        'asset_icon': 'assets/icons/departments/cheese.png',
      },
      {
        'name': 'Latticini e Uova',
        'order_index': 3,
        'asset_icon': 'assets/icons/departments/eggs-milk.png',
      },
      {
        'name': 'Carne',
        'order_index': 4,
        'asset_icon': 'assets/icons/departments/meat.png',
      },
      {
        'name': 'Pesce',
        'order_index': 5,
        'asset_icon': 'assets/icons/departments/fish.png',
      },
      {
        'name': 'Pane e Panetteria',
        'order_index': 6,
        'asset_icon': 'assets/icons/departments/bread.png',
      },
      {
        'name': 'Pasta, Riso e Cereali',
        'order_index': 7,
        'asset_icon': 'assets/icons/departments/pasta.png',
      },
      {
        'name': 'Conserve e Scatolame',
        'order_index': 8,
        'asset_icon': 'assets/icons/departments/canned-food.png',
      },
      {
        'name': 'Olio, Aceto e Condimenti',
        'order_index': 9,
        'asset_icon': 'assets/icons/departments/condiment.png',
      },
      {
        'name': 'Biscotti e Dolciumi',
        'order_index': 10,
        'asset_icon': 'assets/icons/departments/cookie.png',
      },
      {
        'name': 'Detersivi e Pulizia',
        'order_index': 11,
        'asset_icon': 'assets/icons/departments/cleaning-service.png',
      },
      {
        'name': 'Igiene Personale',
        'order_index': 12,
        'asset_icon': 'assets/icons/departments/hand-wash.png',
      },
      {
        'name': 'Accessori da Cucina',
        'order_index': 13,
        'asset_icon': 'assets/icons/departments/kitchen.png',
      },
      {
        'name': 'Animali Domestici',
        'order_index': 14,
        'asset_icon': 'assets/icons/departments/pet-food.png',
      },
      {
        'name': 'Bevande',
        'order_index': 15,
        'asset_icon': 'assets/icons/departments/bottles.png',
      },
      {
        'name': 'Vini e Alcolici',
        'order_index': 16,
        'asset_icon': 'assets/icons/departments/alcohols.png',
      },
      {
        'name': 'Surgelati',
        'order_index': 17,
        'asset_icon': 'assets/icons/departments/freeze.png',
      },
      {
        'name': 'Cartoleria',
        'order_index': 18,
        'asset_icon': 'assets/icons/departments/stationery.png',
      },
    ];

    for (final dept in departments) {
      // Inserisci il reparto con il nuovo sistema di icone
      await db.insert('departments', {
        'name': dept['name'],
        'order_index': dept['order_index'],
        'icon_type': 'asset',
        'icon_value': dept['asset_icon'],
      });
    }
  }

  /// Inserisce un set completo di prodotti strategici (~100 prodotti)
  static Future<void> _insertDefaultProducts(Database db) async {
    final products = [
      // === FRUTTA E VERDURA (id: 1) - 22 prodotti ===
      {
        'name': 'Mele',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/003-apple.png',
      },
      {
        'name': 'Banane',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/002-banana.png',
      },
      {
        'name': 'Arance',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/004-orange.png',
      },
      {
        'name': 'Limoni',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/005-lemon.png',
      },
      {
        'name': 'Pomodori',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/006-tomato.png',
      },
      {
        'name': 'Pomodorini',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/001-cherry-tomato.png',
      },
      {
        'name': 'Carote',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/007-carrot.png',
      },
      {
        'name': 'Cipolle',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/008-onion.png',
      },
      {
        'name': 'Aglio',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/009-garlic.png',
      },
      {
        'name': 'Patate',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/potatoes.png',
      }, // riuso carote
      {
        'name': 'Lattuga',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/010-lettuce.png',
      },
      {
        'name': 'Insalata',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/010-lettuce.png',
      }, // riuso lattuga
      {
        'name': 'Spinaci',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/011-spinach.png',
      },
      {
        'name': 'Zucchine',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/012-zucchini.png',
      },
      {
        'name': 'Melanzane',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/014-eggplant.png',
      },
      {
        'name': 'Peperoni',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/015-bell-pepper.png',
      },
      {
        'name': 'Broccoli',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/016-broccoli.png',
      },
      {
        'name': 'Cavolfiore',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/017-cauliflower.png',
      },
      {
        'name': 'Basilico',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/018-basil.png',
      },
      {
        'name': 'Prezzemolo',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/019-parsley.png',
      },
      {
        'name': 'Cetrioli',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/013-cucumber.png',
      },
      {
        'name': 'Funghi',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/020-mushroom.png',
      },
      {
        'name': 'Avocado',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/005-avocado.png',
      },
      {
        'name': 'Finocchio',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/006-fennel.png',
      },
      {
        'name': 'Porri',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/009-leek.png',
      },
      {
        'name': 'Mandorle',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/002-almond.png',
      },
      {
        'name': 'Noci',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/003-walnut.png',
      },
      {
        'name': 'Nocciole',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/004-hazelnut.png',
      },
      {
        'name': 'Arachidi',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/007-peanuts.png',
      },
      {
        'name': 'Uva',
        'department_id': 1,
        'asset_icon': 'assets/icons/products/030-grapes.png',
      },

      // === SALUMERIA E FORMAGGI (id: 2) - 15 prodotti ===
      {
        'name': 'Prosciutto Crudo',
        'department_id': 2,
        'asset_icon': 'assets/icons/products/021-ham.png',
      },
      {
        'name': 'Prosciutto Cotto',
        'department_id': 2,
        'asset_icon': 'assets/icons/products/022-ham-1.png',
      },
      {
        'name': 'Salame',
        'department_id': 2,
        'asset_icon': 'assets/icons/products/023-salami.png',
      },
      {
        'name': 'Mortadella',
        'department_id': 2,
        'asset_icon': 'assets/icons/products/024-sausage.png',
      },
      {
        'name': 'Bresaola',
        'department_id': 2,
        'asset_icon': 'assets/icons/products/025-pepperoni.png',
      },
      {
        'name': 'Speck',
        'department_id': 2,
        'asset_icon': 'assets/icons/products/026-ham-2.png',
      },
      {
        'name': 'Parmigiano Reggiano',
        'department_id': 2,
        'asset_icon': 'assets/icons/products/028-cheese-grater.png',
      },
      {
        'name': 'Gorgonzola',
        'department_id': 2,
        'asset_icon': 'assets/icons/products/027-cheese.png',
      },
      {
        'name': 'Mozzarella',
        'department_id': 2,
        'asset_icon': 'assets/icons/products/029-mozzarella.png',
      },
      {
        'name': 'Ricotta',
        'department_id': 2,
        'asset_icon': 'assets/icons/products/030-ricotta.png',
      },
      {
        'name': 'Stracchino',
        'department_id': 2,
        'asset_icon': 'assets/icons/products/031-cheese-1.png',
      },
      {
        'name': 'Pecorino',
        'department_id': 2,
        'asset_icon': 'assets/icons/products/027-cheese.png',
      }, // riuso cheese
      {
        'name': 'Grana Padano',
        'department_id': 2,
        'asset_icon': 'assets/icons/products/028-cheese-grater.png',
      }, // riuso cheese-grater
      {
        'name': 'Provolone',
        'department_id': 2,
        'asset_icon': 'assets/icons/products/032-mozzarella-1.png',
      },
      {
        'name': 'Taleggio',
        'department_id': 2,
        'asset_icon': 'assets/icons/products/031-cheese-1.png',
      }, // riuso cheese-1
      // === LATTICINI E UOVA (id: 3) - 8 prodotti ===
      {
        'name': 'Latte',
        'department_id': 3,
        'asset_icon': 'assets/icons/products/033-milk.png',
      },
      {
        'name': 'Yogurt',
        'department_id': 3,
        'asset_icon': 'assets/icons/products/035-ice-cream.png',
      }, // riuso ice-cream
      {
        'name': 'Uova',
        'department_id': 3,
        'asset_icon': 'assets/icons/products/036-eggs.png',
      },
      {
        'name': 'Burro',
        'department_id': 3,
        'asset_icon': 'assets/icons/products/037-butter.png',
      },
      {
        'name': 'Panna da Cucina',
        'department_id': 3,
        'asset_icon': 'assets/icons/products/033-milk.png',
      }, // riuso milk
      {
        'name': 'Mascarpone',
        'department_id': 3,
        'asset_icon': 'assets/icons/products/038-mascarpone.png',
      },
      {
        'name': 'Philadelphia',
        'department_id': 3,
        'asset_icon': 'assets/icons/products/030-ricotta.png',
      }, // riuso ricotta
      {
        'name': 'Latte di Mandorla',
        'department_id': 3,
        'asset_icon': 'assets/icons/products/001-almond-milk.png',
      },
      // === CARNE (id: 4) - 10 prodotti ===
      {
        'name': 'Petto di Pollo',
        'department_id': 4,
        'asset_icon': 'assets/icons/products/039-chicken-breast.png',
      },
      {
        'name': 'Cosce di Pollo',
        'department_id': 4,
        'asset_icon': 'assets/icons/products/040-turkey.png',
      }, // riuso turkey
      {
        'name': 'Fesa di Tacchino',
        'department_id': 4,
        'asset_icon': 'assets/icons/products/040-turkey.png',
      },
      {
        'name': 'Carne Macinata',
        'department_id': 4,
        'asset_icon': 'assets/icons/products/008-minced-meat.png',
      },
      {
        'name': 'Bistecca di Manzo',
        'department_id': 4,
        'asset_icon': 'assets/icons/products/041-meat.png',
      },
      {
        'name': 'Scaloppine',
        'department_id': 4,
        'asset_icon': 'assets/icons/products/041-meat.png',
      }, // riuso meat
      {
        'name': 'Salsiccia',
        'department_id': 4,
        'asset_icon': 'assets/icons/products/042-sausage-1.png',
      },
      {
        'name': 'Pancetta',
        'department_id': 4,
        'asset_icon': 'assets/icons/products/025-pepperoni.png',
      }, // riuso pepperoni
      {
        'name': 'Guanciale',
        'department_id': 4,
        'asset_icon': 'assets/icons/products/025-pepperoni.png',
      }, // riuso pepperoni
      {
        'name': 'Costolette',
        'department_id': 4,
        'asset_icon': 'assets/icons/products/043-ribs.png',
      },

      // === PESCE (id: 5) - 9 prodotti ===
      {
        'name': 'Salmone',
        'department_id': 5,
        'asset_icon': 'assets/icons/products/044-salmon.png',
      },
      {
        'name': 'Tonno Fresco',
        'department_id': 5,
        'asset_icon': 'assets/icons/products/045-tuna.png',
      },
      {
        'name': 'Branzino',
        'department_id': 5,
        'asset_icon': 'assets/icons/products/047-largemouth-bass.png',
      },
      {
        'name': 'Orata',
        'department_id': 5,
        'asset_icon': 'assets/icons/products/046-bream.png',
      },
      {
        'name': 'Merluzzo',
        'department_id': 5,
        'asset_icon': 'assets/icons/products/048-cod.png',
      },
      {
        'name': 'Gamberetti',
        'department_id': 5,
        'asset_icon': 'assets/icons/products/049-shrimp.png',
      },
      {
        'name': 'Calamari',
        'department_id': 5,
        'asset_icon': 'assets/icons/products/050-squid.png',
      },
      {
        'name': 'Cozze',
        'department_id': 5,
        'asset_icon': 'assets/icons/products/051-mussel.png',
      },
      {
        'name': 'Vongole',
        'department_id': 5,
        'asset_icon': 'assets/icons/products/052-clam.png',
      },

      // === PANE E PANETTERIA (id: 6) - 8 prodotti ===
      {
        'name': 'Pane Integrale',
        'department_id': 6,
        'asset_icon': 'assets/icons/products/057-whole-grain.png',
      },
      {
        'name': 'Pane Bianco',
        'department_id': 6,
        'asset_icon': 'assets/icons/products/054-bread-1.png',
      },
      {
        'name': 'Pan Carrè',
        'department_id': 6,
        'asset_icon': 'assets/icons/products/053-bread.png',
      },
      {
        'name': 'Focaccia',
        'department_id': 6,
        'asset_icon': 'assets/icons/products/054-bread-1.png',
      }, // riuso bread-1
      {
        'name': 'Grissini',
        'department_id': 6,
        'asset_icon': 'assets/icons/products/055-grissini.png',
      },
      {
        'name': 'Crackers',
        'department_id': 6,
        'asset_icon': 'assets/icons/products/056-biscuit.png',
      },
      {
        'name': 'Fette Biscottate',
        'department_id': 6,
        'asset_icon': 'assets/icons/products/056-biscuit.png',
      }, // riuso biscuit
      // === PASTA, RISO E CEREALI (id: 7) - 5 prodotti ===
      {
        'name': 'Pasta',
        'department_id': 7,
        'asset_icon': 'assets/icons/products/058-pasta.png',
      },
      {
        'name': 'Riso',
        'department_id': 7,
        'asset_icon': 'assets/icons/products/059-rice.png',
      },
      {
        'name': 'Farro',
        'department_id': 7,
        'asset_icon': 'assets/icons/products/088-wheat.png',
      },
      {
        'name': 'Orzo',
        'department_id': 7,
        'asset_icon': 'assets/icons/products/088-wheat.png',
      }, // riuso wheat
      {
        'name': 'Quinoa',
        'department_id': 7,
        'asset_icon': 'assets/icons/products/060-quinoa.png',
      },

      // === CONSERVE E SCATOLAME (id: 8) - 12 prodotti ===
      {
        'name': 'Pelati',
        'department_id': 8,
        'asset_icon': 'assets/icons/products/061-tomato-1.png',
      },
      {
        'name': 'Passata di Pomodoro',
        'department_id': 8,
        'asset_icon': 'assets/icons/products/062-sauce.png',
      },
      {
        'name': 'Tonno in Scatola',
        'department_id': 8,
        'asset_icon': 'assets/icons/products/063-canned-food.png',
      },
      {
        'name': 'Fagioli',
        'department_id': 8,
        'asset_icon': 'assets/icons/products/064-red-beans.png',
      },
      {
        'name': 'Ceci',
        'department_id': 8,
        'asset_icon': 'assets/icons/products/003-chickpea.png',
      },
      {
        'name': 'Lenticchie',
        'department_id': 8,
        'asset_icon': 'assets/icons/products/066-lentils.png',
      },
      {
        'name': 'Mais',
        'department_id': 8,
        'asset_icon': 'assets/icons/products/067-corn.png',
      },
      {
        'name': 'Piselli',
        'department_id': 8,
        'asset_icon': 'assets/icons/products/065-peas.png',
      },
      {
        'name': 'Olive Nere',
        'department_id': 8,
        'asset_icon': 'assets/icons/products/070-olives.png',
      },
      {
        'name': 'Olive Verdi',
        'department_id': 8,
        'asset_icon': 'assets/icons/products/069-olive-tree.png',
      },
      {
        'name': 'Capperi',
        'department_id': 8,
        'asset_icon': 'assets/icons/products/071-capers.png',
      },
      {
        'name': 'Acciughe',
        'department_id': 8,
        'asset_icon': 'assets/icons/products/072-canned-food-1.png',
      },

      // === OLIO, ACETO E CONDIMENTI (id: 9) - 11 prodotti ===
      {
        'name': 'Olio EVO',
        'department_id': 9,
        'asset_icon': 'assets/icons/products/068-olive-oil.png',
      },
      {
        'name': 'Olio di Semi',
        'department_id': 9,
        'asset_icon': 'assets/icons/products/073-sunflower-oil.png',
      },
      {
        'name': 'Aceto Balsamico',
        'department_id': 9,
        'asset_icon': 'assets/icons/products/074-balsamic-vinegar.png',
      },
      {
        'name': 'Aceto di Vino',
        'department_id': 9,
        'asset_icon': 'assets/icons/products/075-apple-cider-vinegar.png',
      },
      {
        'name': 'Sale Fino',
        'department_id': 9,
        'asset_icon': 'assets/icons/products/076-salt.png',
      },
      {
        'name': 'Sale Grosso',
        'department_id': 9,
        'asset_icon': 'assets/icons/products/076-salt.png',
      }, // riuso salt
      {
        'name': 'Latte di Soia',
        'department_id': 9,
        'asset_icon': 'assets/icons/products/034-soy-milk.png',
      },
      {
        'name': 'Pepe Nero',
        'department_id': 9,
        'asset_icon': 'assets/icons/products/077-pepper-grinder.png',
      },
      {
        'name': 'Origano',
        'department_id': 9,
        'asset_icon': 'assets/icons/products/078-oregano.png',
      },
      {
        'name': 'Rosmarino',
        'department_id': 9,
        'asset_icon': 'assets/icons/products/079-rosemary.png',
      },
      {
        'name': 'Peperoncino',
        'department_id': 9,
        'asset_icon': 'assets/icons/products/080-pepper.png',
      },
      {
        'name': 'Cannella',
        'department_id': 9,
        'asset_icon': 'assets/icons/products/081-cinnamon-roll.png',
      },

      // === BISCOTTI E DOLCIUMI (id: 10) - 7 prodotti ===
      {
        'name': 'Biscotti',
        'department_id': 10,
        'asset_icon': 'assets/icons/products/082-cookies.png',
      },
      {
        'name': 'Cioccolata',
        'department_id': 10,
        'asset_icon': 'assets/icons/products/083-chocolate.png',
      },
      {
        'name': 'Nutella',
        'department_id': 10,
        'asset_icon': 'assets/icons/products/084-chocolate-1.png',
      },
      {
        'name': 'Miele',
        'department_id': 10,
        'asset_icon': 'assets/icons/products/085-honey.png',
      },
      {
        'name': 'Merendine',
        'department_id': 10,
        'asset_icon': 'assets/icons/products/086-muffin.png',
      },
      {
        'name': 'Zucchero',
        'department_id': 10,
        'asset_icon': 'assets/icons/products/087-sugar.png',
      },
      {
        'name': 'Farina 00',
        'department_id': 10,
        'asset_icon': 'assets/icons/products/088-wheat.png',
      },

      // === DETERSIVI E PULIZIA (id: 11) - 9 prodotti ===
      {
        'name': 'Detersivo Piatti',
        'department_id': 11,
        'asset_icon': 'assets/icons/products/090-dish-soap.png',
      },
      {
        'name': 'Detersivo Lavatrice',
        'department_id': 11,
        'asset_icon': 'assets/icons/products/092-detergent.png',
      },
      {
        'name': 'Detersivo Lavastoviglie',
        'department_id': 11,
        'asset_icon': 'assets/icons/products/092-detergent.png',
      }, // riuso detergent
      {
        'name': 'Ammorbidente',
        'department_id': 11,
        'asset_icon': 'assets/icons/products/091-hand-sanitizer.png',
      },
      {
        'name': 'Candeggina',
        'department_id': 11,
        'asset_icon': 'assets/icons/products/089-soap.png',
      },
      {
        'name': 'Sgrassatore',
        'department_id': 11,
        'asset_icon': 'assets/icons/products/089-soap.png',
      }, // riuso soap
      {
        'name': 'Spugne',
        'department_id': 11,
        'asset_icon': 'assets/icons/products/093-sponge.png',
      },
      {
        'name': 'Carta Assorbente',
        'department_id': 11,
        'asset_icon': 'assets/icons/products/095-paper-towel.png',
      },
      {
        'name': 'Panno Microfibra',
        'department_id': 11,
        'asset_icon': 'assets/icons/products/096-wring.png',
      },

      // === IGIENE PERSONALE (id: 12) - 9 prodotti ===
      {
        'name': 'Carta Igienica',
        'department_id': 12,
        'asset_icon': 'assets/icons/products/094-paper-roll.png',
      },
      {
        'name': 'Shampoo',
        'department_id': 12,
        'asset_icon': 'assets/icons/products/097-shampoo.png',
      },
      {
        'name': 'Balsamo',
        'department_id': 12,
        'asset_icon': 'assets/icons/products/097-shampoo.png',
      }, // riuso shampoo
      {
        'name': 'Sapone',
        'department_id': 12,
        'asset_icon': 'assets/icons/products/089-soap.png',
      },
      {
        'name': 'Dentifricio',
        'department_id': 12,
        'asset_icon': 'assets/icons/products/098-toothpaste.png',
      },
      {
        'name': 'Spazzolino',
        'department_id': 12,
        'asset_icon': 'assets/icons/products/099-toothbrush.png',
      },
      {
        'name': 'Deodorante',
        'department_id': 12,
        'asset_icon': 'assets/icons/products/100-deodorant.png',
      },
      {
        'name': 'Collutorio',
        'department_id': 12,
        'asset_icon': 'assets/icons/products/098-toothpaste.png',
      }, // riuso toothpaste
      {
        'name': 'Filo Interdentale',
        'department_id': 12,
        'asset_icon': 'assets/icons/products/101-dental-floss.png',
      },

      // === ANIMALI DOMESTICI (id: 14) - 5 prodotti ===
      {
        'name': 'Crocchette',
        'department_id': 14,
        'asset_icon': 'assets/icons/products/102-pet-food.png',
      },
      {
        'name': 'Scatolette',
        'department_id': 14,
        'asset_icon': 'assets/icons/products/102-pet-food.png',
      }, // riuso pet-food
      {
        'name': 'Lettiera',
        'department_id': 14,
        'asset_icon': 'assets/icons/products/103-litter-box.png',
      },
      {
        'name': 'Shampoo Animali',
        'department_id': 14,
        'asset_icon': 'assets/icons/products/097-shampoo.png',
      }, // riuso shampoo
      {
        'name': 'Giocattoli Animali',
        'department_id': 14,
        'asset_icon': 'assets/icons/products/104-mouse-toy.png',
      },

      // === BEVANDE (id: 15) - 8 prodotti ===
      {
        'name': 'Acqua',
        'department_id': 15,
        'asset_icon': 'assets/icons/products/105-mineral-water.png',
      },
      {
        'name': 'Succo di Frutta',
        'department_id': 15,
        'asset_icon': 'assets/icons/products/106-orange-juice.png',
      },
      {
        'name': 'Cola',
        'department_id': 15,
        'asset_icon': 'assets/icons/products/107-soft-drink.png',
      },
      {
        'name': 'Thé Freddo',
        'department_id': 15,
        'asset_icon': 'assets/icons/products/107-soft-drink.png',
      }, // riuso soft-drink
      {
        'name': 'Energy Drink',
        'department_id': 15,
        'asset_icon': 'assets/icons/products/108-energy-drink.png',
      },
      // === VINI E ALCOLICI (id: 16) - 7 prodotti ===
      {
        'name': 'Vino Bianco',
        'department_id': 16,
        'asset_icon': 'assets/icons/products/110-white-wine.png',
      },
      {
        'name': 'Vino Rosso',
        'department_id': 16,
        'asset_icon': 'assets/icons/products/111-wine.png',
      },
      {
        'name': 'Birra',
        'department_id': 16,
        'asset_icon': 'assets/icons/products/112-beer.png',
      },
      {
        'name': 'Gin',
        'department_id': 16,
        'asset_icon': 'assets/icons/products/113-gin-tonic.png',
      },
      {
        'name': 'Rum',
        'department_id': 16,
        'asset_icon': 'assets/icons/products/114-rum.png',
      },
      {
        'name': 'Vodka',
        'department_id': 16,
        'asset_icon': 'assets/icons/products/115-liquor.png',
      },
      {
        'name': 'Whiskey',
        'department_id': 16,
        'asset_icon': 'assets/icons/products/115-liquor.png',
      }, // riuso liquor
      // === SURGELATI (id: 17) - 9 prodotti ===
      {
        'name': 'Piselli Surgelati',
        'department_id': 17,
        'asset_icon': 'assets/icons/products/065-peas.png',
      }, // riuso peas
      {
        'name': 'Pizza Surgelata',
        'department_id': 17,
        'asset_icon': 'assets/icons/products/116-pizza.png',
      },
      {
        'name': 'Gelato',
        'department_id': 17,
        'asset_icon': 'assets/icons/products/035-ice-cream.png',
      },
      {
        'name': 'Merluzzo Surgelato',
        'department_id': 17,
        'asset_icon': 'assets/icons/products/048-cod.png',
      }, // riuso cod
      {
        'name': 'Funghi Surgelati',
        'department_id': 17,
        'asset_icon': 'assets/icons/products/020-mushroom.png',
      }, // riuso mushroom
      {
        'name': 'Verdure Grigliate',
        'department_id': 17,
        'asset_icon': 'assets/icons/products/118-frozen-food.png',
      },
      {
        'name': 'Spinaci Surgelati',
        'department_id': 17,
        'asset_icon': 'assets/icons/products/011-spinach.png',
      }, // riuso spinach
      {
        'name': 'Burger Vegetali',
        'department_id': 17,
        'asset_icon': 'assets/icons/products/118-frozen-food.png',
      }, // riuso frozen-food
      {
        'name': 'Patatine Fritte',
        'department_id': 17,
        'asset_icon': 'assets/icons/products/119-french-fries.png',
      },

      // === NUOVI PRODOTTI PER REPARTI ESISTENTI ===

      // LATTICINI E UOVA (id: 3) - aggiunti 1 prodotto
      {
        'name': 'Pesto',
        'department_id': 3,
        'asset_icon': 'assets/icons/products/001-pesto.png',
      },

      // PASTA, RISO E CEREALI (id: 7) - aggiunti 4 prodotti
      {
        'name': 'Couscous',
        'department_id': 7,
        'asset_icon': 'assets/icons/products/002-couscous.png',
      },
      {
        'name': 'Caffè',
        'department_id': 7,
        'asset_icon': 'assets/icons/products/004-coffee-beans.png',
      },
      {
        'name': 'Té',
        'department_id': 7,
        'asset_icon': 'assets/icons/products/tea-bag.png',
      },
      {
        'name': 'Pasta Sfoglia',
        'department_id': 7,
        'asset_icon': 'assets/icons/products/dough.png',
      },
      {
        'name': 'Soia',
        'department_id': 7,
        'asset_icon': 'assets/icons/products/021-shoyu.png',
      },

      // DETERSIVI E PULIZIA (id: 11) - aggiunti 7 prodotti
      {
        'name': 'Anticalcare',
        'department_id': 11,
        'asset_icon': 'assets/icons/products/005-cleaning-liquid.png',
      },
      {
        'name': 'Anticalcare Lavatrice',
        'department_id': 11,
        'asset_icon': 'assets/icons/products/005-cleaning-liquid.png',
      },
      {
        'name': 'Candeggina Delicata',
        'department_id': 11,
        'asset_icon': 'assets/icons/products/005-cleaning-liquid.png',
      },
      {
        'name': 'Cura Lavastoviglie',
        'department_id': 11,
        'asset_icon': 'assets/icons/products/091-hand-sanitizer.png',
      },
      {
        'name': 'Detersivo Pavimenti',
        'department_id': 11,
        'asset_icon': 'assets/icons/products/092-detergent.png',
      },
      {
        'name': 'Sale Lavastoviglie',
        'department_id': 11,
        'asset_icon':
            'assets/icons/products/076-salt.png', // mantieni salt per il sale
      },
      {
        'name': 'Insetticida',
        'department_id': 11,
        'asset_icon': 'assets/icons/products/006-insecticide.png',
      },

      // IGIENE PERSONALE (id: 12) - aggiunti 7 prodotti
      {
        'name': 'Assorbenti',
        'department_id': 12,
        'asset_icon': 'assets/icons/products/008-sanitary-napkin.png',
      },
      {
        'name': 'Bagnoschiuma',
        'department_id': 12,
        'asset_icon': 'assets/icons/products/097-shampoo.png', // riuso shampoo
      },
      {
        'name': 'Cotone',
        'department_id': 12,
        'asset_icon': 'assets/icons/products/010-cotton.png',
      },
      {
        'name': 'Cotton Fioc',
        'department_id': 12,
        'asset_icon': 'assets/icons/products/009-cotton-bud.png',
      },
      {
        'name': 'Disinfettante',
        'department_id': 12,
        'asset_icon': 'assets/icons/products/012-antiseptic.png',
      },
      {
        'name': 'Rasoio',
        'department_id': 12,
        'asset_icon': 'assets/icons/products/007-razor.png',
      },
      {
        'name': 'Spugna Doccia',
        'department_id': 12,
        'asset_icon': 'assets/icons/products/011-sponge.png',
      },

      // ACCESSORI DA CUCINA (id: 13) - 8 prodotti
      {
        'name': 'Carta Forno',
        'department_id': 13,
        'asset_icon': 'assets/icons/products/013-parchment-paper.png',
      },
      {
        'name': 'Pellicola',
        'department_id': 13,
        'asset_icon': 'assets/icons/products/014-plastic-film.png',
      },
      {
        'name': 'Alluminio',
        'department_id': 13,
        'asset_icon': 'assets/icons/products/015-aluminum.png',
      },
      {
        'name': 'Vaschette Alluminio',
        'department_id': 13,
        'asset_icon': 'assets/icons/products/020-baking-tray.png',
      },
      {
        'name': 'Piatti di Carta',
        'department_id': 13,
        'asset_icon': 'assets/icons/products/016-plates.png',
      },
      {
        'name': 'Posate di Carta',
        'department_id': 13,
        'asset_icon': 'assets/icons/products/017-cutlery.png',
      },
      {
        'name': 'Tovaglioli',
        'department_id': 13,
        'asset_icon': 'assets/icons/products/018-tissue-box.png',
      },
      {
        'name': 'Sacchetti Congelatore',
        'department_id': 13,
        'asset_icon': 'assets/icons/products/019-ziplock.png',
      },

      // CARTOLERIA (id: 18) - 8 prodotti
      {
        'name': 'Penna',
        'department_id': 18,
        'asset_icon': 'assets/icons/products/025-pens.png',
      },
      {
        'name': 'Matite',
        'department_id': 18,
        'asset_icon': 'assets/icons/products/024-pencil.png',
      },
      {
        'name': 'Graffette',
        'department_id': 18,
        'asset_icon': 'assets/icons/products/023-paper-clip.png',
      },
      {
        'name': 'Gomma da Cancellare',
        'department_id': 18,
        'asset_icon': 'assets/icons/products/022-eraser.png',
      },
      {
        'name': 'Nastro Adesivo',
        'department_id': 18,
        'asset_icon': 'assets/icons/products/029-masking-tape.png',
      },
      {
        'name': 'Note Adesive',
        'department_id': 18,
        'asset_icon': 'assets/icons/products/027-sticky-notes.png',
      },
      {
        'name': 'Puntine',
        'department_id': 18,
        'asset_icon': 'assets/icons/products/028-push-pin.png',
      },
      {
        'name': 'Risma di Carta',
        'department_id': 18,
        'asset_icon': 'assets/icons/products/026-paper.png',
      },
    ];

    for (final product in products) {
      // Inserisci il prodotto con il nuovo sistema di icone
      await db.insert('products', {
        'name': product['name'],
        'department_id': product['department_id'],
        'icon_type': 'asset',
        'icon_value': product['asset_icon'],
      });
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
