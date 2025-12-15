enum ResourceType {
  tool,
  consumable;

  String get label {
    switch (this) {
      case ResourceType.consumable:
        return 'Consumable';
      case ResourceType.tool:
        return 'Instrument';
    }
  }

  String toJson() {
    switch (this) {
      case ResourceType.consumable:
        return 'Consumable';
      case ResourceType.tool:
        return 'Instrument';
    }
  }

  static ResourceType fromJson(String json) {
    switch (json) {
      case 'Consumable':
        return ResourceType.consumable;
      case 'Instrument':
        return ResourceType.tool;
      default:
        return ResourceType.consumable;
    }
  }
}
