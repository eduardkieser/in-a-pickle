import 'categories.dart';

class Offer {
  final bool available;
  final Set<String> categoryIds;

  const Offer({
    this.available = false,
    this.categoryIds = const {},
  });

  bool offers(String categoryId) => categoryIds.contains(categoryId);

  Offer withAvailable(bool value) {
    return Offer(available: value, categoryIds: categoryIds);
  }

  Offer withOffer(String categoryId, bool value) {
    final next = Set<String>.of(categoryIds);
    if (value) {
      next.add(categoryId);
    } else {
      next.remove(categoryId);
    }
    return Offer(available: available, categoryIds: next);
  }

  Map<String, Object?> toJson() => {
        'available': available,
        'categoryIds': categoryIds.toList(),
      };

  factory Offer.fromJson(Map<String, Object?> json) {
    final rawIds = (json['categoryIds'] as List<Object?>?) ?? const [];
    final ids = <String>{};
    for (final item in rawIds) {
      if (item is! String || item.isEmpty) {
        throw ArgumentError('offer has a malformed category id');
      }
      if (categoryById(item) == null) {
        throw ArgumentError('offer has an unknown category $item');
      }
      ids.add(item);
    }
    return Offer(
      available: json['available'] as bool? ?? false,
      categoryIds: ids,
    );
  }
}
