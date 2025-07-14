import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    DrawerItem(
      icon: Icons.shopping_cart,
      title: 'Lista Corrente',
      index: 0,
    ),
    DrawerItem(
      icon: Icons.store,
      title: 'Gestione Reparti',
      index: 1,
    ),
    DrawerItem(
      icon: Icons.inventory_2,
      title: 'Gestione Prodotti',
      index: 2,
    ),
    DrawerItem(
      icon: Icons.history,
      title: 'Ultime Liste',
      index: -1, // Temporaneamente disabilitato
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
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
                Icon(
                  Icons.shopping_bag,
                  size: 48,
                  color: Colors.white,
                ),
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
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
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
                  onTap: isDisabled 
                      ? null 
                      : () {
                          setState(() {
                            _selectedIndex = item.index;
                          });
                          Navigator.pop(context);
                        },
                  trailing: isDisabled 
                      ? const Text(
                          'Presto',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
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
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
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