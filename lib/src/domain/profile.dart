enum AddressVerificationStatus { unverified, verifiedAtHome, captainPending }

enum MatchingLocation { home, live }

class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  Map<String, Object?> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  factory GeoPoint.fromJson(Map<String, Object?> json) => GeoPoint(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      );
}

class Profile {
  static const int maxBioLength = 120;

  final String name;
  final String? address;
  final String? bio;
  final Set<String> capabilityIds;
  final GeoPoint? homeLocation;
  final AddressVerificationStatus verificationStatus;
  final MatchingLocation matchingLocation;
  final bool onboardingComplete;

  Profile({
    required String name,
    this.address,
    this.bio,
    this.capabilityIds = const {},
    this.homeLocation,
    this.verificationStatus = AddressVerificationStatus.unverified,
    this.matchingLocation = MatchingLocation.home,
    this.onboardingComplete = false,
  }) : name = name.trim();

  bool get isVerified =>
      verificationStatus == AddressVerificationStatus.verifiedAtHome;

  bool get isQuiet => !isVerified;

  String get validationError {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'Please tell us your name.';
    }
    final body = bio ?? '';
    if (body.length > maxBioLength) {
      return 'Keep your bio under $maxBioLength characters.';
    }
    return '';
  }

  bool get isValid => validationError.isEmpty;

  Map<String, Object?> toJson() => {
        'name': name,
        'address': address,
        'bio': bio,
        'capabilityIds': capabilityIds.toList(),
        'homeLocation': homeLocation?.toJson(),
        'verificationStatus': verificationStatus.name,
        'matchingLocation': matchingLocation.name,
        'onboardingComplete': onboardingComplete,
      };

  factory Profile.fromJson(Map<String, Object?> json) {
    final name = json['name'] as String? ?? '';
    final rawLocation = json['homeLocation'];
    final rawCapabilities = json['capabilityIds'] as List<Object?>? ?? const [];
    return Profile(
      name: name,
      address: json['address'] as String?,
      bio: json['bio'] as String?,
      capabilityIds: rawCapabilities.whereType<String>().toSet(),
      homeLocation: rawLocation is Map<String, Object?>
          ? GeoPoint.fromJson(rawLocation)
          : null,
      verificationStatus: AddressVerificationStatus.values
              .asNameMap()[json['verificationStatus'] as String?] ??
          AddressVerificationStatus.unverified,
      matchingLocation: MatchingLocation.values
              .asNameMap()[json['matchingLocation'] as String?] ??
          MatchingLocation.home,
      // Profiles from the first prototype predate onboarding. Keep those users
      // out of a surprise registration loop after upgrading.
      onboardingComplete:
          json['onboardingComplete'] as bool? ?? name.trim().isNotEmpty,
    );
  }
}
