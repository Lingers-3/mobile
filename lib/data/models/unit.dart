enum UnitCategory { count, mass, length, volume, area }

class Unit {
  final String backendValue;
  final String label;
  final UnitCategory category;
  final double toBaseFactor;

  const Unit({
    required this.backendValue,
    required this.label,
    required this.category,
    required this.toBaseFactor,
  });
}

const allUnits = [
  // COUNT
  Unit(
    backendValue: "pcs",
    label: "Piece",
    category: UnitCategory.count,
    toBaseFactor: 1,
  ),
  // MASS
  Unit(
    backendValue: "mg",
    label: "mg",
    category: UnitCategory.mass,
    toBaseFactor: 0.001,
  ),
  Unit(
    backendValue: "g",
    label: "g",
    category: UnitCategory.mass,
    toBaseFactor: 1,
  ),
  Unit(
    backendValue: "kg",
    label: "kg",
    category: UnitCategory.mass,
    toBaseFactor: 1000,
  ),

  // LENGTH
  Unit(
    backendValue: "mm",
    label: "mm",
    category: UnitCategory.length,
    toBaseFactor: 1,
  ),
  Unit(
    backendValue: "cm",
    label: "cm",
    category: UnitCategory.length,
    toBaseFactor: 10,
  ),
  Unit(
    backendValue: "m",
    label: "m",
    category: UnitCategory.length,
    toBaseFactor: 1000,
  ),

  // AREA
  Unit(
    backendValue: "mm2",
    label: "mm²",
    category: UnitCategory.area,
    toBaseFactor: 1,
  ),
  Unit(
    backendValue: "cm2",
    label: "cm²",
    category: UnitCategory.area,
    toBaseFactor: 100,
  ),
  Unit(
    backendValue: "m2",
    label: "m²",
    category: UnitCategory.area,
    toBaseFactor: 1_000_000,
  ),

  // VOLUME
  Unit(
    backendValue: "ml",
    label: "ml",
    category: UnitCategory.volume,
    toBaseFactor: 1,
  ),
  Unit(
    backendValue: "l",
    label: "l",
    category: UnitCategory.volume,
    toBaseFactor: 1000,
  ),
];

Unit findUnit(String backendValue) => allUnits.firstWhere(
  (u) => u.backendValue == backendValue,
  orElse: () => Unit(
    backendValue: backendValue,
    label: backendValue,
    category: UnitCategory.count,
    toBaseFactor: 1,
  ),
);

List<Unit> unitsOfCategory(UnitCategory cat) =>
    allUnits.where((u) => u.category == cat).toList();

double convert(double value, Unit from, Unit to) {
  return value * (from.toBaseFactor / to.toBaseFactor);
}
