// lib/data/models/base_measurement_unit.dart
enum BaseMeasurementUnit {
  piece('piece', 'piece'),
  box('box', 'box'),
  gram('g', 'gram'),
  kilogram('kg', 'kilogram'),
  liter('l', 'liter'),
  meter('m', 'meter');

  const BaseMeasurementUnit(this.backendValue, this.label);

  /// Те, що піде в бек (base_measurement_unit / display_measurement_unit)
  final String backendValue;

  final String label;

  static BaseMeasurementUnit fromBackend(String value) {
    try {
      return BaseMeasurementUnit.values.firstWhere(
        (u) => u.backendValue == value,
      );
    } catch (_) {
      return BaseMeasurementUnit.piece;
    }
  }
}
