class AppStrings {
  // App Header
  static const String appHeaderCategory = 'GESTIÓN DE';
  static const String appHeaderTitle = 'Servicios Básicos';
  static const String appHeaderSubtitle = 'División de gastos compartidos';

  // Home Screen
  static const String addBillButton = 'Agregar factura';
  static const String addBillTitle = 'Nueva factura';
  static const String editBillTitle = 'Editar factura';
  static const String noBillsFound = 'No hay facturas registradas.';
  static const String noFilteredBillsFound =
      'No hay facturas que coincidan con los filtros.';
  static const String filterAll = 'Todos';
  static const String filterPending = 'Pendientes';
  static const String filterPaid = 'Pagados';
  static const String clearFilters = 'Limpiar';

  // Dialogs & Actions
  static const String deleteBillTitle = 'Eliminar factura';
  static const String deleteBillConfirmMessage =
      '¿Estás seguro de que deseas eliminar este servicio de la lista?';
  static const String cancel = 'Cancelar';
  static const String delete = 'Eliminar';
  static const String save = 'Guardar';
  static const String shareSummary = 'Compartir resumen';
  static const String summaryCopied = '¡Resumen copiado al portapapeles!';

  // Form Labels
  static const String labelService = 'SERVICIO';
  static const String labelMonth = 'MES';
  static const String labelTotalAmount = 'TOTAL DE LA FACTURA (BS)';
  static const String labelOwnerAmount = 'LO QUE PAGO YO (BS)';
  static const String labelNeighbors = 'VECINOS / INQUILINOS';
  static const String addNeighborButton = 'Agregar Vecino';

  // Hints
  static const String hintTotalAmount = 'Ej: 533';
  static const String hintOwnerAmount = 'Ej: 200';
  static const String hintNeighborName = 'Nombre (ej: Vecina)';
  static const String suffixBs = 'Bs';

  // Validation Messages
  static const String valRequired = 'Requerido';
  static const String valInvalidAmount = 'Monto inválido';
  static const String valAmountTooHigh = 'No puede ser mayor al total';
  static const String valInvalid = 'Inválido';
}
