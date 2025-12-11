import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:pocketeer_mobile/data/models/resource_reservations/resource_reservation.dart';
import 'package:pocketeer_mobile/data/models/resource_reservations/resource_reservation_create_request.dart';
import 'package:pocketeer_mobile/data/models/resource_reservations/resource_reservation_update_request.dart';

class ResourceReservationService {
  // TODO: use real implementation when backend is ready
  static const Duration _simulatedLatency = Duration(milliseconds: 800);
  static final List<ResourceReservation> _mockData = [
    ResourceReservation(
      id: 1,
      itemId: 101,
      reservedQuantity: 50.0,
      usedQuantity: 10.0,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ResourceReservation(
      id: 2,
      itemId: 102,
      reservedQuantity: 12.5,
      usedQuantity: 12.5,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
  ];

  Future<List<ResourceReservation>> getAllReservations() async {
    await Future.delayed(_simulatedLatency);

    if (kDebugMode) {
      print('📥 (Mock) Fetched ${_mockData.length} reservations');
    }

    return _mockData.where((e) => e.deletedAt == null).toList();
  }

  Future<ResourceReservation> getReservation(int id) async {
    await Future.delayed(_simulatedLatency);

    try {
      final reservation = _mockData.firstWhere(
        (e) => e.id == id && e.deletedAt == null,
      );
      return reservation;
    } catch (e) {
      throw Exception('Reservation not found');
    }
  }

  Future<ResourceReservation> createReservation(
    ResourceReservationCreateRequest request,
  ) async {
    await Future.delayed(_simulatedLatency);

    final newId = _mockData.isNotEmpty
        ? _mockData.map((e) => e.id).reduce(max) + 1
        : 1;
    final now = DateTime.now();

    final newReservation = ResourceReservation(
      id: newId,
      itemId: request.itemId,
      reservedQuantity: request.reservedQuantity,
      usedQuantity: 0,
      createdAt: now,
      updatedAt: now,
    );

    _mockData.add(newReservation);

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
    await Future.delayed(_simulatedLatency);

    final index = _mockData.indexWhere(
      (e) => e.id == id && e.deletedAt == null,
    );
    if (index == -1) {
      throw Exception('Reservation not found');
    }

    final oldItem = _mockData[index];
    final updatedItem = ResourceReservation(
      id: oldItem.id,
      itemId: oldItem.itemId,
      reservedQuantity: request.reservedQuantity ?? oldItem.reservedQuantity,
      usedQuantity: request.usedQuantity ?? oldItem.usedQuantity,
      createdAt: oldItem.createdAt,
      updatedAt: DateTime.now(),
    );

    _mockData[index] = updatedItem;

    if (kDebugMode) {
      print(
        '✅ (Mock) Reservation updated: ${jsonEncode(updatedItem.toJson())}',
      );
    }

    return updatedItem;
  }

  Future<void> deleteReservation(int id) async {
    await Future.delayed(_simulatedLatency);

    final index = _mockData.indexWhere((e) => e.id == id);
    if (index == -1) {
      throw Exception('Reservation not found');
    }

    final oldItem = _mockData[index];
    _mockData[index] = ResourceReservation(
      id: oldItem.id,
      itemId: oldItem.itemId,
      reservedQuantity: oldItem.reservedQuantity,
      usedQuantity: oldItem.usedQuantity,
      createdAt: oldItem.createdAt,
      updatedAt: oldItem.updatedAt,
      deletedAt: DateTime.now(),
    );

    if (kDebugMode) {
      print('🗑️ (Mock) Reservation deleted (soft): ID $id');
    }
  }
}
