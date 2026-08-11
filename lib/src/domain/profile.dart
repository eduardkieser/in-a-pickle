class Profile {
  static const int maxBioLength = 120;

  final String name;
  final String? address;
  final String? bio;

  Profile({required String name, this.address, this.bio}) : name = name.trim();

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
      };

  factory Profile.fromJson(Map<String, Object?> json) {
    return Profile(
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      bio: json['bio'] as String?,
    );
  }
}