class Validators {
  static String? validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Il nome del prodotto è obbligatorio';
    }
    if (value.trim().length < 2) {
      return 'Il nome deve essere di almeno 2 caratteri';
    }
    if (value.trim().length > 50) {
      return 'Il nome non può superare i 50 caratteri';
    }
    return null;
  }
  
  static String? validateDepartmentName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Il nome del reparto è obbligatorio';
    }
    if (value.trim().length < 3) {
      return 'Il nome deve essere di almeno 3 caratteri';
    }
    if (value.trim().length > 30) {
      return 'Il nome non può superare i 30 caratteri';
    }
    return null;
  }
}
