import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:pocketeer_mobile/data/models/resource_reservations/resource_reservation.dart';
import 'package:pocketeer_mobile/data/models/resource_reservations/resource_reservation_create_request.dart';
import 'package:pocketeer_mobile/data/models/resource_reservations/resource_reservation_update_request.dart';

class ResourceReservationMock {
  static final latency = Duration(milliseconds: 800);

  static final reservations = [
    ResourceReservation(
      id: 1,
      resourceSpecificationId: 1,
      itemId: 101,
      reservedQuantity: 50.0,
      usedQuantity: 10.0,
    ),
    ResourceReservation(
      id: 2,
      resourceSpecificationId: 1,
      itemId: 102,
      reservedQuantity: 12.5,
      usedQuantity: 12.5,
    ),
  ];
}

class ResourceReservationService {
  // TODO: use real implementation when backend is ready

  Future<List<ResourceReservation>> getAllReservations() async {
    await Future.delayed(ResourceReservationMock.latency);

    if (kDebugMode) {
      print(
        '📥 (Mock) Fetched ${ResourceReservationMock.reservations.length} reservations',
      );
    }

    return ResourceReservationMock.reservations;
  }

  Future<ResourceReservation> getReservation(int id) async {
    await Future.delayed(ResourceReservationMock.latency);

    try {
      final reservation = ResourceReservationMock.reservations.firstWhere(
        (e) => e.id == id,
      );
      return reservation;
    } catch (e) {
      throw Exception('Reservation not found');
    }
  }

  Future<ResourceReservation> createReservation(
    ResourceReservationCreateRequest request,
  ) async {
    await Future.delayed(ResourceReservationMock.latency);

    final newId = ResourceReservationMock.reservations.isNotEmpty
        ? ResourceReservationMock.reservations.map((e) => e.id).reduce(max) + 1
        : 1;

    final newReservation = ResourceReservation(
      id: newId,
      resourceSpecificationId: request.resourceSpecificationId,
      itemId: request.itemId,
      reservedQuantity: request.reservedQuantity,
      usedQuantity: 0,
    );

    ResourceReservationMock.reservations.add(newReservation);

    if (kDebugMode) {
      print(
        '✅ (Mock) Reservation created: ${jsonEncode(newReservation.toJson())}',
      );
    }

    return newReservation;
  }

  Future<ResourceReservation> updateReservation(
    int id,
    ResourceReservationUpdateRequest request,
  ) async {
    await Future.delayed(ResourceReservationMock.latency);

    final index = ResourceReservationMock.reservations.indexWhere(
      (e) => e.id == id,
    );
    if (index == -1) {
      throw Exception('Reservation not found');
    }

    final oldItem = ResourceReservationMock.reservations[index];
    final updatedItem = ResourceReservation(
      id: oldItem.id,
      resourceSpecificationId: oldItem.resourceSpecificationId,
      itemId: oldItem.itemId,
      reservedQuantity: request.reservedQuantity ?? oldItem.reservedQuantity,
      usedQuantity: request.usedQuantity ?? oldItem.usedQuantity,
    );

    ResourceReservationMock.reservations[index] = updatedItem;

    if (kDebugMode) {
      print(
        '✅ (Mock) Reservation updated: ${jsonEncode(updatedItem.toJson())}',
      );
    }

    return updatedItem;
  }

  Future<void> deleteReservation(int id) async {
    await Future.delayed(ResourceReservationMock.latency);

    final index = ResourceReservationMock.reservations.indexWhere(
      (e) => e.id == id,
    );
    if (index == -1) {
      throw Exception('Reservation not found');
    }

    ResourceReservationMock.reservations.removeWhere((r) => r.id == id);

    if (kDebugMode) {
      print('🗑️ (Mock) Reservation deleted: ID $id');
    }
  }
}
