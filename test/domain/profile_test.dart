import 'package:flutter_test/flutter_test.dart';
import 'package:in_a_pickle/src/domain/profile.dart';

void main() {
  group('Profile validation', () {
    test('a blank name is invalid', () {
      final profile = Profile(name: '   ');
      expect(profile.isValid, isFalse);
      expect(profile.validationError, contains('name'));
    });

    test('an empty name is invalid', () {
      final profile = Profile(name: '');
      expect(profile.isValid, isFalse);
    });

    test('a name that is only whitespace is trimmed to blank', () {
      final profile = Profile(name: '   ');
      expect(profile.name.trim(), isEmpty);
    });

    test('a plain name is valid', () {
      final profile = Profile(name: 'Gogo Dlamini');
      expect(profile.isValid, isTrue);
      expect(profile.validationError, isEmpty);
    });

    test('name is trimmed when read', () {
      final profile = Profile(name: '  Jan van der Merwe  ');
      expect(profile.name, 'Jan van der Merwe');
    });

    test('address and bio are optional', () {
      final profile = Profile(name: 'Tara');
      expect(profile.address, isNull);
      expect(profile.bio, isNull);
      expect(profile.isValid, isTrue);
    });

    test('a bio at the max length is acceptable', () {
      final bio = List.filled(Profile.maxBioLength, 'a').join();
      final profile = Profile(name: 'Tara', bio: bio);
      expect(profile.isValid, isTrue);
    });

    test('a bio over the max length is rejected', () {
      final bio = List.filled(Profile.maxBioLength + 1, 'a').join();
      final profile = Profile(name: 'Tara', bio: bio);
      expect(profile.isValid, isFalse);
      expect(profile.validationError, contains('120'));
    });
  });

  group('Profile persistence', () {
    test('round-trips through JSON', () {
      final profile = Profile(
        name: 'Gogo',
        address: 'Harbour Road 3',
        bio: 'Retired teacher, happy to chat.',
      );
      final restored = Profile.fromJson(profile.toJson());
      expect(restored.name, profile.name);
      expect(restored.address, profile.address);
      expect(restored.bio, profile.bio);
    });

    test('optional fields round-trip as null', () {
      final profile = Profile(name: 'Tara');
      final restored = Profile.fromJson(profile.toJson());
      expect(restored.address, isNull);
      expect(restored.bio, isNull);
    });
  });
}
