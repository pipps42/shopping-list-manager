import 'package:shopping_list_manager/screens/completed_lists_screen.dart';
import 'package:shopping_list_manager/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_manager/widgets/common/app_bar_gradient.dart';
import 'current_list_screen.dart';
import 'departments_management_screen.dart';
import 'products_management_screen.dart';
import 'loyalty_cards_screen.dart';
import 'package:shopping_list_manager/utils/color_palettes.dart';
import 'package:shopping_list_manager/providers/list_type_provider.dart';

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
    const LoyaltyCardsScreen(),
    const CompletedListsScreen(),
  ];

  final List<String> _titles = [
    AppStrings.currentList,
    AppStrings.departmentManagement,
    AppStrings.productManagement,
    AppStrings.loyaltyCards,
    AppStrings.lastLists,
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
      icon: Icons.credit_card,
      title: AppStrings.loyaltyCards,
      index: 3,
    ),
    DrawerItem(icon: Icons.history, title: AppStrings.lastLists, index: 4),
  ];

  void _onTabChanged(int index) {
    // Rimuovi TUTTO il focus
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild!.unfocus();
    }
    FocusScope.of(context).requestFocus(FocusNode());

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
      // AppBar solo per le sezioni che non hanno il proprio AppBar
      appBar: _selectedIndex != 0 && _selectedIndex != 4
          ? AppBarGradient(
              title: _titles[_selectedIndex],
              showDrawer: true,
              onDrawerPressed: () {
                _onDrawerOpened();
                _scaffoldKey.currentState?.openDrawer();
              },
            )
          : null,
      drawer: _buildDrawer(),
      drawerEdgeDragWidth: (MediaQuery.of(context).size.width * 0.2).clamp(
        50.0,
        100.0,
      ),
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
                        AppStrings.appName,
                        style: TextStyle(
                          color: AppColors.textOnPrimary(context),
                          fontSize: AppConstants.fontTitle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppStrings.appSubtitle,
                        style: TextStyle(
                          color: AppColors.textOnPrimary(
                            context,
                          ).withOpacity(0.7),
                          fontSize: AppConstants.fontL,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildListExpansionTile(),
                ..._drawerItems.skip(1).map((item) => _buildDrawerItem(item)),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Text(
              AppConstants.appVersion,
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

  Widget _buildListExpansionTile() {
    final isListSelected = _selectedIndex == 0;

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent, // Rimuove le linee grigie
      ),
      child: ExpansionTile(
        leading: Icon(
          Icons.shopping_cart,
          color: isListSelected ? AppColors.primary : null,
        ),
        title: Text(
          'Liste',
          style: TextStyle(
            color: isListSelected ? AppColors.primary : null,
            fontWeight: isListSelected ? FontWeight.bold : null,
          ),
        ),
        initiallyExpanded: isListSelected,
        children: [
          _buildListTypeItem('weekly', 'Spesa Settimanale'),
          _buildListTypeItem('monthly', 'Spesa Mensile'),
          _buildListTypeItem('occasional', 'Spesa Occasionale'),
        ],
      ),
    );
  }

  Widget _buildListTypeItem(String listType, String title) {
    return Consumer(
      builder: (context, ref, child) {
        final currentListType = ref.watch(currentListTypeProvider);
        final isCurrentType = currentListType == listType;
        final isListScreenSelected = _selectedIndex == 0;
        
        return Padding(
          padding: const EdgeInsets.only(left: AppConstants.paddingL),
          child: ListTile(
            leading: Icon(
              _getListTypeIcon(listType),
              color: isCurrentType && isListScreenSelected ? AppColors.primary : null,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isCurrentType && isListScreenSelected ? AppColors.primary : null,
                fontWeight: isCurrentType && isListScreenSelected ? FontWeight.bold : null,
              ),
            ),
            selected: isCurrentType && isListScreenSelected,
            onTap: () {
              // Cambia il tipo di lista
              ref.read(currentListTypeProvider.notifier).state = listType;
              // Vai alla schermata lista
              _onTabChanged(0);
            },
          ),
        );
      },
    );
  }
  
  IconData _getListTypeIcon(String listType) {
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

  Widget _buildDrawerItem(DrawerItem item) {
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
