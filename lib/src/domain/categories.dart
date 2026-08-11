class PickleCategory {
  final String id;
  final String title;
  final String hint;

  const PickleCategory({
    required this.id,
    required this.title,
    required this.hint,
  });
}

const kPickleCategories = <PickleCategory>[
  PickleCategory(
    id: 'lift',
    title: 'A lift',
    hint: 'To the shop, clinic or station',
  ),
  PickleCategory(
    id: 'shopping',
    title: 'Shopping',
    hint: 'Fetch supplies or a script',
  ),
  PickleCategory(
    id: 'house',
    title: 'Around the house',
    hint: 'A tap, a bulb, a shelf',
  ),
  PickleCategory(
    id: 'medical',
    title: 'Medical',
    hint: 'Clinic run, care or a check-in',
  ),
  PickleCategory(
    id: 'company',
    title: 'Company',
    hint: 'A cuppa and a chat',
  ),
  PickleCategory(
    id: 'petcare',
    title: 'Pet care',
    hint: 'Feeding, walking, sitting',
  ),
  PickleCategory(
    id: 'tech',
    title: 'Technology',
    hint: 'A phone, a TV, a laptop',
  ),
];

PickleCategory? categoryById(String id) {
  for (final category in kPickleCategories) {
    if (category.id == id) return category;
  }
  return null;
}