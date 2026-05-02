import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class DiscoveryFilters {
  final double minAge;
  final double maxAge;
  final double distance;
  final String gender;
  final bool verifiedOnly;

  const DiscoveryFilters({
    this.minAge = 18,
    this.maxAge = 65,
    this.distance = 10000,
    this.gender = 'Non-binary',
    this.verifiedOnly = true,
  });

  DiscoveryFilters copyWith({
    double? minAge,
    double? maxAge,
    double? distance,
    String? gender,
    bool? verifiedOnly,
  }) {
    return DiscoveryFilters(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      distance: distance ?? this.distance,
      gender: gender ?? this.gender,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
    );
  }
}

class DiscoveryFiltersNotifier extends StateNotifier<DiscoveryFilters> {
  DiscoveryFiltersNotifier() : super(const DiscoveryFilters());

  void setAgeRange(RangeValues range) {
    state = state.copyWith(minAge: range.start, maxAge: range.end);
  }

  void setDistance(double distance) {
    state = state.copyWith(distance: distance);
  }

  void setGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void setVerifiedOnly(bool verifiedOnly) {
    state = state.copyWith(verifiedOnly: verifiedOnly);
  }

  void reset() {
    state = const DiscoveryFilters();
  }
}

final discoveryFiltersProvider =
    StateNotifierProvider<DiscoveryFiltersNotifier, DiscoveryFilters>((ref) {
      return DiscoveryFiltersNotifier();
    });
