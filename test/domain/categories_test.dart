import 'package:flutter_test/flutter_test.dart';
import 'package:in_a_pickle/src/domain/categories.dart';

void main() {
  test('the category list is not empty', () {
    expect(kPickleCategories, isNotEmpty);
  });

  test('category ids are unique', () {
    final ids = kPickleCategories.map((c) => c.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('every category has a usable id, title and hint', () {
    for (final c in kPickleCategories) {
      expect(c.id, isNotEmpty, reason: '${c.title} has no id');
      expect(c.title, isNotEmpty, reason: '${c.id} has no title');
      expect(c.hint, isNotEmpty, reason: '${c.id} has no hint');
    }
  });

  test('covers the everyday pickles a village needs', () {
    final ids = kPickleCategories.map((c) => c.id).toSet();
    for (final expected in [
      'lift',
      'shopping',
      'house',
      'medical',
      'company',
      'petcare',
      'tech',
    ]) {
      expect(ids, contains(expected), reason: 'missing $expected');
    }
  });

  test('titles read as plain help-first language', () {
    for (final c in kPickleCategories) {
      expect(c.title, isNot(matches(r'\bhelp\b')),
          reason: '${c.id} title leans on the word "help"');
    }
  });

  test('a category can be looked up by id', () {
    final lift = categoryById('lift');
    expect(lift, isNotNull);
    expect(lift!.title, 'A lift');
  });

  test('unknown ids resolve to null', () {
    expect(categoryById('nope'), isNull);
  });
}
