import 'package:shopping_list_manager/utils/constants.dart';

class Validators {
  static String? validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.productNameRequired;
    }
    if (value.trim().length < AppConstants.productNameMinLength) {
      return 'Il nome deve essere di almeno  {AppConstants.productNameMinLength} caratteri';
    }
    if (value.trim().length > AppConstants.productNameMaxLength) {
      return 'Il nome non può superare i  {AppConstants.productNameMaxLength} caratteri';
    }
    return null;
  }

  static String? validateDepartmentName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.departmentNameRequired;
    }
    if (value.trim().length < AppConstants.departmentNameMinLength) {
      return 'Il nome deve essere di almeno  {AppConstants.departmentNameMinLength} caratteri';
    }
    if (value.trim().length > AppConstants.departmentNameMaxLength) {
      return 'Il nome non può superare i  {AppConstants.departmentNameMaxLength} caratteri';
    }
    return null;
  }
}
