enum ServiceType {
  water,
  electricity,
  gas,
  internet;

  String get displayName {
    switch (this) {
      case ServiceType.water:
        return 'Agua';
      case ServiceType.electricity:
        return 'Luz';
      case ServiceType.gas:
        return 'Gas';
      case ServiceType.internet:
        return 'Internet';
    }
  }
}
