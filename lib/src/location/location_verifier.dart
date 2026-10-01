import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/profile.dart';

class LocationCheck {
  const LocationCheck({
    required this.actual,
    required this.distanceFromPinMetres,
    required this.isCloseEnough,
  });

  final GeoPoint actual;
  final int distanceFromPinMetres;
  final bool isCloseEnough;
}

abstract class LocationVerifier {
  Future<LocationCheck> checkAtHome(GeoPoint claimedHome);
}

/// Deterministic implementation for the local prototype and screenshot suite.
/// A production implementation can use device GPS without changing the flow.
class PrototypeLocationVerifier implements LocationVerifier {
  @override
  Future<LocationCheck> checkAtHome(GeoPoint claimedHome) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return LocationCheck(
      actual: GeoPoint(
        claimedHome.latitude + 0.00008,
        claimedHome.longitude - 0.00006,
      ),
      distanceFromPinMetres: 11,
      isCloseEnough: true,
    );
  }
}

final locationVerifierProvider = Provider<LocationVerifier>(
  (ref) => PrototypeLocationVerifier(),
);
