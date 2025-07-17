// lib/screens/main_screen.dart (AGGIORNATO)
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/current_list_provider.dart';
import 'current_list_screen.dart';
import 'departments_management_screen.dart';
import 'products_management_screen.dart';
import 'loyalty_cards_screen.dart'; // ← NUOVO IMPORT
import 'package:shopping_list_manager/utils/color_palettes.dart';

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
    const LoyaltyCardsScreen(), // ← NUOVO SCREEN
  ];

  final List<String> _titles = [
    AppStrings.currentList,
    AppStrings.departmentManagement,
    AppStrings.productManagement,
    'Carte Fedeltà', // ← NUOVO TITOLO
  ];

  final List<DrawerItem> _drawerItems = [
    DrawerItem(
      icon: Icons.shopping_cart,
      title: AppStrings.currentList,
      index: 0,
    ),
    DrawerItem(
      icon: Icons.store,
      title: AppStrings.departmentManagement,
      index: 1,
    ),
    DrawerItem(
      icon: Icons.inventory_2,
      title: AppStrings.productManagement,
      index: 2,
    ),
    DrawerItem(
      icon: Icons.credit_card, // ← NUOVA SEZIONE
      title: 'Carte Fedeltà',
      index: 3,
    ),
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: AppColors.textOnPrimary(context),
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
                          Icon(Icons.clear_all, color: AppColors.error),
                          SizedBox(width: AppConstants.spacingS),
                          Text(
                            AppStrings.clearList,
                            style: TextStyle(color: AppColors.error),
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
                    //       SizedBox(width: AppConstants.spacingS),
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
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag,
                  size: AppConstants.iconXL,
                  color: AppColors.textOnPrimary(context),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lista Spesa',
                        style: TextStyle(
                          color: AppColors.textOnPrimary(context),
                          fontSize: AppConstants.fontTitle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Assistente alla spesa',
                        style: TextStyle(
                          color: AppColors.textOnPrimary(
                            context,
                          ).withOpacity(0.7),
                          fontSize: AppConstants.fontXL,
                        ),
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
                        ? AppColors.textDisabled(context)
                        : isSelected
                        ? AppColors.primary
                        : null,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: isDisabled
                          ? AppColors.textDisabled(context)
                          : isSelected
                          ? AppColors.primary
                          : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  ),
                  selected: isSelected,
                  enabled: !isDisabled,
                  onTap: isDisabled ? null : () => _onTabChanged(item.index),
                  trailing: isDisabled
                      ? Text(
                          'Presto',
                          style: TextStyle(
                            fontSize: AppConstants.fontM,
                            color: AppColors.textDisabled(context),
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Text(
              'v1.0.0',
              style: TextStyle(
                color: AppColors.textDisabled(context),
                fontSize: AppConstants.fontM,
              ),
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
        title: Text(AppStrings.clearList),
        content: const Text(
          'Sei sicuro di voler rimuovere tutti i prodotti dalla lista corrente?\n\nQuesta azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearCurrentList();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary(context),
            ),
            child: Text(AppStrings.clearList),
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
          SnackBar(
            content: Text(AppStrings.listCleared),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: $e'),
            backgroundColor: AppColors.error,
          ),
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


/* import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/current_list_provider.dart';
import 'current_list_screen.dart';
import 'departments_management_screen.dart';
import 'products_management_screen.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';

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
    AppStrings.currentList,
    AppStrings.departmentManagement,
    AppStrings.productManagement,
  ];

  final List<DrawerItem> _drawerItems = [
    DrawerItem(
      icon: Icons.shopping_cart,
      title: AppStrings.currentList,
      index: 0,
    ),
    DrawerItem(
      icon: Icons.store,
      title: AppStrings.departmentManagement,
      index: 1,
    ),
    DrawerItem(
      icon: Icons.inventory_2,
      title: AppStrings.productManagement,
      index: 2,
    ),
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: AppColors.textOnPrimary(context),
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
                          Icon(Icons.clear_all, color: AppColors.error),
                          SizedBox(width: AppConstants.spacingS),
                          Text(
                            AppStrings.clearList,
                            style: TextStyle(color: AppColors.error),
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
                    //       SizedBox(width: AppConstants.spacingS),
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
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag,
                  size: AppConstants.iconXL,
                  color: AppColors.textOnPrimary(context),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lista Spesa',
                        style: TextStyle(
                          color: AppColors.textOnPrimary(context),
                          fontSize: AppConstants.fontTitle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Assistente alla spesa',
                        style: TextStyle(
                          color: AppColors.textOnPrimary(
                            context,
                          ).withOpacity(0.7),
                          fontSize: AppConstants.fontXL,
                        ),
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
                        ? AppColors.textDisabled(context)
                        : isSelected
                        ? AppColors.primary
                        : null,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: isDisabled
                          ? AppColors.textDisabled(context)
                          : isSelected
                          ? AppColors.primary
                          : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  ),
                  selected: isSelected,
                  enabled: !isDisabled,
                  onTap: isDisabled ? null : () => _onTabChanged(item.index),
                  trailing: isDisabled
                      ? Text(
                          'Presto',
                          style: TextStyle(
                            fontSize: AppConstants.fontM,
                            color: AppColors.textDisabled(context),
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Text(
              'v1.0.0',
              style: TextStyle(
                color: AppColors.textDisabled(context),
                fontSize: AppConstants.fontM,
              ),
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
        title: Text(AppStrings.clearList),
        content: const Text(
          'Sei sicuro di voler rimuovere tutti i prodotti dalla lista corrente?\n\nQuesta azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearCurrentList();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary(context),
            ),
            child: Text(AppStrings.clearList),
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
          SnackBar(
            content: Text(AppStrings.listCleared),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: $e'),
            backgroundColor: AppColors.error,
          ),
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
 */