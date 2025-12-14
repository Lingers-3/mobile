enum ResourceType {
  tool,
  consumable;

  String get label {
    switch (this) {
      case ResourceType.tool:
        return 'Tool';
      case ResourceType.consumable:
        return 'Consumable';
    }
  }

  String toJson() {
    switch (this) {
      case ResourceType.consumable:
        return 'consumable';
      case ResourceType.tool:
        return 'tool';
    }
  }

  static ResourceType fromJson(String json) {
    switch (json) {
      case 'consumable':
        return ResourceType.consumable;
      case 'tool':
        return ResourceType.tool;
      default:
        return ResourceType.consumable;
    }
  }
}
