enum FilamentSortMode {
  material,
  remainingWeight,
  name,
}

extension FilamentSortModeExtension on FilamentSortMode {
  String get storageValue {
    switch (this) {
      case FilamentSortMode.material:
        return 'material';

      case FilamentSortMode.remainingWeight:
        return 'remainingWeight';

      case FilamentSortMode.name:
        return 'name';
    }
  }
}

FilamentSortMode filamentSortModeFromStorageValue(String? value) {
  switch (value) {
    case 'remainingWeight':
    case 'Restgewicht':
      return FilamentSortMode.remainingWeight;

    case 'name':
    case 'Name':
      return FilamentSortMode.name;

    case 'material':
    case 'Material':
    default:
      return FilamentSortMode.material;
  }
}