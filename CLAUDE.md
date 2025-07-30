# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter shopping list app organized by departments (Italian grocery store sections), using Riverpod for state management and SQLite for data persistence. The app allows users to create and manage shopping lists organized by store departments like "Frutta e Verdura", "Salumeria e Formaggi", etc.

## Development Commands

### Flutter Commands
- `flutter run` - Run the app in development mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter test` - Run unit tests
- `flutter analyze` - Analyze code for issues and warnings
- `flutter pub get` - Install dependencies
- `flutter clean` - Clean build cache

### Testing
- `flutter test` - Run widget tests (test/widget_test.dart)
- `flutter test integration_test/` - Run integration tests

## Architecture

### State Management
Uses **Riverpod** pattern with providers in `lib/providers/`:
- `databaseServiceProvider` - Database service instance
- `currentListProvider` - Current shopping list state
- `departmentsProvider` - Departments management
- `productsProvider` - Products management  
- `completedListsProvider` - Completed lists history
- `loyaltyCardsProvider` - Loyalty cards management
- `imageProvider` - Image handling utilities

### Database Layer
**SQLite** with custom service at `lib/services/database_service.dart`:
- Singleton pattern with `DatabaseService._instance`
- Tables: departments, products, shopping_lists, list_items, loyalty_cards
- Pre-populated with Italian grocery departments (Esselunga layout)
- Complex JOIN queries for grouped data retrieval

### UI Architecture  
**Screen → Provider → Service** pattern:
- `lib/screens/` - Main UI screens
- `lib/widgets/` - Reusable components organized by feature:
  - `common/` - Shared widgets (LoadingWidget, ErrorStateWidget, EmptyStateWidget)
  - `current_list/` - Current list specific widgets
  - `departments_management/` - Department management widgets
  - Feature-specific widget folders

### Models
- `Department` - Store departments with order_index for custom sorting
- `Product` - Products linked to departments
- `ShoppingList` - Shopping lists with completion tracking
- `ListItem` - Individual items in lists with checked status
- `DepartmentWithProducts` - Grouped data for UI display
- `LoyaltyCard` - Store loyalty cards with images

## Key Implementation Details

### Department Ordering
Departments have an `order_index` field matching typical Italian grocery store layout. The `reorderDepartments()` method updates all department orders in a transaction.

### List Completion Flow
When completing a list:
1. Mark current list as completed with timestamp
2. Optionally mark all items as checked or remove unchecked items
3. Create new empty "Lista Corrente" automatically
4. Transaction ensures data consistency

### Image Handling
Uses `image_picker` package with custom provider. Images are cached with `cacheWidth: 100, cacheHeight: 100` for performance.

### Performance Considerations
- Providers use `autoDispose` for memory management
- Database queries use proper indexing and JOIN operations
- `FutureBuilder` performance issue exists in `AddProductDialog` (see HANDOFF.md line 74-102)

## Current State

The app is 60% through a major refactoring:
- ✅ Common widgets extracted (LoadingWidget, ErrorStateWidget, EmptyStateWidget)
- ✅ CurrentListScreen refactored from 300 to 80 lines
- ⚠️ Performance issue in AddProductDialog needs fixing
- 🔄 ProductsManagementScreen still needs refactoring (~200 lines)

## Common Issues & Solutions

### Warning Fixes Applied
- Replaced `ref.refresh()` with `ref.invalidate()` to eliminate `unused_result` warnings
- Added `cacheWidth/cacheHeight` to all `Image.file()` calls
- Added missing `dart:io` imports

### Development Workflow
1. Always run `flutter analyze` before committing
2. Test on both Android and iOS when possible
3. Use proper Riverpod invalidation instead of refresh
4. Follow existing widget extraction patterns for large screens

## File Organization

```
lib/
├── models/          # Data models
├── providers/       # Riverpod providers
├── screens/         # Main app screens  
├── services/        # Business logic (DatabaseService)
├── utils/           # Utilities (constants, validators, helpers)
└── widgets/         # Reusable UI components
    ├── common/      # Shared widgets
    └── [feature]/   # Feature-specific widgets
```