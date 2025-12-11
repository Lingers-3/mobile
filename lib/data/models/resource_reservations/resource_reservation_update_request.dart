class ResourceReservationUpdateRequest {
  final double? reservedQuantity;
  final double? usedQuantity;

  ResourceReservationUpdateRequest({this.reservedQuantity, this.usedQuantity});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (reservedQuantity != null) {
      data['reserved_quantity'] = reservedQuantity;
    }
    if (usedQuantity != null) {
      data['used_quantity'] = usedQuantity;
    }
    return data;
  }
}
