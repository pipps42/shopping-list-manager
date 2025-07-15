import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/current_list_provider.dart';
import 'current_list_screen.dart';
import 'departments_management_screen.dart';
import 'products_management_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const CurrentListScreen(),
    const DepartmentsManagementScreen(),
    const ProductsManagementScreen(),
  ];

  final List<String> _titles = [
    'Lista Corrente',
    'Gestione Reparti',
    'Gestione Prodotti',
  ];

  final List<DrawerItem> _drawerItems = [
    DrawerItem(icon: Icons.shopping_cart, title: 'Lista Corrente', index: 0),
    DrawerItem(icon: Icons.store, title: 'Gestione Reparti', index: 1),
    DrawerItem(icon: Icons.inventory_2, title: 'Gestione Prodotti', index: 2),
    DrawerItem(
      icon: Icons.history,
      title: 'Ultime Liste',
      index: -1, // Temporaneamente disabilitato
    ),
  ];

  void _onTabChanged(int index) {
    // Rimuovi TUTTO il focus
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild!.unfocus();
    }
    FocusScope.of(
      context,
    ).requestFocus(FocusNode()); // Forza focus su nodo vuoto
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  void _onDrawerOpened() {
    // Rimuovi focus quando apro drawer
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild!.unfocus();
    }
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => {
              _onDrawerOpened(),
              Scaffold.of(context).openDrawer(),
            },
          ),
        ),
        actions:
            _selectedIndex ==
                0 // MENU SOLO PER CURRENT LIST
            ? [
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'clear_all',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Svuota lista',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    // 🔥 SPAZIO PER FUTURE OPZIONI
                    // const PopupMenuItem(
                    //   value: 'export_list',
                    //   child: Row(
                    //     children: [
                    //       Icon(Icons.share),
                    //       SizedBox(width: 8),
                    //       Text('Condividi lista'),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ]
            : null, // Nessun menu per altri screen
      ),
      drawer: _buildDrawer(),
      body: GestureDetector(
        // Wrapper per catturare tap fuori
        onTap: () {
          final currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.focusedChild!.unfocus();
          }
        },
        child: IndexedStack(index: _selectedIndex, children: _screens),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.shopping_bag, size: 48, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lista Spesa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Esselunga',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _drawerItems.length,
              itemBuilder: (context, index) {
                final item = _drawerItems[index];
                final isSelected = _selectedIndex == item.index;
                final isDisabled = item.index == -1;

                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: isDisabled
                        ? Colors.grey
                        : isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: isDisabled
                          ? Colors.grey
                          : isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  ),
                  selected: isSelected,
                  enabled: !isDisabled,
                  onTap: isDisabled ? null : () => _onTabChanged(item.index),
                  trailing: isDisabled
                      ? const Text(
                          'Presto',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      : null,
                );
              },
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'v1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear_all':
        _showClearAllDialog();
        break;
      // 🔥 FUTURE ACTIONS
      // case 'export_list':
      //   _exportCurrentList();
      //   break;
      // case 'complete_list':
      //   _completeCurrentList();
      //   break;
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Svuota Lista'),
        content: const Text(
          'Sei sicuro di voler rimuovere tutti i prodotti dalla lista corrente?\n\nQuesta azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearCurrentList();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Svuota Lista'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCurrentList() async {
    try {
      // Ottieni il ref da un ConsumerState
      final container = ProviderScope.containerOf(context);
      await container.read(currentListProvider.notifier).clearAllItems();

      // Mostra conferma
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lista svuotata con successo'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class DrawerItem {
  final IconData icon;
  final String title;
  final int index;

  const DrawerItem({
    required this.icon,
    required this.title,
    required this.index,
  });
}
