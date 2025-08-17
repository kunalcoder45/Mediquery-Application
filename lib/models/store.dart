// lib/models/store.dart
import 'package:flutter/material.dart';

class Store {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String category;
  final double lat;
  final double lon;
  final double distance;
  final String openingHours;

  Store({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.category,
    required this.lat,
    required this.lon,
    required this.distance,
    required this.openingHours,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      name: json['name'] ?? 'Unknown Store',
      phone: json['phone'] ?? 'Not available',
      address: json['address'] ?? 'Address not available',
      category: json['category'] ?? 'Pharmacy',
      lat: (json['coordinates']?['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['coordinates']?['lon'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      openingHours: json['opening_hours'] ?? 'Not available',
    );
  }
}